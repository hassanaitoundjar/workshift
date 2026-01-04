import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/employee.dart';
import '../models/client.dart';
import '../models/shift.dart';

class DatabaseProvider extends ChangeNotifier {
  static const String employeeBoxName = 'employees';
  static const String clientBoxName = 'clients';
  static const String shiftBoxName = 'shifts';
  static const String settingsBoxName = 'settings';

  Box<Employee>? _employeeBox;
  Box<Client>? _clientBox;
  Box<Shift>? _shiftBox;
  Box? _settingsBox;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Initialize Hive and open boxes
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(EmployeeAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ClientAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(ShiftTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(ShiftAdapter());
      }

      // Delete old boxes if they exist (to handle schema changes)
      try {
        await Hive.deleteBoxFromDisk(employeeBoxName);
        await Hive.deleteBoxFromDisk(clientBoxName);
        await Hive.deleteBoxFromDisk(shiftBoxName);
      } catch (e) {
        debugPrint('No old boxes to delete: $e');
      }

      // Open boxes
      _employeeBox = await Hive.openBox<Employee>(employeeBoxName);
      _clientBox = await Hive.openBox<Client>(clientBoxName);
      _shiftBox = await Hive.openBox<Shift>(shiftBoxName);
      _settingsBox = await Hive.openBox(settingsBoxName);

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  // Employee operations
  List<Employee> getAllEmployees() {
    return _employeeBox?.values.toList() ?? [];
  }

  List<Employee> getActiveEmployees() {
    return _employeeBox?.values.where((e) => e.isActive).toList() ?? [];
  }

  Employee? getEmployee(String id) {
    return _employeeBox?.values.firstWhere(
      (e) => e.id == id,
      orElse: () => Employee(id: '', name: ''),
    );
  }

  Future<void> addEmployee(Employee employee) async {
    await _employeeBox?.put(employee.id, employee);
    notifyListeners();
  }

  Future<void> updateEmployee(Employee employee) async {
    await _employeeBox?.put(employee.id, employee);
    notifyListeners();
  }

  Future<void> deleteEmployee(String id) async {
    await _employeeBox?.delete(id);
    // Also delete associated shifts
    final shifts = getShiftsByEmployee(id);
    for (var shift in shifts) {
      await deleteShift(shift.id);
    }
    notifyListeners();
  }

  // Client operations
  List<Client> getAllClients() {
    return _clientBox?.values.toList() ?? [];
  }

  List<Client> getActiveClients() {
    return _clientBox?.values.where((c) => c.isActive).toList() ?? [];
  }

  Client? getClient(String id) {
    return _clientBox?.values.firstWhere(
      (c) => c.id == id,
      orElse: () => Client(id: '', name: ''),
    );
  }

  Future<void> addClient(Client client) async {
    await _clientBox?.put(client.id, client);
    notifyListeners();
  }

  Future<void> updateClient(Client client) async {
    await _clientBox?.put(client.id, client);
    notifyListeners();
  }

  Future<void> deleteClient(String id) async {
    await _clientBox?.delete(id);
    // Update shifts to remove client reference
    final shifts = getShiftsByClient(id);
    for (var shift in shifts) {
      await updateShift(shift.copyWith(clientId: null));
    }
    notifyListeners();
  }

  // Shift operations
  List<Shift> getAllShifts() {
    return _shiftBox?.values.toList() ?? [];
  }

  Shift? getShift(String id) {
    return _shiftBox?.values.firstWhere(
      (s) => s.id == id,
      orElse: () => Shift(
        id: '',
        employeeId: '',
        date: DateTime.now(),
        shiftType: ShiftType.allDay,
      ),
    );
  }

  List<Shift> getShiftsByEmployee(String employeeId) {
    return _shiftBox?.values
            .where((s) => s.employeeId == employeeId)
            .toList() ??
        [];
  }

  List<Shift> getShiftsByClient(String clientId) {
    return _shiftBox?.values.where((s) => s.clientId == clientId).toList() ??
        [];
  }

  List<Shift> getShiftsByDate(DateTime date) {
    return _shiftBox?.values.where((s) {
          return s.date.year == date.year &&
              s.date.month == date.month &&
              s.date.day == date.day;
        }).toList() ??
        [];
  }

  List<Shift> getShiftsByDateRange(DateTime start, DateTime end) {
    return _shiftBox?.values.where((s) {
          return s.date.isAfter(start.subtract(const Duration(days: 1))) &&
              s.date.isBefore(end.add(const Duration(days: 1)));
        }).toList() ??
        [];
  }

  Future<void> addShift(Shift shift) async {
    await _shiftBox?.put(shift.id, shift);
    notifyListeners();
  }

  Future<void> updateShift(Shift shift) async {
    await _shiftBox?.put(shift.id, shift);
    notifyListeners();
  }

  Future<void> deleteShift(String id) async {
    await _shiftBox?.delete(id);
    notifyListeners();
  }

  // Check for shift conflicts
  // Allows: Morning + Afternoon on same day (different or same client)
  // Prevents: All Day + anything, Morning + Morning, Afternoon + Afternoon
  bool hasConflict(Shift shift) {
    final employeeShifts = getShiftsByEmployee(shift.employeeId);

    for (var existingShift in employeeShifts) {
      // Skip checking against itself
      if (existingShift.id == shift.id) continue;

      // Check if on same date
      if (existingShift.date.year == shift.date.year &&
          existingShift.date.month == shift.date.month &&
          existingShift.date.day == shift.date.day) {
        // If either shift is All Day, it conflicts with everything
        if (existingShift.shiftType == ShiftType.allDay ||
            shift.shiftType == ShiftType.allDay) {
          return true; // Conflict found
        }

        // If both are Morning, conflict
        if (existingShift.shiftType == ShiftType.morning &&
            shift.shiftType == ShiftType.morning) {
          return true; // Conflict found
        }

        // If both are Afternoon, conflict
        if (existingShift.shiftType == ShiftType.afternoon &&
            shift.shiftType == ShiftType.afternoon) {
          return true; // Conflict found
        }

        // Morning + Afternoon is allowed (no conflict)
        // Off + anything is allowed (no conflict)
      }
    }

    return false;
  }

  // Settings operations
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
    notifyListeners();
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox?.get(key, defaultValue: defaultValue);
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _employeeBox?.clear();
    await _clientBox?.clear();
    await _shiftBox?.clear();
    notifyListeners();
  }

  // Close all boxes
  Future<void> close() async {
    await _employeeBox?.close();
    await _clientBox?.close();
    await _shiftBox?.close();
    await _settingsBox?.close();
  }

  // Export data to JSON string
  Future<String> exportData() async {
    final data = {
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'employees': _employeeBox?.values.map((e) => e.toJson()).toList() ?? [],
      'clients': _clientBox?.values.map((c) => c.toJson()).toList() ?? [],
      'shifts': _shiftBox?.values.map((s) => s.toJson()).toList() ?? [],
    };
    return jsonEncode(data);
  }

  // Import data from JSON string
  Future<void> importData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString);

      // Validate structure
      if (data['employees'] == null ||
          data['clients'] == null ||
          data['shifts'] == null) {
        throw const FormatException('Invalid backup file format');
      }

      // Clear existing data
      await clearAllData();

      // Restore Employees
      final employees = (data['employees'] as List)
          .map((e) => Employee.fromJson(e))
          .toList();
      for (var employee in employees) {
        await addEmployee(employee);
      }

      // Restore Clients
      final clients = (data['clients'] as List)
          .map((c) => Client.fromJson(c))
          .toList();
      for (var client in clients) {
        await addClient(client);
      }

      // Restore Shifts
      final shifts = (data['shifts'] as List)
          .map((s) => Shift.fromJson(s))
          .toList();
      for (var shift in shifts) {
        await addShift(shift);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error importing data: $e');
      rethrow;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/shift.dart';
import '../../models/employee.dart';
import '../../models/client.dart';
import '../../providers/database_provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';

class AddShiftScreen extends StatefulWidget {
  final Shift? shift;

  const AddShiftScreen({super.key, this.shift});

  @override
  State<AddShiftScreen> createState() => _AddShiftScreenState();
}

class _AddShiftScreenState extends State<AddShiftScreen> {
  final _formKey = GlobalKey<FormState>();

  Employee? _selectedEmployee;
  Client? _selectedClient;
  DateTime _selectedDate = DateTime.now();
  ShiftType _selectedShiftType = ShiftType.allDay;
  final _notesController = TextEditingController();
  final _advanceController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.shift != null) {
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      _selectedEmployee = dbProvider.getEmployee(widget.shift!.employeeId);
      if (widget.shift!.clientId != null) {
        _selectedClient = dbProvider.getClient(widget.shift!.clientId!);
      }
      _selectedDate = widget.shift!.date;
      _selectedShiftType = widget.shift!.shiftType;
      _notesController.text = widget.shift!.notes ?? '';
      _advanceController.text = widget.shift!.advanceMoney > 0
          ? widget.shift!.advanceMoney.toString()
          : '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  Future<void> _saveShift() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEmployee == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectEmployee)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

    final shift = Shift(
      id: widget.shift?.id ?? const Uuid().v4(),
      employeeId: _selectedEmployee!.id,
      clientId: _selectedClient?.id,
      date: _selectedDate,
      shiftType: _selectedShiftType,
      advanceMoney: _advanceController.text.trim().isEmpty
          ? 0.0
          : double.parse(_advanceController.text.trim()),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.shift?.createdAt ?? DateTime.now(),
    );

    // Check for conflicts
    if (dbProvider.hasConflict(shift)) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Get existing shift to show more specific error
        final existingShifts = dbProvider.getShiftsByEmployee(_selectedEmployee!.id)
            .where((s) => 
                s.date.year == _selectedDate.year &&
                s.date.month == _selectedDate.month &&
                s.date.day == _selectedDate.day &&
                s.id != shift.id)
            .toList();
        
        final l10n = AppLocalizations.of(context)!;
        String conflictMessage;
        if (existingShifts.isNotEmpty) {
          final existingShift = existingShifts.first;
          if (existingShift.shiftType == ShiftType.allDay || shift.shiftType == ShiftType.allDay) {
            conflictMessage = l10n.cannotAddShift;
          } else if (existingShift.shiftType == shift.shiftType) {
            conflictMessage = l10n.shiftConflictDetected;
          } else {
            conflictMessage = l10n.shiftConflictDetected;
          }
        } else {
          conflictMessage = l10n.shiftConflictDetected;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(conflictMessage),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (widget.shift == null) {
      await dbProvider.addShift(shift);
    } else {
      await dbProvider.updateShift(shift);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dbProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shift == null ? l10n.addShift : l10n.editShift),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _saveShift),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Employee Selection
            Text(
              '${l10n.employee} *',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showEmployeeDialog(dbProvider),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedEmployee?.name ?? l10n.selectEmployee,
                        style: TextStyle(
                          color: _selectedEmployee == null
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Client Selection (Optional)
            Text(
              l10n.clientOptional,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showClientDialog(dbProvider),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.business_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedClient?.name ?? l10n.selectClient,
                        style: TextStyle(
                          color: _selectedClient == null
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Date Selection
            Text(
              '${l10n.date} *',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(DateFormat('EEEE, MMM d, y').format(_selectedDate)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Shift Type Selection
            Text(
              '${l10n.shiftType} *',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildShiftTypeChip(
                  ShiftType.morning,
                  l10n.morning,
                  l10n.fourHours,
                  AppTheme.morningShiftColor,
                ),
                _buildShiftTypeChip(
                  ShiftType.allDay,
                  l10n.allDay,
                  l10n.eightHours,
                  AppTheme.allDayShiftColor,
                ),
                _buildShiftTypeChip(
                  ShiftType.afternoon,
                  l10n.afternoon,
                  l10n.fourHours,
                  AppTheme.afternoonShiftColor,
                ),
                _buildShiftTypeChip(
                  ShiftType.off,
                  l10n.off,
                  l10n.zeroHours,
                  AppTheme.offShiftColor,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Advance Money (Optional)
            Text(
              '${l10n.advanceMoney} (${l10n.optional})',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _advanceController,
              decoration: InputDecoration(
                hintText: l10n.enterAdvanceAmount,
                prefixIcon: const Icon(Icons.money),
                suffixText: 'MAD',
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 24),

            // Notes
            Text(
              '${l10n.notes} (${l10n.optional})',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: l10n.addNotes,
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 40),

            // Save Button
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isLoading ? null : _saveShift,
                  child: Center(
                    child: Text(
                      widget.shift == null ? l10n.addShift : l10n.updateShift,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftTypeChip(
    ShiftType type,
    String label,
    String duration,
    Color color,
  ) {
    final isSelected = _selectedShiftType == type;

    return FilterChip(
      selected: isSelected,
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            duration,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.white70 : color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      selectedColor: color,
      checkmarkColor: Colors.white,
      onSelected: (selected) {
        setState(() {
          _selectedShiftType = type;
        });
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showEmployeeDialog(DatabaseProvider dbProvider) {
    showDialog(
      context: context,
      builder: (context) {
        final employees = dbProvider.getActiveEmployees();

        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.selectEmployee),
          content: SizedBox(
            width: double.maxFinite,
            child: employees.isEmpty
                ? Center(child: Text(l10n.noEmployeesAvailable))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final employee = employees[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            employee.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(employee.name),
                        subtitle: employee.phone != null
                            ? Text(employee.phone!)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedEmployee = employee;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  void _showClientDialog(DatabaseProvider dbProvider) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final clients = dbProvider.getActiveClients();

        return AlertDialog(
          title: Text(l10n.selectClient),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.clear),
                  title: Text(l10n.noClient),
                  onTap: () {
                    setState(() {
                      _selectedClient = null;
                    });
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ...clients.map(
                  (client) => ListTile(
                    leading: const Icon(Icons.business),
                    title: Text(client.name),
                    subtitle: client.location != null
                        ? Text(client.location!)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedClient = client;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }
}

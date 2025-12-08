import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'dart:async';
import '../../config/theme.dart';
import '../../providers/database_provider.dart';
import '../../models/employee.dart';
import '../../models/shift.dart';
import '../../l10n/app_localizations.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Employee? _selectedEmployee;
  DateTime _selectedMonth = DateTime.now();
  bool _isGenerating = false;

  // Get start and end dates from selected month
  DateTime get _startDate => DateTime(_selectedMonth.year, _selectedMonth.month, 1);
  DateTime get _endDate => DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dbProvider = Provider.of<DatabaseProvider>(context);
    final employees = dbProvider.getActiveEmployees();
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    // Get shifts for selected employee
    List<Shift> shifts = [];
    if (_selectedEmployee != null) {
      shifts = dbProvider.getShiftsByEmployee(_selectedEmployee!.id)
          .where((shift) =>
              shift.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
              shift.date.isBefore(_endDate.add(const Duration(days: 1))))
          .toList();
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: isSmallScreen ? 160 : 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCollapsed = constraints.maxHeight < 100;
                    if (isCollapsed) {
                      return Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 16),
                          child: Text(
                            l10n.reports,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                titlePadding: EdgeInsets.zero,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isExpanded = constraints.maxHeight > 150;
                        final iconSize = isExpanded ? 32.0 : 24.0;
                        final titleSize = isExpanded ? 28.0 : 20.0;
                        final spacing = isExpanded ? 12.0 : 8.0;
                        final topPadding = isExpanded ? 60.0 : 20.0;
                        final bottomPadding = isExpanded ? 16.0 : 8.0;

                        return Padding(
                          padding: EdgeInsets.only(
                            top: topPadding,
                            left: 16,
                            right: 16,
                            bottom: bottomPadding,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(isExpanded ? 16 : 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.assessment_rounded,
                                  color: Colors.white,
                                  size: iconSize,
                                ),
                              ),
                              if (spacing > 0) SizedBox(height: spacing),
                              Flexible(
                                child: Text(
                                  l10n.reports,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: titleSize,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 4),
                                Flexible(
                                  child: Text(
                                    l10n.generateEmployeeReports,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employee Selection
                    _buildSectionHeader(context, l10n.selectEmployee, Icons.person_rounded, isSmallScreen),
                    const SizedBox(height: 12),
                    _buildEmployeeSelector(context, dbProvider, employees, isSmallScreen),
                    const SizedBox(height: 24),

                    // Month Selection
                    _buildSectionHeader(context, l10n.selectMonth, Icons.calendar_month_rounded, isSmallScreen),
                    const SizedBox(height: 12),
                    _buildMonthSelector(context, isSmallScreen),
                    const SizedBox(height: 24),

                    // Report Summary
                    if (_selectedEmployee != null) ...[
                      _buildSectionHeader(context, l10n.reportSummary, Icons.summarize_rounded, isSmallScreen),
                      const SizedBox(height: 12),
                      _buildReportSummary(context, shifts, _selectedEmployee!, isSmallScreen),
                      const SizedBox(height: 24),
                    ],

                    // Action Buttons
                    _buildSectionHeader(context, l10n.exportOptions, Icons.file_download_rounded, isSmallScreen),
                    const SizedBox(height: 12),
                    if (_selectedEmployee == null)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: Colors.grey.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.selectEmployeeToGenerateReports,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              context,
                              l10n.downloadExcel,
                              Icons.file_download_rounded,
                              AppTheme.accentColor,
                              () => _generateExcelReport(shifts, _selectedEmployee!),
                              isSmallScreen,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 10 : 12),
                          Expanded(
                            child: _buildActionButton(
                              context,
                              l10n.sharePdf,
                              Icons.share_rounded,
                              AppTheme.primaryColor,
                              () => _generateAndSharePDF(shifts, _selectedEmployee!),
                              isSmallScreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: isSmallScreen ? 20 : 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: isSmallScreen ? 18 : 20),
        ),
        SizedBox(width: isSmallScreen ? 10 : 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 18 : null,
              ),
        ),
      ],
    );
  }

  Widget _buildEmployeeSelector(
    BuildContext context,
    DatabaseProvider dbProvider,
    List<Employee> employees,
    bool isSmallScreen,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showEmployeeDialog(context, dbProvider, employees),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppTheme.primaryColor,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedEmployee?.name ?? AppLocalizations.of(context)!.selectEmployee,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _selectedEmployee == null ? Colors.grey.shade600 : Colors.black,
                          ),
                    ),
                    if (_selectedEmployee != null && _selectedEmployee!.phone != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _selectedEmployee!.phone!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down_rounded, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showMonthPicker(context),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: AppTheme.accentColor,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM dd').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down_rounded, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportSummary(
    BuildContext context,
    List<Shift> shifts,
    Employee employee,
    bool isSmallScreen,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final totalDays = shifts.length;
    final totalEarnings = shifts.fold<double>(
      0,
      (sum, shift) => sum + (shift.durationInHours / 8.0) * employee.pricePerDay,
    );
    final totalAdvances = shifts.fold<double>(
      0,
      (sum, shift) => sum + shift.advanceMoney,
    );
    final balance = totalEarnings - totalAdvances;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalShifts,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '$totalDays',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalEarnings,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalEarnings.toStringAsFixed(0)} MAD',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalAdvances,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalAdvances.toStringAsFixed(0)} MAD',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.balanceToPay,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: balance >= 0
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.red.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${balance >= 0 ? '+' : ''}${balance.toStringAsFixed(0)} MAD',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    bool isSmallScreen,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _isGenerating ? null : onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 16 : 18,
              horizontal: isSmallScreen ? 12 : 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isGenerating)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(icon, color: Colors.white, size: isSmallScreen ? 20 : 24),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    final currentYear = _selectedMonth.year;
    final currentMonth = _selectedMonth.month;

    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.selectMonth),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Year selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(currentYear - 1, currentMonth);
                      });
                      Navigator.pop(context);
                      _showMonthPicker(context);
                    },
                  ),
                  Text(
                    currentYear.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(currentYear + 1, currentMonth);
                      });
                      Navigator.pop(context);
                      _showMonthPicker(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Month grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = month == currentMonth;
                  final monthName = DateFormat('MMM').format(DateTime(currentYear, month));

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMonth = DateTime(currentYear, month);
                      });
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          monthName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
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

  void _showEmployeeDialog(BuildContext context, DatabaseProvider dbProvider, List<Employee> employees) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        child: Text(
                          employee.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(employee.name),
                      subtitle: employee.phone != null ? Text(employee.phone!) : null,
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

  Future<void> _generateExcelReport(List<Shift> shifts, Employee employee) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isGenerating = true);

    try {
      final excel = Excel.createExcel();
      
      // Use the default sheet that's created
      final sheet = excel['Sheet1'];

      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

      // Calculate monthly summary
      final workDays = shifts.where((s) => s.shiftType != ShiftType.off).length;
      final offDays = shifts.where((s) => s.shiftType == ShiftType.off).length;
      final totalEarnings = shifts.fold<double>(
        0,
        (sum, shift) => sum + (shift.durationInHours / 8.0) * employee.pricePerDay,
      );
      final totalAdvances = shifts.fold<double>(
        0,
        (sum, shift) => sum + shift.advanceMoney,
      );
      final totalPay = totalEarnings - totalAdvances;
      
      // Calculate total work days by client
      final workDaysByClient = <String, int>{};
      for (var shift in shifts.where((s) => s.shiftType != ShiftType.off)) {
        if (shift.clientId != null) {
          final client = dbProvider.getClient(shift.clientId!);
          final clientName = client?.name ?? l10n.na;
          final dateKey = DateTime(shift.date.year, shift.date.month, shift.date.day);
          workDaysByClient.putIfAbsent('$clientName-${dateKey.toString()}', () => 0);
          workDaysByClient['$clientName-${dateKey.toString()}'] = 1;
        }
      }
      final totalWorkDaysByClient = workDaysByClient.length;

      // Group ALL shifts by date (including off days)
      final allShiftsByDate = <DateTime, List<Shift>>{};
      for (var shift in shifts) {
        final dateKey = DateTime(shift.date.year, shift.date.month, shift.date.day);
        allShiftsByDate.putIfAbsent(dateKey, () => []).add(shift);
      }

      // Column headers
      sheet.appendRow([
        'date',
        'employe',
        'client',
        'total work day month',
        'advouce',
        'total off day',
        'total pay',
        'note',
      ]);
      
      // Apply header row colors
      final headerStyle = CellStyle(
        backgroundColorHex: '#4472C4', // Blue header
        fontColorHex: '#FFFFFF', // White text
        bold: true,
      );
      // Apply style to all 8 header columns
      for (var i = 0; i < 8; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = headerStyle;
      }

      // Generate all dates in the selected month
      final allDatesInMonth = <DateTime>[];
      final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
      
      for (var i = 0; i <= lastDay.day - 1; i++) {
        allDatesInMonth.add(DateTime(firstDay.year, firstDay.month, firstDay.day + i));
      }
      
      // Create one row per date (including empty days)
      int rowIndex = 1; // Start after header row
      for (var date in allDatesInMonth) {
        final dateKey = DateTime(date.year, date.month, date.day);
        final dayShifts = allShiftsByDate[dateKey] ?? [];
        final workShifts = dayShifts.where((s) => s.shiftType != ShiftType.off).toList();
        
        // Build client string for this specific date
        String clientString = '';
        if (workShifts.isNotEmpty) {
          final morningShifts = workShifts.where((s) => s.shiftType == ShiftType.morning).toList();
          final afternoonShifts = workShifts.where((s) => s.shiftType == ShiftType.afternoon).toList();
          final allDayShifts = workShifts.where((s) => s.shiftType == ShiftType.allDay).toList();

          final parts = <String>[];
          if (allDayShifts.isNotEmpty) {
            for (var shift in allDayShifts) {
              final client = shift.clientId != null ? dbProvider.getClient(shift.clientId!) : null;
              parts.add('allday: ${client?.name ?? l10n.na}');
            }
          } else {
            if (morningShifts.isNotEmpty) {
              final clients = morningShifts.map((s) {
                final client = s.clientId != null ? dbProvider.getClient(s.clientId!) : null;
                return client?.name ?? l10n.na;
              }).join(',');
              parts.add('morning:$clients');
            }
            if (afternoonShifts.isNotEmpty) {
              final clients = afternoonShifts.map((s) {
                final client = s.clientId != null ? dbProvider.getClient(s.clientId!) : null;
                return client?.name ?? l10n.na;
              }).join(',');
              parts.add('afternoon:$clients');
            }
          }
          clientString = parts.join(' /');
        }
        
        // Get advance and notes for this specific date
        final dayAdvance = dayShifts.fold<double>(0, (sum, s) => sum + s.advanceMoney);
        final dayNotes = dayShifts
            .where((s) => s.notes != null && s.notes!.isNotEmpty)
            .map((s) => s.notes!)
            .join('; ');
        
        // Data row (one row per date, including empty days)
        sheet.appendRow([
          DateFormat('dd/MM/yy').format(date),
          employee.name,
          clientString, // Empty if no shifts
          '${workDays}day', // Monthly total (always shown)
          dayAdvance > 0 ? '${dayAdvance.toStringAsFixed(0)}dh' : (dayShifts.isNotEmpty ? 'o' : ''), // Empty if no shifts and no advance
          '', // Empty column
          '${offDays}day', // Monthly total (always shown)
          totalPay.toStringAsFixed(0), // Monthly total (always shown)
          dayNotes.isNotEmpty ? dayNotes : (dayShifts.isNotEmpty ? '0' : ''), // Empty if no shifts
        ]);
        
        // Apply column colors
        // Column 0 (date) - Light blue
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).cellStyle = 
            CellStyle(backgroundColorHex: '#D9E1F2');
        // Column 1 (employee name) - Light green
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).cellStyle = 
            CellStyle(backgroundColorHex: '#E2EFDA');
        // Column 2 (client) - Light yellow
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).cellStyle = 
            CellStyle(backgroundColorHex: '#FFF2CC');
        // Column 3 (total work day month) - Light orange
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).cellStyle = 
            CellStyle(backgroundColorHex: '#FCE4D6');
        // Column 4 (advouce) - Light pink
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).cellStyle = 
            CellStyle(backgroundColorHex: '#F4B084');
        // Column 5 (empty) - White
        // Column 6 (total off day) - Light purple
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).cellStyle = 
            CellStyle(backgroundColorHex: '#D9D2E9');
        // Column 7 (total pay) - Light teal
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).cellStyle = 
            CellStyle(backgroundColorHex: '#D0E0E3');
        // Column 8 (note) - Light gray
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex)).cellStyle = 
            CellStyle(backgroundColorHex: '#F2F2F2');
        
        rowIndex++;
      }

      // Add summary row at the end with all totals
      sheet.appendRow([]); // Empty row for spacing
      rowIndex++; // Skip empty row
      
      // Add "Total" label row
      sheet.appendRow([
        'Total', // Total label
        employee.name, // employe
        '${totalWorkDaysByClient}day', // client name total (total work days by client)
        '${workDays}day', // dayby month (total work days)
        totalAdvances > 0 ? '${totalAdvances.toStringAsFixed(0)}dh' : '0', // total advounce
        '${workDays}day', // total day (total work days)
        '${offDays}day', // total off day
        totalPay.toStringAsFixed(0), // total pay
        '', // notes (empty)
      ]);
      
      // Apply bold style to total row
      final totalRowStyle = CellStyle(
        backgroundColorHex: '#B4C6E7', // Darker blue for total row
        fontColorHex: '#000000',
        bold: true,
      );
      // Apply style to all 9 total row columns (including date column)
      for (var i = 0; i < 9; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = totalRowStyle;
      }

      // Save file - Use Downloads folder for easier access
      final directory = Platform.isLinux 
          ? Directory('${Platform.environment['HOME']}/Downloads')
          : await getApplicationDocumentsDirectory();
      
      // Ensure directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      final fileName = '${employee.name}_Report_${DateFormat('yyyyMM').format(_selectedMonth)}.xlsx';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      
      // Encode and save Excel file
      final excelBytes = excel.encode();
      if (excelBytes == null) {
        throw Exception('Failed to encode Excel file');
      }
      
      await file.writeAsBytes(excelBytes);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l10n.excelFileSaved}: $fileName'),
                const SizedBox(height: 4),
                Text(
                  filePath,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: l10n.open,
              textColor: Colors.white,
              onPressed: () async {
                // Open file location in file manager
                if (Platform.isLinux) {
                  try {
                    await Process.run('xdg-open', [directory.path]);
                  } catch (e) {
                    // Fallback: try nautilus, dolphin, or thunar
                    try {
                      await Process.run('nautilus', [directory.path]);
                    } catch (_) {
                      try {
                        await Process.run('dolphin', [directory.path]);
                      } catch (_) {
                        try {
                          await Process.run('thunar', [directory.path]);
                        } catch (_) {
                          // If all fail, just show the path
                        }
                      }
                    }
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorGeneratingExcel}: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _generateAndSharePDF(List<Shift> shifts, Employee employee) async {
    setState(() => _isGenerating = true);

    try {
      final l10n = AppLocalizations.of(context)!;
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      final totalEarnings = shifts.fold<double>(
        0,
        (sum, shift) => sum + (shift.durationInHours / 8.0) * employee.pricePerDay,
      );
      final totalAdvances = shifts.fold<double>(
        0,
        (sum, shift) => sum + shift.advanceMoney,
      );
      final balance = totalEarnings - totalAdvances;

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      l10n.employeeReport,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      DateFormat('MMM dd, yyyy').format(DateTime.now()),
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Employee Info
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${l10n.employeeLabel}: ${employee.name}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (employee.phone != null)
                      pw.Text(
                        '${l10n.phone}: ${employee.phone}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    pw.Text(
                      '${l10n.month}: ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('${l10n.totalShifts}:', style: const pw.TextStyle(fontSize: 14)),
                        pw.Text(
                          '${shifts.length}',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('${l10n.totalEarnings}:', style: const pw.TextStyle(fontSize: 14)),
                        pw.Text(
                          '${totalEarnings.toStringAsFixed(2)} MAD',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('${l10n.totalAdvances}:', style: const pw.TextStyle(fontSize: 14)),
                        pw.Text(
                          '${totalAdvances.toStringAsFixed(2)} MAD',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('${l10n.balanceToPay}:', style: const pw.TextStyle(fontSize: 14)),
                        pw.Text(
                          '${balance.toStringAsFixed(2)} MAD',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: balance >= 0 ? PdfColors.green : PdfColors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Shifts Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(l10n.date, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(l10n.shift, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(l10n.client, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(l10n.totalEarnings, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data rows
                  ...shifts.map((shift) {
                    final client = shift.clientId != null
                        ? dbProvider.getClient(shift.clientId!)
                        : null;
                    final earnings = (shift.durationInHours / 8.0) * employee.pricePerDay;

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(DateFormat('MMM dd').format(shift.date)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(shift.shiftTypeName),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(client?.name ?? l10n.na),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${earnings.toStringAsFixed(2)} MAD'),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ];
          },
        ),
      );

      // Share PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '${employee.name}_Report_${DateFormat('yyyyMM').format(_selectedMonth)}.pdf',
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pdfGeneratedReadyToShare),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorGeneratingPdf}: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}


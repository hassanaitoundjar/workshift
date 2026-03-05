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
import 'package:share_plus/share_plus.dart';
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
  DateTime get _startDate =>
      DateTime(_selectedMonth.year, _selectedMonth.month, 1);
  DateTime get _endDate =>
      DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dbProvider = Provider.of<DatabaseProvider>(context);
    final employees = dbProvider.getActiveEmployees();
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    // Get shifts for selected employee
    List<Shift> shifts = [];
    if (_selectedEmployee != null) {
      shifts = dbProvider
          .getShiftsByEmployee(_selectedEmployee!.id)
          .where(
            (shift) =>
                shift.date.isAfter(
                  _startDate.subtract(const Duration(days: 1)),
                ) &&
                shift.date.isBefore(_endDate.add(const Duration(days: 1))),
          )
          .toList();
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: isSmallScreen ? 140 : 200,
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
                        final isExpanded = constraints.maxHeight > 120;
                        final iconSize = isSmallScreen
                            ? (isExpanded ? 24.0 : 20.0)
                            : (isExpanded ? 32.0 : 24.0);
                        final titleSize = isSmallScreen
                            ? (isExpanded ? 22.0 : 18.0)
                            : (isExpanded ? 28.0 : 20.0);
                        final subtitleSize = isSmallScreen ? 12.0 : 14.0;
                        final spacing = isSmallScreen
                            ? (isExpanded ? 8.0 : 4.0)
                            : (isExpanded ? 12.0 : 8.0);
                        final topPadding = isSmallScreen
                            ? (isExpanded ? 24.0 : 16.0)
                            : (isExpanded ? 60.0 : 20.0);
                        final bottomPadding = isSmallScreen
                            ? (isExpanded ? 12.0 : 8.0)
                            : (isExpanded ? 16.0 : 8.0);
                        final iconPadding = isSmallScreen
                            ? (isExpanded ? 10.0 : 8.0)
                            : (isExpanded ? 16.0 : 12.0);

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
                                padding: EdgeInsets.all(iconPadding),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(
                                    isSmallScreen ? 16 : 20,
                                  ),
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
                              Text(
                                l10n.reports,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleSize,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isExpanded) ...[
                                SizedBox(height: isSmallScreen ? 2 : 4),
                                Text(
                                  l10n.generateEmployeeReports,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: subtitleSize,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                    _buildSectionHeader(
                      context,
                      l10n.selectEmployee,
                      Icons.person_rounded,
                      isSmallScreen,
                    ),
                    const SizedBox(height: 12),
                    _buildEmployeeSelector(
                      context,
                      dbProvider,
                      employees,
                      isSmallScreen,
                    ),
                    const SizedBox(height: 24),

                    // Month Selection
                    _buildSectionHeader(
                      context,
                      l10n.selectMonth,
                      Icons.calendar_month_rounded,
                      isSmallScreen,
                    ),
                    const SizedBox(height: 12),
                    _buildMonthSelector(context, isSmallScreen),
                    const SizedBox(height: 24),

                    // Report Summary
                    if (_selectedEmployee != null) ...[
                      _buildSectionHeader(
                        context,
                        l10n.reportSummary,
                        Icons.summarize_rounded,
                        isSmallScreen,
                      ),
                      const SizedBox(height: 12),
                      _buildReportSummary(
                        context,
                        shifts,
                        _selectedEmployee!,
                        isSmallScreen,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Action Buttons
                    _buildSectionHeader(
                      context,
                      l10n.exportOptions,
                      Icons.file_download_rounded,
                      isSmallScreen,
                    ),
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
                            Icon(
                              Icons.info_outline_rounded,
                              color: Colors.grey.shade600,
                            ),
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
                              () => _generateExcelReport(
                                shifts,
                                _selectedEmployee!,
                              ),
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
                              () => _generateAndSharePDF(
                                shifts,
                                _selectedEmployee!,
                              ),
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

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: isSmallScreen ? 18 : 20,
          ),
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
                      _selectedEmployee?.name ??
                          AppLocalizations.of(context)!.selectEmployee,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _selectedEmployee == null
                            ? Colors.grey.shade600
                            : Colors.black,
                      ),
                    ),
                    if (_selectedEmployee != null &&
                        _selectedEmployee!.phone != null) ...[
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
      (sum, shift) =>
          sum + (shift.durationInHours / 8.0) * employee.pricePerDay,
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
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
              Text(
                '$totalDays',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          const Divider(color: Colors.white24),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalEarnings,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isSmallScreen ? 11 : 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${totalEarnings.toStringAsFixed(0)} MAD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              SizedBox(width: isSmallScreen ? 8 : 0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalAdvances,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isSmallScreen ? 11 : 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${totalAdvances.toStringAsFixed(0)} MAD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          const Divider(color: Colors.white24),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  l10n.balanceToPay,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: balance >= 0
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.red.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${balance >= 0 ? '+' : ''}${balance.toStringAsFixed(0)} MAD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 16 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                  Icon(
                    icon,
                    color: Colors.white,
                    size: isSmallScreen ? 20 : 24,
                  ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                          _selectedMonth = DateTime(
                            currentYear - 1,
                            currentMonth,
                          );
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
                          _selectedMonth = DateTime(
                            currentYear + 1,
                            currentMonth,
                          );
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
                    final monthName = DateFormat(
                      'MMM',
                    ).format(DateTime(currentYear, month));

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

  void _showEmployeeDialog(
    BuildContext context,
    DatabaseProvider dbProvider,
    List<Employee> employees,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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

  Future<void> _generateExcelReport(
    List<Shift> shifts,
    Employee employee,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    setState(() => _isGenerating = true);
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

    try {
      final excel = Excel.createExcel();
      // Excel 4.x creates a default sheet usually named 'Sheet1'
      // We can use it directly or rename it.
      // Let's try to rename 'Sheet1' to our desired name.
      final String defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
      final String sheetName =
          'Report ${DateFormat('MMM yyyy', locale).format(_selectedMonth)}';

      // Rename safe approach: check if renaming is supported without crashing
      // If renaming crashes, we will just use the default sheet with the default name
      // but we will try to rename it.
      try {
        excel.rename(defaultSheet, sheetName);
      } catch (e) {
        // If rename fails, we just use the default sheet
        debugPrint('Could not rename sheet: $e');
      }

      // Get the sheet (either renamed or original)
      final sheet = excel[sheetName];

      // --- Styles ---
      final titleStyle = CellStyle(
        fontFamily: getFontFamily(FontFamily.Arial),
        fontSize: 14,
        bold: true,
        fontColorHex: ExcelColor.fromHexString('#1F4E78'), // Dark Blue
      );
      // ..horizontalAlign = HorizontalAlign.Left
      // ..verticalAlign = VerticalAlign.Center;

      final headerStyle = CellStyle(
        fontFamily: getFontFamily(FontFamily.Arial),
        fontSize: 10,
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString(
          '#4472C4',
        ), // Professional Blue
        fontColorHex: ExcelColor.white,
      );
      // ..horizontalAlign = HorizontalAlign.Center
      // ..verticalAlign = VerticalAlign.Center;

      final rowStyleOdd = CellStyle(
        fontFamily: getFontFamily(FontFamily.Arial),
        fontSize: 10,
        backgroundColorHex: ExcelColor.white,
      );
      // ..horizontalAlign = HorizontalAlign.Left
      // ..verticalAlign = VerticalAlign.Center;

      final rowStyleEven = CellStyle(
        fontFamily: getFontFamily(FontFamily.Arial),
        fontSize: 10,
        backgroundColorHex: ExcelColor.fromHexString('#DDEBF7'), // Light Blue
      );
      // ..horizontalAlign = HorizontalAlign.Left
      // ..verticalAlign = VerticalAlign.Center;

      final dateStyleOdd = rowStyleOdd.copyWith();
      // ..horizontalAlign = HorizontalAlign.Center;
      final dateStyleEven = rowStyleEven.copyWith();
      // ..horizontalAlign = HorizontalAlign.Center;
      final numberStyleOdd = rowStyleOdd.copyWith();
      // ..horizontalAlign = HorizontalAlign.Right;
      final numberStyleEven = rowStyleEven.copyWith();
      // ..horizontalAlign = HorizontalAlign.Right;

      // --- Helper to set cell value and style safely ---
      void setCell(int col, int row, dynamic value, CellStyle style) {
        var cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
        );
        cell.value = value != null ? TextCellValue(value.toString()) : null;
        cell.cellStyle = style;
      }

      // --- Header Section ---
      sheet.appendRow([TextCellValue(l10n.employeeReport.toUpperCase())]);
      setCell(0, 0, l10n.employeeReport.toUpperCase(), titleStyle);

      sheet.appendRow([]); // Spacer

      sheet.appendRow([
        TextCellValue('${l10n.employeeLabel}: ${employee.name}'),
        null,
        null,
        TextCellValue(
          '${l10n.month}: ${DateFormat('MMMM yyyy', locale).format(_selectedMonth)}',
        ),
      ]);

      // Apply bold style to info row
      final infoStyle = CellStyle(
        fontFamily: getFontFamily(FontFamily.Arial),
        fontSize: 10,
        bold: true,
      );
      setCell(0, 2, '${l10n.employeeLabel}: ${employee.name}', infoStyle);
      setCell(
        3,
        2,
        '${l10n.month}: ${DateFormat('MMMM yyyy', locale).format(_selectedMonth)}',
        infoStyle,
      );

      sheet.appendRow([]); // Spacer

      // --- Table Headers ---
      final List<TextCellValue> headers = [
        TextCellValue(l10n.date),
        TextCellValue(l10n.day),
        TextCellValue(l10n.client),
        TextCellValue(l10n.projectName),
        TextCellValue(l10n.shift),
        TextCellValue(l10n.totalEarnings),
        TextCellValue(l10n.totalAdvances),
        TextCellValue(l10n.notes),
      ];
      sheet.appendRow(headers);

      // Apply Header Style
      for (int i = 0; i < headers.length; i++) {
        setCell(i, 4, headers[i].value, headerStyle);
      }

      // --- Data Rows ---
      final allShiftsByDate = <DateTime, List<Shift>>{};
      for (var shift in shifts) {
        final dateKey = DateTime(
          shift.date.year,
          shift.date.month,
          shift.date.day,
        );
        allShiftsByDate.putIfAbsent(dateKey, () => []).add(shift);
      }

      final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final lastDay = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        0,
      );
      int rowIndex = 5;

      for (int i = 0; i < lastDay.day; i++) {
        final date = DateTime(firstDay.year, firstDay.month, firstDay.day + i);
        final dateKey = DateTime(date.year, date.month, date.day);
        final dayShifts = allShiftsByDate[dateKey] ?? [];

        // Determine Row Style (Alternating)
        final isEven = rowIndex % 2 == 0;
        final rowStyle = isEven ? rowStyleEven : rowStyleOdd;
        final dateStyle = isEven ? dateStyleEven : dateStyleOdd;
        final numStyle = isEven ? numberStyleEven : numberStyleOdd;

        if (dayShifts.isEmpty) {
          // Empty day row
          final rowData = [
            TextCellValue(DateFormat('dd/MM/yyyy', locale).format(date)),
            TextCellValue(DateFormat('EEEE', locale).format(date)),
            TextCellValue('-'),
            TextCellValue('-'),
            TextCellValue(l10n.off),
            TextCellValue('-'),
            TextCellValue('-'),
            TextCellValue('-'),
          ];
          sheet.appendRow(rowData);

          // Apply styles
          setCell(0, rowIndex, rowData[0].value, dateStyle);
          setCell(1, rowIndex, rowData[1].value, rowStyle);
          for (int c = 2; c < 8; c++) {
            setCell(
              c,
              rowIndex,
              rowData[c].value,
              c >= 5 && c <= 6 ? numStyle : rowStyle,
            );
          }
          rowIndex++;
        } else {
          for (var shift in dayShifts) {
            final client = shift.clientId != null
                ? dbProvider.getClient(shift.clientId!)
                : null;
            final dailyEarning =
                (shift.durationInHours / 8.0) * employee.pricePerDay;

            final rowData = [
              TextCellValue(DateFormat('dd/MM/yyyy', locale).format(date)),
              TextCellValue(DateFormat('EEEE', locale).format(date)),
              TextCellValue(client?.name ?? '-'),
              TextCellValue(client?.projectName ?? '-'),
              TextCellValue(shift.shiftTypeName),
              TextCellValue(dailyEarning.toStringAsFixed(2)),
              TextCellValue(
                shift.advanceMoney > 0
                    ? shift.advanceMoney.toStringAsFixed(2)
                    : '-',
              ),
              TextCellValue(shift.notes ?? ''),
            ];

            sheet.appendRow(rowData);

            // Apply styles
            setCell(0, rowIndex, rowData[0].value, dateStyle);
            setCell(1, rowIndex, rowData[1].value, rowStyle);
            setCell(2, rowIndex, rowData[2].value, rowStyle);
            setCell(3, rowIndex, rowData[3].value, rowStyle);
            setCell(4, rowIndex, rowData[4].value, rowStyle);
            setCell(5, rowIndex, rowData[5].value, numStyle);
            setCell(6, rowIndex, rowData[6].value, numStyle);
            setCell(7, rowIndex, rowData[7].value, rowStyle);

            rowIndex++;
          }
        }
      }

      // --- Summary Section ---
      sheet.appendRow([]); // Spacer
      rowIndex++;

      final totalEarnings = shifts.fold<double>(
        0,
        (sum, s) => sum + (s.durationInHours / 8.0) * employee.pricePerDay,
      );
      final totalAdvances = shifts.fold<double>(
        0,
        (sum, s) => sum + s.advanceMoney,
      );
      final netPay = totalEarnings - totalAdvances;

      // Calculate Total Days (assuming 8 hours = 1 day)
      final totalWorkDays = shifts.fold<double>(
        0,
        (sum, s) =>
            sum +
            (s.shiftType != ShiftType.off ? (s.durationInHours / 8.0) : 0),
      );

      // Header for Summary
      sheet.appendRow([TextCellValue(l10n.reportSummary)]);
      setCell(0, rowIndex, l10n.reportSummary, titleStyle);
      rowIndex++;

      // Summary Data
      final summaryData = [
        [l10n.totalDays, totalWorkDays.toStringAsFixed(1)],
        [l10n.totalEarnings, totalEarnings.toStringAsFixed(2)],
        [l10n.totalAdvances, totalAdvances.toStringAsFixed(2)],
        [l10n.balanceToPay, netPay.toStringAsFixed(2)],
      ];

      final labelStyle = CellStyle(
        fontFamily: getFontFamily(FontFamily.Arial),
        bold: true,
      );
      final valueStyle = CellStyle(fontFamily: getFontFamily(FontFamily.Arial));
      // ..horizontalAlign = HorizontalAlign.Right;

      for (var row in summaryData) {
        final rData = [TextCellValue(row[0]), TextCellValue(row[1])];
        sheet.appendRow(rData);

        // Style Label
        setCell(0, rowIndex, rData[0].value, labelStyle);
        // Style Value
        setCell(1, rowIndex, rData[1].value, valueStyle);

        rowIndex++;
      }

      // --- Client / Project Breakdown ---
      sheet.appendRow([]); // Spacer
      rowIndex++;

      sheet.appendRow([TextCellValue(l10n.clientProjectBreakdown)]);
      setCell(0, rowIndex, l10n.clientProjectBreakdown, titleStyle);
      rowIndex++;

      // Header for Breakdown
      final breakdownHeaders = [
        TextCellValue(l10n.client),
        TextCellValue(l10n.projectName),
        TextCellValue(l10n.totalDays),
      ];
      sheet.appendRow(breakdownHeaders);
      for (int i = 0; i < breakdownHeaders.length; i++) {
        setCell(i, rowIndex, breakdownHeaders[i].value, headerStyle);
      }
      rowIndex++;

      // Aggregate Data
      final breakdownMap = <String, Map<String, dynamic>>{};

      for (var shift in shifts) {
        if (shift.shiftType == ShiftType.off) continue;

        final client = shift.clientId != null
            ? dbProvider.getClient(shift.clientId!)
            : null;

        // Key based on ID to ensure uniqueness, but display String
        final key = client != null ? '${client.id}' : 'unknown';

        if (!breakdownMap.containsKey(key)) {
          breakdownMap[key] = {
            'clientName': client?.name ?? 'Unknown',
            'projectName': client?.projectName ?? '-',
            'days': 0.0,
          };
        }

        // Calculate days based on duration (assuming 8 hours = 1 day)
        // 4 hours = 0.5 days, etc.
        final daysToAdd = shift.durationInHours / 8.0;
        breakdownMap[key]!['days'] += daysToAdd;
      }

      // Write rows
      int breakdownIndex = 0;
      for (var entry in breakdownMap.values) {
        final isEven = breakdownIndex % 2 == 0;
        final rowStyle = isEven ? rowStyleEven : rowStyleOdd;

        final bData = [
          TextCellValue(entry['clientName']),
          TextCellValue(entry['projectName']),
          TextCellValue(entry['days'].toStringAsFixed(1)), // e.g. 1.0, 0.5
        ];

        sheet.appendRow(bData);

        setCell(0, rowIndex, bData[0].value, rowStyle);
        setCell(1, rowIndex, bData[1].value, rowStyle);
        setCell(2, rowIndex, bData[2].value, rowStyle);

        rowIndex++;
        breakdownIndex++;
      }

      // Manual "Auto-Fit" by setting width for known columns
      // In excel ^4.0.0 we use setColumnWidth with index
      sheet.setColumnWidth(0, 15.0); // Date
      sheet.setColumnWidth(1, 15.0); // Day
      sheet.setColumnWidth(2, 25.0); // Client
      sheet.setColumnWidth(3, 20.0); // Project
      sheet.setColumnWidth(4, 15.0); // Shift
      sheet.setColumnWidth(5, 12.0); // Earnings
      sheet.setColumnWidth(6, 12.0); // Advances
      sheet.setColumnWidth(7, 30.0); // Notes

      // Save file logic
      final directory = Platform.isLinux
          ? Directory('${Platform.environment['HOME']}/Downloads')
          : await getApplicationDocumentsDirectory();

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fileName =
          '${employee.name}_Report_${DateFormat('yyyyMM', locale).format(_selectedMonth)}.xlsx';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      final excelBytes = excel.save(); // save() returns List<int>? in v4
      if (excelBytes == null) {
        throw Exception('Failed to encode Excel file');
      }

      await file.writeAsBytes(excelBytes);

      if (mounted) {
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
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: l10n.open,
              textColor: Colors.white,
              onPressed: () async {
                if (Platform.isLinux) {
                  try {
                    await Process.run('xdg-open', [directory.path]);
                  } catch (e) {
                    // ignore
                  }
                } else if (Platform.isAndroid) {
                  try {
                    await Share.shareXFiles([XFile(filePath)], text: fileName);
                  } catch (e) {
                    // ignore
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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

  Future<void> _generateAndSharePDF(
    List<Shift> shifts,
    Employee employee,
  ) async {
    setState(() => _isGenerating = true);

    try {
      final l10n = AppLocalizations.of(context)!;
      final locale = Localizations.localeOf(context).toString();

      // Calculations
      final totalEarnings = shifts.fold<double>(
        0,
        (sum, shift) =>
            sum + (shift.durationInHours / 8.0) * employee.pricePerDay,
      );
      final totalAdvances = shifts.fold<double>(
        0,
        (sum, shift) => sum + shift.advanceMoney,
      );
      final balance = totalEarnings - totalAdvances;
      final totalDays = shifts.fold<double>(
        0,
        (sum, shift) =>
            sum +
            (shift.shiftType != ShiftType.off
                ? shift.durationInHours / 8.0
                : 0),
      );

      final pdf = pw.Document();

      // Theme Colors
      final primaryColor = PdfColors.blue800;
      final secondaryColor = PdfColors.blue50;

      // Helper for Summary Card
      pw.Widget buildStatCard(
        String title,
        String value,
        PdfColor color,
        PdfColor textColor,
      ) {
        return pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(color: textColor, fontSize: 9),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  value,
                  style: pw.TextStyle(
                    color: textColor,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // --- Header ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        l10n.employeeReport.toUpperCase(),
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '${l10n.period}: ${DateFormat('MMMM yyyy', locale).format(_selectedMonth)}',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        '${l10n.reportDate}: ${DateFormat('dd MMM yyyy', locale).format(DateTime.now())}',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'Shihab Falling',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: primaryColor,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: primaryColor, thickness: 1.5),
              pw.SizedBox(height: 20),

              // --- Employee Info ---
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 30,
                          height: 30,
                          decoration: pw.BoxDecoration(
                            color: secondaryColor,
                            shape: pw.BoxShape.circle,
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              employee.name[0].toUpperCase(),
                              style: pw.TextStyle(
                                color: primaryColor,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              employee.name,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (employee.phone != null)
                              pw.Text(
                                employee.phone!,
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          l10n.dailyRate,
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.Text(
                          '${employee.pricePerDay.toStringAsFixed(0)} MAD',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // --- Summary Stats ---
              pw.Row(
                children: [
                  buildStatCard(
                    l10n.totalDays,
                    totalDays.toStringAsFixed(1),
                    PdfColors.blue50,
                    PdfColors.blue800,
                  ),
                  pw.SizedBox(width: 10),
                  buildStatCard(
                    l10n.totalEarnings,
                    '${totalEarnings.toStringAsFixed(0)}', // MAD removed for space or added below
                    PdfColors.green50,
                    PdfColors.green800,
                  ),
                  pw.SizedBox(width: 10),
                  buildStatCard(
                    l10n.totalAdvances,
                    '${totalAdvances.toStringAsFixed(0)}',
                    PdfColors.orange50,
                    PdfColors.orange800,
                  ),
                  pw.SizedBox(width: 10),
                  buildStatCard(
                    l10n.balanceToPay,
                    '${balance.toStringAsFixed(0)}',
                    primaryColor,
                    PdfColors.white,
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // --- Detailed Table ---

              // --- Footer / Signatures ---
              pw.SizedBox(height: 40),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${l10n.employeeSignature}: ${employee.name}',
                        style: const pw.TextStyle(
                          color: PdfColors.grey700,
                          fontSize: 10,
                        ),
                      ),
                      pw.SizedBox(height: 30),
                      pw.Container(
                        width: 100,
                        height: 1,
                        color: PdfColors.grey400,
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${l10n.managerSignature}: ${l10n.managerName}',
                        style: const pw.TextStyle(
                          color: PdfColors.grey700,
                          fontSize: 10,
                        ),
                      ),
                      pw.SizedBox(height: 30),
                      pw.Container(
                        width: 100,
                        height: 1,
                        color: PdfColors.grey400,
                      ),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );

      // Share PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            '${employee.name}_Report_${DateFormat('yyyyMM').format(_selectedMonth)}.pdf',
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

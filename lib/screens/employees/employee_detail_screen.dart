import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshift/models/employee.dart';
import 'package:workshift/models/shift.dart';
import 'package:workshift/providers/database_provider.dart';
import 'package:workshift/config/theme.dart';
import 'package:workshift/screens/employees/add_employee_screen.dart';
import 'package:intl/intl.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context);
    final allShifts = dbProvider.getShiftsByEmployee(employee.id);

    // Calculate current month stats
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = DateTime(now.year, now.month + 1, 0);

    final currentMonthShifts = allShifts.where((shift) {
      return shift.date.isAfter(
            currentMonthStart.subtract(const Duration(days: 1)),
          ) &&
          shift.date.isBefore(currentMonthEnd.add(const Duration(days: 1)));
    }).toList();

    // Calculate last 15 days
    final last15DaysStart = now.subtract(const Duration(days: 15));
    final last15DaysShifts = allShifts.where((shift) {
      return shift.date.isAfter(
            last15DaysStart.subtract(const Duration(days: 1)),
          ) &&
          shift.date.isBefore(now.add(const Duration(days: 1)));
    }).toList();

    // Calculate next 15 days
    final next15DaysEnd = now.add(const Duration(days: 15));
    final next15DaysShifts = allShifts.where((shift) {
      return shift.date.isAfter(now.subtract(const Duration(days: 1))) &&
          shift.date.isBefore(next15DaysEnd.add(const Duration(days: 1)));
    }).toList();

    // Calculate earnings
    double calculateEarnings(List<Shift> shifts) {
      double total = 0;
      for (var shift in shifts) {
        total += (shift.durationInHours / 8.0) * employee.pricePerDay;
      }
      return total;
    }

    // Calculate advances
    double calculateAdvances(List<Shift> shifts) {
      double total = 0;
      for (var shift in shifts) {
        total += shift.advanceMoney;
      }
      return total;
    }

    final monthlyEarnings = calculateEarnings(currentMonthShifts);
    final monthlyAdvances = calculateAdvances(currentMonthShifts);
    final last15Earnings = calculateEarnings(last15DaysShifts);
    final last15Advances = calculateAdvances(last15DaysShifts);
    final next15Earnings = calculateEarnings(next15DaysShifts);
    final next15Advances = calculateAdvances(next15DaysShifts);
    final monthlyBalance = monthlyEarnings - monthlyAdvances;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Hero Avatar
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Hero(
                        tag: 'employee_${employee.id}',
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withValues(alpha: 0.9),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              employee.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        employee.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_money_rounded,
                              size: 18,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${employee.pricePerDay.toStringAsFixed(0)} MAD/day',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddEmployeeScreen(employee: employee),
                    ),
                  );
                },
                tooltip: 'Edit Employee',
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Info
                  if (employee.phone != null) ...[
                    _buildSectionHeader(context, 'Contact Information', Icons.phone_rounded),
                    const SizedBox(height: 12),
                    _buildContactCard(context, employee.phone!),
                    const SizedBox(height: 24),
                  ],

                  // Monthly Statistics Card
                  _buildSectionHeader(context, 'This Month', Icons.calendar_month_rounded),
                  const SizedBox(height: 12),
                  _buildMonthlyStatsCard(
                    context,
                    currentMonthShifts.length,
                    monthlyEarnings,
                    monthlyAdvances,
                    monthlyBalance,
                  ),
                  const SizedBox(height: 24),

                  // 15-Day Periods
                  _buildSectionHeader(context, '15-Day Periods', Icons.timeline_rounded),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _build15DayCard(
                          context,
                          'Last 15 Days',
                          last15DaysShifts.length,
                          last15Earnings,
                          last15Advances,
                          AppTheme.secondaryColor,
                          Icons.history_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _build15DayCard(
                          context,
                          'Next 15 Days',
                          next15DaysShifts.length,
                          next15Earnings,
                          next15Advances,
                          AppTheme.accentColor,
                          Icons.upcoming_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Shifts
                  _buildSectionHeader(context, 'Recent Shifts', Icons.work_history_rounded),
                  const SizedBox(height: 12),
                  if (allShifts.isEmpty)
                    _buildEmptyShiftsCard(context)
                  else
                    ...allShifts.take(10).map((shift) {
                      final client = shift.clientId != null
                          ? dbProvider.getClient(shift.clientId!)
                          : null;
                      return _buildShiftItem(context, shift, client?.name);
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildContactCard(BuildContext context, String phone) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withValues(alpha: 0.1),
            AppTheme.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.phone_rounded,
              color: AppTheme.accentColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement phone call
            },
            icon: Icon(
              Icons.phone_outlined,
              color: AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStatsCard(
    BuildContext context,
    int totalDays,
    double totalEarnings,
    double totalAdvances,
    double balance,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total Days
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Total Days',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '$totalDays',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 20),

          // Earnings and Advances Row
          Row(
            children: [
              Expanded(
                child: _buildStatRow(
                  Icons.attach_money_rounded,
                  'Earned',
                  '${totalEarnings.toStringAsFixed(0)} MAD',
                  Colors.white,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white24,
              ),
              Expanded(
                child: _buildStatRow(
                  Icons.money_off_rounded,
                  'Advances',
                  '${totalAdvances.toStringAsFixed(0)} MAD',
                  Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 20),

          // Balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Balance to Pay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: balance >= 0
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.red.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${balance >= 0 ? '+' : ''}${balance.toStringAsFixed(0)} MAD',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
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

  Widget _buildStatRow(IconData icon, String label, String value, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _build15DayCard(
    BuildContext context,
    String title,
    int days,
    double earnings,
    double advances,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$days',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Text(
                  'days',
                  style: TextStyle(
                    fontSize: 13,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Earned:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '${earnings.toStringAsFixed(0)} MAD',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Advances:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '${advances.toStringAsFixed(0)} MAD',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftItem(
    BuildContext context,
    Shift shift,
    String? clientName,
  ) {
    Color shiftColor;
    switch (shift.shiftType) {
      case ShiftType.morning:
        shiftColor = AppTheme.morningShiftColor;
        break;
      case ShiftType.allDay:
        shiftColor = AppTheme.allDayShiftColor;
        break;
      case ShiftType.afternoon:
        shiftColor = AppTheme.afternoonShiftColor;
        break;
      case ShiftType.off:
        shiftColor = AppTheme.offShiftColor;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 60,
            decoration: BoxDecoration(
              color: shiftColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('MMM dd, yyyy').format(shift.date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                if (clientName != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.business_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        clientName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: shiftColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  shift.shiftTypeName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: shiftColor,
                  ),
                ),
              ),
              if (shift.advanceMoney > 0) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Adv: ${shift.advanceMoney.toStringAsFixed(0)} MAD',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyShiftsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.work_outline_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No shifts yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Shifts will appear here once added',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }
}

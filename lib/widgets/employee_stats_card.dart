import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../models/shift.dart';
import '../providers/database_provider.dart';
import '../config/theme.dart';
import '../screens/employees/employee_detail_screen.dart';

class EmployeeStatsCard extends StatelessWidget {
  final Employee employee;
  final bool isSmallScreen;
  final DateTime? selectedDate;

  const EmployeeStatsCard({
    super.key,
    required this.employee,
    this.isSmallScreen = false,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context);
    final allShifts = dbProvider.getShiftsByEmployee(employee.id);

    // Calculate stats based on selected date or today
    final now = selectedDate ?? DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = DateTime(now.year, now.month + 1, 0);

    final currentMonthShifts = allShifts.where((shift) {
      return shift.date.isAfter(
            currentMonthStart.subtract(const Duration(days: 1)),
          ) &&
          shift.date.isBefore(currentMonthEnd.add(const Duration(days: 1)));
    }).toList();

    // Calculate total earnings based on shift durations
    double calculateEarnings(List<Shift> shifts) {
      double total = 0;
      for (var shift in shifts) {
        // Calculate price based on hours worked
        // 8 hours = full day price, 4 hours = half price
        total += (shift.durationInHours / 8.0) * employee.pricePerDay;
      }
      return total;
    }

    final monthlyEarnings = calculateEarnings(currentMonthShifts);

    // Calculate total days based on shift durations
    double calculateTotalDays(List<Shift> shifts) {
      double total = 0;
      for (var shift in shifts) {
        total += shift.durationInHours / 8.0;
      }
      return total;
    }

    final monthlyDays = calculateTotalDays(currentMonthShifts);

    // Calculate total advances from shifts
    double calculateTotalAdvances(List<Shift> shifts) {
      double total = 0;
      for (var shift in shifts) {
        total += shift.advanceMoney;
      }
      return total;
    }

    final totalAdvances = calculateTotalAdvances(currentMonthShifts);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeDetailScreen(employee: employee),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                AppTheme.primaryColor.withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Employee Header
                Row(
                  children: [
                    // Avatar
                    Hero(
                      tag: 'employee_${employee.id}',
                      child: Container(
                        width: isSmallScreen ? 50 : 60,
                        height: isSmallScreen ? 50 : 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            employee.name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),

                    // Name and Price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 16 : 18,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              // Price Per Day Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.attach_money,
                                      size: isSmallScreen ? 12 : 14,
                                      color: AppTheme.successColor,
                                    ),
                                    Text(
                                      '${employee.pricePerDay.toStringAsFixed(0)} MAD/day',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 11 : 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.successColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Balance Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: (monthlyEarnings - totalAdvances) >= 0
                                      ? AppTheme.primaryColor.withValues(
                                          alpha: 0.1,
                                        )
                                      : AppTheme.errorColor.withValues(
                                          alpha: 0.1,
                                        ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      (monthlyEarnings - totalAdvances) >= 0
                                          ? Icons.account_balance_wallet
                                          : Icons.warning,
                                      size: isSmallScreen ? 12 : 14,
                                      color:
                                          (monthlyEarnings - totalAdvances) >= 0
                                          ? AppTheme.primaryColor
                                          : AppTheme.errorColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${(monthlyEarnings - totalAdvances).abs().toStringAsFixed(0)} MAD',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 11 : 13,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            (monthlyEarnings - totalAdvances) >=
                                                0
                                            ? AppTheme.primaryColor
                                            : AppTheme.errorColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status Indicator
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: employee.isActive
                            ? AppTheme.successColor.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        employee.isActive
                            ? Icons.check_circle
                            : Icons.pause_circle,
                        color: employee.isActive
                            ? AppTheme.successColor
                            : Colors.grey,
                        size: isSmallScreen ? 16 : 20,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isSmallScreen ? 16 : 20),

                // Statistics Grid
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    children: [
                      // Row 1: Days & Earnings
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              context,
                              icon: Icons.calendar_month,
                              label: 'Days',
                              value: monthlyDays % 1 == 0
                                  ? monthlyDays.toInt().toString()
                                  : monthlyDays.toString(),
                              subtitle: 'worked',
                              color: AppTheme.primaryColor,
                              isSmallScreen: isSmallScreen,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              icon: Icons.attach_money,
                              label: 'Earnings',
                              value:
                                  '${monthlyEarnings.toStringAsFixed(0)} MAD',
                              subtitle: 'gross',
                              color: AppTheme.successColor,
                              isSmallScreen: isSmallScreen,
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: Colors.grey.shade300),
                      ),

                      // Row 2: Advances & Net Pay
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              context,
                              icon: Icons.money_off_rounded,
                              label: 'Advances',
                              value: '${totalAdvances.toStringAsFixed(0)} MAD',
                              subtitle: 'taken',
                              color: Colors.orange,
                              isSmallScreen: isSmallScreen,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              icon: Icons.account_balance_wallet_rounded,
                              label: 'Net Pay',
                              value:
                                  '${(monthlyEarnings - totalAdvances).toStringAsFixed(0)} MAD',
                              subtitle: 'to pay',
                              color: (monthlyEarnings - totalAdvances) >= 0
                                  ? AppTheme.primaryColor
                                  : AppTheme.errorColor,
                              isSmallScreen: isSmallScreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isSmallScreen ? 14 : 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isSmallScreen ? 9 : 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: isSmallScreen ? 9 : 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

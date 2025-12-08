import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/database_provider.dart';
import '../config/theme.dart';
import '../screens/employees/employee_detail_screen.dart';
import '../screens/employees/add_employee_screen.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final bool isGridView;

  const EmployeeCard({
    super.key,
    required this.employee,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return _buildGridCard(context);
    } else {
      return _buildListCard(context);
    }
  }

  Widget _buildGridCard(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final shifts = dbProvider.getShiftsByEmployee(employee.id);
    
    // Calculate this month's earnings
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = DateTime(now.year, now.month + 1, 0);
    final currentMonthShifts = shifts.where((shift) {
      return shift.date.isAfter(currentMonthStart.subtract(const Duration(days: 1))) &&
          shift.date.isBefore(currentMonthEnd.add(const Duration(days: 1)));
    }).toList();
    
    final monthlyEarnings = currentMonthShifts.fold<double>(
      0,
      (sum, shift) => sum + (shift.durationInHours / 8.0) * employee.pricePerDay,
    );

    return Hero(
      tag: 'employee_${employee.id}',
      child: Material(
        color: Colors.transparent,
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
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                  AppTheme.secondaryColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar with gradient background
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        employee.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name
                  Text(
                    employee.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Price per day
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${employee.pricePerDay.toStringAsFixed(0)} MAD/day',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        context,
                        shifts.length.toString(),
                        'Shifts',
                        Icons.work_rounded,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey.shade300,
                      ),
                      _buildStatItem(
                        context,
                        monthlyEarnings.toStringAsFixed(0),
                        'MAD',
                        Icons.attach_money_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final shifts = dbProvider.getShiftsByEmployee(employee.id);
    
    // Calculate this month's stats
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = DateTime(now.year, now.month + 1, 0);
    final currentMonthShifts = shifts.where((shift) {
      return shift.date.isAfter(currentMonthStart.subtract(const Duration(days: 1))) &&
          shift.date.isBefore(currentMonthEnd.add(const Duration(days: 1)));
    }).toList();
    
    final monthlyEarnings = currentMonthShifts.fold<double>(
      0,
      (sum, shift) => sum + (shift.durationInHours / 8.0) * employee.pricePerDay,
    );

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (context) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEmployeeScreen(employee: employee),
                ),
              );
            },
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            icon: Icons.edit_rounded,
            label: 'Edit',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          SlidableAction(
            onPressed: (context) {
              _showDeleteDialog(context);
            },
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ],
      ),
      child: Hero(
        tag: 'employee_${employee.id}',
        child: Material(
          color: Colors.transparent,
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
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          employee.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money_rounded,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${employee.pricePerDay.toStringAsFixed(0)} MAD/day',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                              if (employee.phone != null) ...[
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.phone_rounded,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    employee.phone!,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Stats
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                shifts.length.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'shifts',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (monthlyEarnings > 0) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${monthlyEarnings.toStringAsFixed(0)} MAD',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentColor,
                            ),
                          ),
                          Text(
                            'this month',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.errorColor),
            const SizedBox(width: 12),
            const Text('Delete Employee'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${employee.name}? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<DatabaseProvider>(
                context,
                listen: false,
              ).deleteEmployee(employee.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${employee.name} has been deleted'),
                  backgroundColor: AppTheme.errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

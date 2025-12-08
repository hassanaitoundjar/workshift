import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shift.dart';
import '../models/employee.dart';
import '../models/client.dart';
import '../providers/database_provider.dart';
import '../config/theme.dart';

class ShiftCard extends StatelessWidget {
  final Shift shift;

  const ShiftCard({super.key, required this.shift});

  Color _getShiftColor(ShiftType type) {
    switch (type) {
      case ShiftType.morning:
        return AppTheme.morningShiftColor;
      case ShiftType.allDay:
        return AppTheme.allDayShiftColor;
      case ShiftType.afternoon:
        return AppTheme.afternoonShiftColor;
      case ShiftType.off:
        return AppTheme.offShiftColor;
    }
  }

  String _getShiftTypeName(ShiftType type) {
    switch (type) {
      case ShiftType.morning:
        return 'Morning';
      case ShiftType.allDay:
        return 'All Day';
      case ShiftType.afternoon:
        return 'Afternoon';
      case ShiftType.off:
        return 'Off';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context);
    final employee = dbProvider.getEmployee(shift.employeeId);
    final client = shift.clientId != null
        ? dbProvider.getClient(shift.clientId!)
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to shift detail or edit
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Shift Type Indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: _getShiftColor(shift.shiftType),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),

              // Employee Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: _getShiftColor(
                  shift.shiftType,
                ).withValues(alpha: 0.2),
                child: Text(
                  employee?.name[0].toUpperCase() ?? '?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getShiftColor(shift.shiftType),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Shift Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee?.name ?? 'Unknown Employee',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (client != null)
                      Text(
                        client.name,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${shift.durationInHours.toStringAsFixed(0)} hours',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Shift Type Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getShiftColor(shift.shiftType).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getShiftColor(
                      shift.shiftType,
                    ).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _getShiftTypeName(shift.shiftType),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getShiftColor(shift.shiftType),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

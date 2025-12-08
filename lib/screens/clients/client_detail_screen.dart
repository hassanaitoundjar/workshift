import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/client.dart';
import '../../providers/database_provider.dart';
import '../../config/theme.dart';
import '../../widgets/shift_card.dart';
import 'add_client_screen.dart';

class ClientDetailScreen extends StatelessWidget {
  final Client client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context);
    final allShifts = dbProvider.getShiftsByClient(client.id);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    // Get unique employees
    final employeeIds = allShifts.map((s) => s.employeeId).toSet();
    final uniqueEmployees = employeeIds.length;

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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Hero Icon
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.accentGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
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
                        child: const Icon(
                          Icons.business_rounded,
                          size: 56,
                          color: AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (client.location != null)
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
                                Icons.location_on_rounded,
                                size: 18,
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                client.location!,
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
                      builder: (context) => AddClientScreen(client: client),
                    ),
                  );
                },
                tooltip: 'Edit Client',
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Information
                  if (client.contactPhone != null) ...[
                    _buildSectionHeader(
                      context,
                      'Contact Information',
                      Icons.phone_rounded,
                      isSmallScreen,
                    ),
                    const SizedBox(height: 12),
                    _buildContactCard(context, client.contactPhone!, isSmallScreen),
                    const SizedBox(height: 24),
                  ],

                  // Statistics Cards
                  _buildSectionHeader(
                    context,
                    'Statistics',
                    Icons.analytics_rounded,
                    isSmallScreen,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Shifts',
                          allShifts.length.toString(),
                          Icons.work_rounded,
                          AppTheme.accentColor,
                          isSmallScreen,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Employees',
                          uniqueEmployees.toString(),
                          Icons.people_rounded,
                          AppTheme.primaryColor,
                          isSmallScreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'This Month',
                          currentMonthShifts.length.toString(),
                          Icons.calendar_month_rounded,
                          AppTheme.secondaryColor,
                          isSmallScreen,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Last 15 Days',
                          last15DaysShifts.length.toString(),
                          Icons.history_rounded,
                          AppTheme.morningShiftColor,
                          isSmallScreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 15-Day Periods
                  _buildSectionHeader(
                    context,
                    '15-Day Periods',
                    Icons.timeline_rounded,
                    isSmallScreen,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _build15DayCard(
                          context,
                          'Last 15 Days',
                          last15DaysShifts.length,
                          last15DaysShifts.length,
                          AppTheme.secondaryColor,
                          Icons.history_rounded,
                          isSmallScreen,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 12),
                      Expanded(
                        child: _build15DayCard(
                          context,
                          'Next 15 Days',
                          next15DaysShifts.length,
                          next15DaysShifts.length,
                          AppTheme.accentColor,
                          Icons.upcoming_rounded,
                          isSmallScreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Shifts
                  _buildSectionHeader(
                    context,
                    'Recent Shifts',
                    Icons.work_history_rounded,
                    isSmallScreen,
                  ),
                  const SizedBox(height: 12),
                  if (allShifts.isEmpty)
                    _buildEmptyShiftsCard(context, isSmallScreen)
                  else
                    ...allShifts.take(10).map((shift) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ShiftCard(shift: shift),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
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
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.accentColor,
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

  Widget _buildContactCard(
    BuildContext context,
    String phone,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 18 : 20),
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
          SizedBox(width: isSmallScreen ? 14 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 17 : 19,
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

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 24 : 28),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1,
            ),
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _build15DayCard(
    BuildContext context,
    String title,
    int shifts,
    int employees,
    Color color,
    IconData icon,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: isSmallScreen ? 16 : 18),
              ),
              SizedBox(width: isSmallScreen ? 8 : 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: isSmallScreen ? 12 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$shifts',
                style: TextStyle(
                  fontSize: isSmallScreen ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Text(
                  'shifts',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyShiftsCard(BuildContext context, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 28 : 32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.work_outline_rounded,
            size: isSmallScreen ? 44 : 48,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),
          Text(
            'No shifts yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: isSmallScreen ? 15 : null,
                ),
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          Text(
            'Shifts will appear here once assigned',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                  fontSize: isSmallScreen ? 12 : null,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

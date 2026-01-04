import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/database_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/employee_stats_card.dart';
import '../../l10n/app_localizations.dart';
import '../shifts/add_shift_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dbProvider = Provider.of<DatabaseProvider>(context);
    final todayShifts = dbProvider.getShiftsByDate(_selectedDay);
    final allEmployees = dbProvider.getActiveEmployees();
    final workingToday = todayShifts.length;

    // Get upcoming shifts (next 7 days)
    final upcomingShifts = dbProvider.getShiftsByDateRange(
      DateTime.now(),
      DateTime.now().add(const Duration(days: 7)),
    );

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isMediumScreen = size.width < 900;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Modern App Bar with Gradient
            SliverAppBar(
              expandedHeight: isSmallScreen
                  ? 140
                  : isMediumScreen
                  ? 180
                  : 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCollapsed = constraints.maxHeight < 100;
                    return Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'WorkShift',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!isCollapsed) ...[
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'EEEE, MMM dd',
                                ).format(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
                titlePadding: EdgeInsets.zero,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                ),
              ),
            ),

            // Quick Stats Cards
            SliverPadding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              sliver: SliverToBoxAdapter(
                child: AnimationLimiter(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = isSmallScreen
                          ? (constraints.maxWidth - 12) / 2
                          : isMediumScreen
                          ? (constraints.maxWidth - 24) / 3
                          : (constraints.maxWidth - 36) / 4;

                      return Wrap(
                        spacing: isSmallScreen ? 10 : 12,
                        runSpacing: isSmallScreen ? 10 : 12,
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 375),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: StatCard(
                                title: l10n.workingToday,
                                value: workingToday.toString(),
                                icon: Icons.work_rounded,
                                gradient: AppTheme.primaryGradient,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: StatCard(
                                title: l10n.totalStaff,
                                value: allEmployees.length.toString(),
                                icon: Icons.people_rounded,
                                gradient: AppTheme.secondaryGradient,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: StatCard(
                                title: l10n.upcoming,
                                value: upcomingShifts.length.toString(),
                                icon: Icons.calendar_today_rounded,
                                gradient: AppTheme.accentGradient,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: StatCard(
                                title: l10n.activeClients,
                                value: dbProvider
                                    .getActiveClients()
                                    .length
                                    .toString(),
                                icon: Icons.business_rounded,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF093FB),
                                    Color(0xFFF5576C),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Employee Statistics Section
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                isSmallScreen ? 12 : 16,
                isSmallScreen ? 12 : 24,
                isSmallScreen ? 12 : 16,
                12,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.employeeStatistics,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 18 : null,
                          ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Navigate to employees screen
                      },
                      icon: Icon(
                        Icons.arrow_forward_rounded,
                        size: isSmallScreen ? 14 : 16,
                      ),
                      label: Text(
                        l10n.viewAll,
                        style: TextStyle(fontSize: isSmallScreen ? 13 : null),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 12,
                          vertical: isSmallScreen ? 4 : 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Employee Cards with Statistics
            if (allEmployees.isEmpty)
              SliverPadding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: isSmallScreen ? 56 : 64,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Text(
                          l10n.noEmployees,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final employee = allEmployees[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: EmployeeStatsCard(
                              employee: employee,
                              isSmallScreen: isSmallScreen,
                              selectedDate: _focusedDay,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: allEmployees.length > 5
                        ? 5
                        : allEmployees.length,
                  ),
                ),
              ),

            // Calendar Section
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                isSmallScreen ? 12 : 16,
                isSmallScreen ? 12 : 24,
                isSmallScreen ? 12 : 16,
                12,
              ),
              sliver: SliverToBoxAdapter(
                child: Text(
                  l10n.scheduleCalendar,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 18 : null,
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
              ),
              sliver: SliverToBoxAdapter(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      calendarFormat: _calendarFormat,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: AppTheme.accentColor.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: AppTheme.secondaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                        formatButtonShowsNext: false,
                        formatButtonDecoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        formatButtonTextStyle: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: isSmallScreen ? 11 : 12,
                        ),
                        titleTextStyle: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      eventLoader: (day) {
                        return dbProvider.getShiftsByDate(day);
                      },
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.only(bottom: isSmallScreen ? 80 : 100),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddShiftScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(isSmallScreen ? l10n.addShift : l10n.addShift),
        elevation: 4,
      ),
    );
  }
}

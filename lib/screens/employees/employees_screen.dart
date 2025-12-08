import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../config/theme.dart';
import '../../providers/database_provider.dart';
import '../../widgets/employee_card.dart';
import '../../l10n/app_localizations.dart';
import 'add_employee_screen.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  String _searchQuery = '';
  bool _isGridView = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dbProvider = Provider.of<DatabaseProvider>(context);
    var employees = dbProvider.getActiveEmployees();
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isMediumScreen = size.width < 900;

    // Filter employees based on search query
    if (_searchQuery.isNotEmpty) {
      employees = employees.where((employee) {
        return employee.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Calculate total stats
    final totalShifts = employees.fold<int>(
      0,
      (sum, emp) => sum + dbProvider.getShiftsByEmployee(emp.id).length,
    );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Modern App Bar with Stats
            SliverAppBar(
              expandedHeight: isSmallScreen ? 200 : isMediumScreen ? 240 : 260,
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
                            l10n.employees,
                            style: TextStyle(
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
                    gradient: AppTheme.secondaryGradient,
                  ),
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isExpanded = constraints.maxHeight > 150;
                        return Padding(
                          padding: EdgeInsets.only(
                            top: isSmallScreen ? 50 : 60,
                            left: isSmallScreen ? 12 : 16,
                            right: isSmallScreen ? 12 : 16,
                            bottom: isSmallScreen ? 12 : 16,
                          ),
                          child: isExpanded
                              ? Row(
                                  children: [
                                    Expanded(
                                      flex: isSmallScreen ? 3 : 2,
                                      child: _buildEmployeeStatCard(
                                        employees.length,
                                        totalShifts,
                                        isSmallScreen,
                                        l10n,
                                      ),
                                    ),
                                    SizedBox(width: isSmallScreen ? 8 : 12),
                                    Expanded(
                                      child: _buildShiftStatCard(
                                        totalShifts,
                                        isSmallScreen,
                                        l10n,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                  tooltip: _isGridView ? l10n.listView : l10n.gridView,
                ),
              ],
            ),

            // Enhanced Search Bar
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                isSmallScreen ? 12 : 16,
                16,
                isSmallScreen ? 12 : 16,
                8,
              ),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchEmployeesByName,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade600),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, color: Colors.grey.shade600),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 14 : 16,
                        vertical: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
            ),

            // Results Header
            if (employees.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  isSmallScreen ? 12 : 16,
                  8,
                  isSmallScreen ? 12 : 16,
                  12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _searchQuery.isEmpty
                            ? l10n.allEmployees
                            : '${employees.length} ${employees.length != 1 ? l10n.results : l10n.result}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontSize: isSmallScreen ? 15 : null,
                            ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                          icon: Icon(
                            Icons.clear_rounded,
                            size: isSmallScreen ? 14 : 16,
                          ),
                          label: Text(
                            l10n.clear,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : null,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
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

            // Employees List/Grid
            if (employees.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _searchQuery.isEmpty
                              ? Icons.people_outline_rounded
                              : Icons.search_off_rounded,
                          size: 64,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _searchQuery.isEmpty
                            ? l10n.noEmployees
                            : l10n.noEmployeesFound,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isEmpty
                            ? l10n.startByAddingFirstEmployee
                            : l10n.tryDifferentSearchTerm,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isGridView)
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isSmallScreen
                        ? 2
                        : isMediumScreen
                            ? 3
                            : 4,
                    childAspectRatio: isSmallScreen ? 0.75 : 0.8,
                    crossAxisSpacing: isSmallScreen ? 10 : 12,
                    mainAxisSpacing: isSmallScreen ? 10 : 12,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: isSmallScreen
                          ? 2
                          : isMediumScreen
                              ? 3
                              : 4,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: EmployeeCard(
                            employee: employees[index],
                            isGridView: true,
                          ),
                        ),
                      ),
                    );
                  }, childCount: employees.length),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: EmployeeCard(
                            employee: employees[index],
                            isGridView: false,
                          ),
                        ),
                      ),
                    );
                  }, childCount: employees.length),
                ),
              ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(isSmallScreen ? l10n.addEmployee : l10n.addEmployee),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmployeeStatCard(int totalEmployees, int totalShifts, bool isSmallScreen, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.employees,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            totalEmployees.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 32 : 40,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          Text(
            '$totalShifts ${l10n.totalShiftsLabel} • $totalEmployees ${l10n.active}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftStatCard(int totalShifts, bool isSmallScreen, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.work_rounded,
            color: Colors.white,
            size: isSmallScreen ? 28 : 32,
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            totalShifts.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 28 : 36,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          Text(
            l10n.shifts,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: isSmallScreen ? 11 : 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

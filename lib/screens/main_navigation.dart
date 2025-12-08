import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import 'home/home_screen.dart';
import 'employees/employees_screen.dart';
import 'clients/clients_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  final List<Widget> _screens = const [
    HomeScreen(),
    EmployeesScreen(),
    ClientsScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Update navigation items with translations
    final navItems = [
      NavigationItem(icon: Icons.home_rounded, label: l10n.home),
      NavigationItem(icon: Icons.people_rounded, label: l10n.employees),
      NavigationItem(icon: Icons.business_rounded, label: l10n.clients),
      NavigationItem(icon: Icons.assessment_rounded, label: l10n.reports),
      NavigationItem(icon: Icons.settings_rounded, label: l10n.settings),
    ];
    
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).cardTheme.color,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
            items: navItems.map((item) {
              final index = navItems.indexOf(item);
              final isSelected = _currentIndex == index;

              return BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, size: 24),
                ),
                label: item.label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  const NavigationItem({required this.icon, required this.label});
}

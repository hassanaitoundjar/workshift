import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/language_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/update_checker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentVersion = '1.0.0+1';
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    final version = await UpdateChecker.getCurrentVersion();
    if (mounted) {
      setState(() {
        _currentVersion = version;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final dbProvider = Provider.of<DatabaseProvider>(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isMediumScreen = size.width < 900;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: isSmallScreen ? 160 : isMediumScreen ? 200 : 240,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCollapsed = constraints.maxHeight < 120;
                    return Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          bottom: isCollapsed ? 12 : 16,
                        ),
                        child: Row(
                          children: [
                            if (!isCollapsed) ...[
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.settings_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Flexible(
                              child: Text(
                                l10n.settings,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isCollapsed ? 20.0 : 28.0,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
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
                  child: Stack(
                    children: [
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Settings List
            SliverPadding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Language Section
                  _buildSectionHeader(
                    context,
                    l10n.language,
                    Icons.language_rounded,
                    isSmallScreen,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.1),
                          AppTheme.accentColor.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildLanguageTile(
                          context,
                          languageProvider,
                          const Locale('en'),
                          'English',
                          '🇬🇧',
                          isSmallScreen,
                        ),
                        Divider(
                          height: 1,
                          indent: isSmallScreen ? 16 : 20,
                          endIndent: isSmallScreen ? 16 : 20,
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                        _buildLanguageTile(
                          context,
                          languageProvider,
                          const Locale('ar'),
                          'العربية',
                          '🇸🇦',
                          isSmallScreen,
                        ),
                        Divider(
                          height: 1,
                          indent: isSmallScreen ? 16 : 20,
                          endIndent: isSmallScreen ? 16 : 20,
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                        _buildLanguageTile(
                          context,
                          languageProvider,
                          const Locale('fr'),
                          'Français',
                          '🇫🇷',
                          isSmallScreen,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Appearance Section
                  _buildSectionHeader(
                    context,
                    l10n.appearance,
                    Icons.palette_rounded,
                    isSmallScreen,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.1),
                          AppTheme.accentColor.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 20,
                        vertical: isSmallScreen ? 8 : 12,
                      ),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          themeProvider.isDarkMode
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: AppTheme.primaryColor,
                          size: isSmallScreen ? 20 : 22,
                        ),
                      ),
                      title: Text(
                        l10n.darkMode,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 15 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        themeProvider.isDarkMode ? l10n.enabled : l10n.disabled,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Data Management Section
                  _buildSectionHeader(
                    context,
                    l10n.dataManagement,
                    Icons.storage_rounded,
                    isSmallScreen,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.1),
                          AppTheme.accentColor.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildListTile(
                          context,
                          icon: Icons.backup_rounded,
                          title: l10n.backupData,
                          subtitle: l10n.exportAllDataToFile,
                          color: AppTheme.accentColor,
                          onTap: () => _showBackupDialog(context),
                          isSmallScreen: isSmallScreen,
                        ),
                        Divider(
                          height: 1,
                          indent: isSmallScreen ? 16 : 20,
                          endIndent: isSmallScreen ? 16 : 20,
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                        _buildListTile(
                          context,
                          icon: Icons.restore_rounded,
                          title: l10n.restoreData,
                          subtitle: l10n.importDataFromBackup,
                          color: AppTheme.primaryColor,
                          onTap: () => _showRestoreDialog(context),
                          isSmallScreen: isSmallScreen,
                        ),
                        Divider(
                          height: 1,
                          indent: isSmallScreen ? 16 : 20,
                          endIndent: isSmallScreen ? 16 : 20,
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                        _buildListTile(
                          context,
                          icon: Icons.delete_forever_rounded,
                          title: l10n.clearAllData,
                          subtitle: l10n.deleteAllEmployeesClientsShifts,
                          color: AppTheme.errorColor,
                          onTap: () => _showClearDataDialog(context, dbProvider),
                          isSmallScreen: isSmallScreen,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Statistics Section
                  _buildSectionHeader(
                    context,
                    l10n.statistics,
                    Icons.analytics_rounded,
                    isSmallScreen,
                  ),
                  const SizedBox(height: 12),
                  // Statistics Cards Grid
                  isSmallScreen
                      ? Column(
                          children: [
                            _buildStatCard(
                              context,
                              l10n.totalEmployees,
                              dbProvider.getAllEmployees().length.toString(),
                              Icons.people_rounded,
                              AppTheme.primaryColor,
                              isSmallScreen,
                            ),
                            const SizedBox(height: 12),
                            _buildStatCard(
                              context,
                              l10n.totalClients,
                              dbProvider.getAllClients().length.toString(),
                              Icons.business_rounded,
                              AppTheme.accentColor,
                              isSmallScreen,
                            ),
                            const SizedBox(height: 12),
                            _buildStatCard(
                              context,
                              l10n.shifts,
                              dbProvider.getAllShifts().length.toString(),
                              Icons.calendar_today_rounded,
                              AppTheme.secondaryColor,
                              isSmallScreen,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                l10n.totalEmployees,
                                dbProvider.getAllEmployees().length.toString(),
                                Icons.people_rounded,
                                AppTheme.primaryColor,
                                isSmallScreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                l10n.totalClients,
                                dbProvider.getAllClients().length.toString(),
                                Icons.business_rounded,
                                AppTheme.accentColor,
                                isSmallScreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                l10n.shifts,
                                dbProvider.getAllShifts().length.toString(),
                                Icons.calendar_today_rounded,
                                AppTheme.secondaryColor,
                                isSmallScreen,
                              ),
                            ),
                          ],
                        ),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // About Section
                  _buildSectionHeader(
                    context,
                    l10n.about,
                    Icons.info_rounded,
                    isSmallScreen,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.1),
                          AppTheme.accentColor.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildListTile(
                          context,
                          icon: Icons.info_rounded,
                          title: l10n.appVersion,
                          subtitle: _currentVersion.split('+')[0],
                          color: AppTheme.primaryColor,
                          onTap: null,
                          isSmallScreen: isSmallScreen,
                          showTrailing: false,
                        ),
                        Divider(
                          height: 1,
                          indent: isSmallScreen ? 16 : 20,
                          endIndent: isSmallScreen ? 16 : 20,
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                        _buildListTile(
                          context,
                          icon: Icons.system_update_rounded,
                          title: l10n.checkForUpdates,
                          subtitle: _isCheckingUpdate ? l10n.checkingForUpdates : l10n.checkForNewVersion,
                          color: AppTheme.successColor,
                          onTap: _isCheckingUpdate ? null : () => _checkForUpdates(context),
                          isSmallScreen: isSmallScreen,
                          showTrailing: _isCheckingUpdate,
                          trailingWidget: _isCheckingUpdate
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : null,
                        ),
                        Divider(
                          height: 1,
                          indent: isSmallScreen ? 16 : 20,
                          endIndent: isSmallScreen ? 16 : 20,
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                        _buildListTile(
                          context,
                          icon: Icons.description_rounded,
                          title: l10n.aboutWorkShift,
                          subtitle: l10n.manageYourTeamShiftsEfficiently,
                          color: AppTheme.accentColor,
                          onTap: () => _showAboutDialog(context),
                          isSmallScreen: isSmallScreen,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),
                ]),
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
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 18 : null,
              ),
        ),
      ],
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    LanguageProvider languageProvider,
    Locale locale,
    String languageName,
    String flag,
    bool isSmallScreen,
  ) {
    final isSelected = languageProvider.locale == locale;

    return InkWell(
      onTap: () {
        languageProvider.setLanguage(locale);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: 4,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 10 : 14,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.2)
                    : AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                flag,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppTheme.primaryColor : null,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
    required bool isSmallScreen,
    bool showTrailing = true,
    Widget? trailingWidget,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 8 : 12,
      ),
      leading: Icon(
        icon,
        color: color,
        size: isSmallScreen ? 22 : 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isSmallScreen ? 15 : 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: isSmallScreen ? 12 : 13,
        ),
      ),
      trailing: trailingWidget ??
          (showTrailing
              ? Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: isSmallScreen ? 14 : 16,
                  color: Colors.grey.shade400,
                )
              : null),
      onTap: onTap,
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isSmallScreen ? 22 : 24,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: Colors.grey.shade700,
                ),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.backup_rounded, color: AppTheme.accentColor),
            const SizedBox(width: 12),
            Text(l10n.backupData),
          ],
        ),
        content: Text(
          'This feature will export all your data to a file. You can use this file to restore your data later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Backup feature coming soon!'),
                  backgroundColor: AppTheme.accentColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Export'),
          ),
        ],
        );
      },
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.restore_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            const Text('Restore Data'),
          ],
        ),
        content: const Text(
          'This will import data from a backup file. Your current data will be replaced.',
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.restoreFeatureComingSoon),
                  backgroundColor: AppTheme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.import),
          ),
        ],
      );
      },
    );
  }

  void _showClearDataDialog(BuildContext context, DatabaseProvider dbProvider) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.errorColor),
            const SizedBox(width: 12),
            Text(l10n.clearAllData),
          ],
        ),
        content: Text(
          l10n.areYouSureDeleteAll,
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
            onPressed: () async {
              await dbProvider.clearAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All data cleared'),
                    backgroundColor: AppTheme.errorColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      );
      },
    );
  }

  Future<void> _checkForUpdates(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    setState(() {
      _isCheckingUpdate = true;
    });

    try {
      final latestVersion = await UpdateChecker.checkForUpdate();
      final currentVersion = await UpdateChecker.getCurrentVersion();

      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });

        if (latestVersion == null) {
          // Network error or invalid response
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.updateCheckFailed),
                    const SizedBox(height: 4),
                    Text(
                      'URL: ${UpdateChecker.versionCheckUrl}',
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                backgroundColor: AppTheme.warningColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
          return;
        }

        final isUpdateAvailable = UpdateChecker.isUpdateAvailable(
          currentVersion,
          '${latestVersion.version}+${latestVersion.buildNumber}',
        );

        if (isUpdateAvailable) {
          _showUpdateDialog(context, latestVersion);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.appIsUpToDate),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.updateCheckFailed),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showUpdateDialog(BuildContext context, AppVersion latestVersion) {
    final l10n = AppLocalizations.of(context)!;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      barrierDismissible: !latestVersion.forceUpdate,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => !latestVersion.forceUpdate,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.updateAvailable,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.newVersionAvailable}: ${latestVersion.version}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (latestVersion.releaseNotes != null) ...[
                    Text(
                      l10n.releaseNotes,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      latestVersion.releaseNotes!,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (latestVersion.forceUpdate)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: AppTheme.errorColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.forceUpdateRequired,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 13,
                                color: AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              if (!latestVersion.forceUpdate)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.later,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ElevatedButton(
                onPressed: () async {
                  final url = Uri.parse(latestVersion.downloadUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.cannotOpenDownloadLink),
                          backgroundColor: AppTheme.errorColor,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.updateNow),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.work_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'WorkShift',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.version} 1.0.0',
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.modernShiftWorkCalendar,
                style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
              ),
              const SizedBox(height: 16),
              Text(
                '${l10n.features}:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 14 : 15,
                ),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem(l10n.employeeManagement, isSmallScreen),
              _buildFeatureItem(l10n.clientManagement, isSmallScreen),
              _buildFeatureItem(l10n.shiftScheduling, isSmallScreen),
              _buildFeatureItem(l10n.conflictDetection, isSmallScreen),
              _buildFeatureItem(l10n.calendarView, isSmallScreen),
              _buildFeatureItem(l10n.darkModeSupport, isSmallScreen),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.close,
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
        );
      },
    );
  }

  Widget _buildFeatureItem(String feature, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: isSmallScreen ? 16 : 18,
            color: AppTheme.accentColor,
          ),
          const SizedBox(width: 8),
          Text(
            feature,
            style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
          ),
        ],
      ),
    );
  }
}

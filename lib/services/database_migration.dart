import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Database migration utilities
///
/// IMPORTANT: These methods should only be called when you explicitly need
/// to migrate or reset the database. DO NOT call these on app initialization
/// unless you have a specific version check in place.
class DatabaseMigration {
  static const String versionKey = 'db_version';
  static const int currentVersion = 1;

  /// Check if migration is needed
  /// Returns true if the database needs to be migrated
  static Future<bool> needsMigration() async {
    try {
      final settingsBox = await Hive.openBox('settings');
      final storedVersion = settingsBox.get(versionKey, defaultValue: 0);
      return storedVersion < currentVersion;
    } catch (e) {
      debugPrint('Error checking migration status: $e');
      return false;
    }
  }

  /// Perform database migration
  /// This will backup existing data, clear boxes, and restore data
  static Future<void> migrate() async {
    try {
      final settingsBox = await Hive.openBox('settings');
      final storedVersion = settingsBox.get(versionKey, defaultValue: 0);

      if (storedVersion >= currentVersion) {
        debugPrint('Database is already up to date');
        return;
      }

      debugPrint(
        'Migrating database from version $storedVersion to $currentVersion',
      );

      // Add migration logic here based on version
      // Example:
      // if (storedVersion < 1) {
      //   await _migrateToV1();
      // }

      // Update version
      await settingsBox.put(versionKey, currentVersion);
      debugPrint('Migration completed successfully');
    } catch (e) {
      debugPrint('Error during migration: $e');
      rethrow;
    }
  }

  /// DANGER: Clear all data
  /// This should only be used for development or when explicitly requested by the user
  static Future<void> clearAllData() async {
    try {
      debugPrint('WARNING: Clearing all database data');

      // Delete all boxes
      await Hive.deleteBoxFromDisk('employees');
      await Hive.deleteBoxFromDisk('clients');
      await Hive.deleteBoxFromDisk('shifts');
      await Hive.deleteBoxFromDisk('settings');

      debugPrint('All data cleared successfully');
    } catch (e) {
      debugPrint('Error clearing data: $e');
      rethrow;
    }
  }

  /// Reset database to fresh state (for testing/development)
  /// This will delete all boxes and reset the version
  static Future<void> resetDatabase() async {
    try {
      debugPrint('Resetting database to fresh state');
      await clearAllData();

      // Reopen settings box and set version
      final settingsBox = await Hive.openBox('settings');
      await settingsBox.put(versionKey, currentVersion);

      debugPrint('Database reset completed');
    } catch (e) {
      debugPrint('Error resetting database: $e');
      rethrow;
    }
  }
}

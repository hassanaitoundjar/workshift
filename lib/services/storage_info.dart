import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Utility class to get information about local storage
class StorageInfo {
  /// Get the path where Hive stores data on the device
  static Future<String> getStoragePath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      debugPrint('Error getting storage path: $e');
      return 'Unable to determine storage path';
    }
  }

  /// Get detailed storage information
  static Future<Map<String, dynamic>> getStorageDetails() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      // Get Hive box files
      final hiveFiles = <String, int>{};
      final dir = Directory(directory.path);

      if (await dir.exists()) {
        await for (var entity in dir.list()) {
          if (entity is File) {
            final fileName = entity.path.split('/').last;
            if (fileName.endsWith('.hive') || fileName.endsWith('.lock')) {
              final fileSize = await entity.length();
              hiveFiles[fileName] = fileSize;
            }
          }
        }
      }

      return {
        'storagePath': directory.path,
        'platform': Platform.operatingSystem,
        'hiveFiles': hiveFiles,
        'totalSize': hiveFiles.values.fold(0, (sum, size) => sum + size),
      };
    } catch (e) {
      debugPrint('Error getting storage details: $e');
      return {'error': e.toString()};
    }
  }

  /// Print storage information to console (for debugging)
  static Future<void> printStorageInfo() async {
    final info = await getStorageDetails();

    debugPrint('=== LOCAL STORAGE INFORMATION ===');
    debugPrint('Platform: ${info['platform']}');
    debugPrint('Storage Path: ${info['storagePath']}');
    debugPrint('');
    debugPrint('Hive Database Files:');

    if (info['hiveFiles'] != null) {
      final files = info['hiveFiles'] as Map<String, int>;
      if (files.isEmpty) {
        debugPrint('  No Hive files found');
      } else {
        files.forEach((fileName, size) {
          final sizeKB = (size / 1024).toStringAsFixed(2);
          debugPrint('  $fileName: $sizeKB KB');
        });
      }

      final totalKB = (info['totalSize'] / 1024).toStringAsFixed(2);
      debugPrint('');
      debugPrint('Total Storage Used: $totalKB KB');
    }

    debugPrint('=================================');
  }

  /// Format bytes to human-readable size
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Check if data exists in local storage
  static Future<bool> hasLocalData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dir = Directory(directory.path);

      if (!await dir.exists()) return false;

      await for (var entity in dir.list()) {
        if (entity is File) {
          final fileName = entity.path.split('/').last;
          if (fileName.endsWith('.hive')) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error checking local data: $e');
      return false;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  final String version;
  final String buildNumber;
  final String downloadUrl;
  final bool forceUpdate;
  final String? releaseNotes;

  AppVersion({
    required this.version,
    required this.buildNumber,
    required this.downloadUrl,
    this.forceUpdate = false,
    this.releaseNotes,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      version: json['version'] ?? '1.0.0',
      buildNumber: json['buildNumber'] ?? '1',
      downloadUrl: json['downloadUrl'] ?? '',
      forceUpdate: json['forceUpdate'] ?? false,
      releaseNotes: json['releaseNotes'],
    );
  }
}

class UpdateChecker {
  // Version check URL - Can be hosted on:
  // - Firebase Hosting (recommended): https://your-project.web.app/version.json
  // - Netlify: https://your-site.netlify.app/version.json
  // - Vercel: https://your-site.vercel.app/version.json
  // - GitHub Raw: https://raw.githubusercontent.com/user/repo/main/version.json
  // - Your own server: https://yourdomain.com/version.json
  static const String versionCheckUrl = 
      'https://raw.githubusercontent.com/hassanaitoundjar/workshift/main/version.json';
  
  // To use Firebase Hosting (better option):
  // 1. Run: ./setup_firebase_hosting.sh
  // 2. Deploy: firebase deploy --only hosting
  // 3. Change URL to: 'https://your-project-id.web.app/version.json'

  /// Check if a new version is available
  static Future<AppVersion?> checkForUpdate() async {
    try {
      final response = await http.get(
        Uri.parse(versionCheckUrl),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return AppVersion.fromJson(jsonData);
      } else {
        // Log error for debugging (in production, you might want to use a logging service)
        print('Update check failed: HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Handle network errors
      print('Update check error: $e');
      return null;
    }
  }

  /// Get current app version
  static Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      return '1.0.0+1';
    }
  }

  /// Compare versions to check if update is needed
  static bool isUpdateAvailable(String currentVersion, String latestVersion) {
    try {
      // Remove build number for comparison (e.g., "1.0.0+1" -> "1.0.0")
      final current = currentVersion.split('+')[0];
      final latest = latestVersion.split('+')[0];

      final currentParts = current.split('.').map(int.parse).toList();
      final latestParts = latest.split('.').map(int.parse).toList();

      // Ensure both have 3 parts (major.minor.patch)
      while (currentParts.length < 3) currentParts.add(0);
      while (latestParts.length < 3) latestParts.add(0);

      // Compare version numbers
      for (int i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) {
          return true;
        } else if (latestParts[i] < currentParts[i]) {
          return false;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}


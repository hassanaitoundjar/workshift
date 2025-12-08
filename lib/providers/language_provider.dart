import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      if (languageCode != null) {
        _locale = Locale(languageCode);
        notifyListeners();
      }
    } catch (e) {
      // Use default locale if loading fails
      _locale = const Locale('en');
    }
  }

  Future<void> setLanguage(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  bool get isEnglish => _locale.languageCode == 'en';
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isFrench => _locale.languageCode == 'fr';
}


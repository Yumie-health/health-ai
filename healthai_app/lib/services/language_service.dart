import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'app_language';

  // Load saved language from SharedPreferences
  static Future<String> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? '';
    } catch (e) {
      return '';
    }
  }

  // Save language to SharedPreferences
  static Future<void> saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      // Handle error silently
    }
  }

  // Detect device language
  static String getDeviceLanguage() {
    try {
      final deviceLocale = Platform.localeName;
      if (deviceLocale.startsWith('ar')) return 'ar';
      if (deviceLocale.startsWith('es')) return 'es';
      return 'en'; // Default to English
    } catch (e) {
      return 'en';
    }
  }
}

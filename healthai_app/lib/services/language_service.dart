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
      if (deviceLocale.startsWith('hi')) return 'hi';
      if (deviceLocale.startsWith('de')) return 'de';
      if (deviceLocale.startsWith('fr')) return 'fr';
      if (deviceLocale.startsWith('it')) return 'it';
      if (deviceLocale.startsWith('ja')) return 'ja';
      if (deviceLocale.startsWith('ko')) return 'ko';
      if (deviceLocale.startsWith('nl')) return 'nl';
      if (deviceLocale.startsWith('pt')) return 'pt';
      if (deviceLocale.startsWith('ru')) return 'ru';
      if (deviceLocale.startsWith('tr')) return 'tr';
      return 'en'; // Default to English
    } catch (e) {
      return 'en';
    }
  }
}

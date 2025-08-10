import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/language_service.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  bool _isInitialized = false;

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;
  bool get isInitialized => _isInitialized;

  // Initialize language on app start
  Future<void> initialize() async {
    try {
      // First check if user has saved a language preference
      final savedLanguage = await LanguageService.loadLanguage();
      
      if (savedLanguage.isNotEmpty) {
        _currentLocale = Locale(savedLanguage);
      } else {
        // If no saved preference, try to detect device language
        final deviceLanguage = LanguageService.getDeviceLanguage();
        _currentLocale = Locale(deviceLanguage);
        
        // Save the detected language as user preference
        await LanguageService.saveLanguage(deviceLanguage);
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // If anything fails, default to English
      _currentLocale = const Locale('en');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Change language and save preference
  Future<void> changeLanguage(String languageCode) async {
    try {
      _currentLocale = Locale(languageCode);
      await LanguageService.saveLanguage(languageCode);
      notifyListeners();
    } catch (e) {
      // Handle error - keep current language
    }
  }

  // Get all supported languages with their native names and flags
  List<Map<String, String>> getAllSupportedLanguages() {
    return [
      {
        'code': 'en',
        'name': 'English',
        'nativeName': 'English',
        'flag': '🇺🇸',
      },
      {
        'code': 'ar',
        'name': 'Arabic',
        'nativeName': 'العربية',
        'flag': '🇸🇦',
      },
      {
        'code': 'hi',
        'name': 'Hindi',
        'nativeName': 'हिन्दी',
        'flag': '🇮🇳',
      },
      {
        'code': 'de',
        'name': 'German',
        'nativeName': 'Deutsch',
        'flag': '🇩🇪',
      },
      {
        'code': 'es',
        'name': 'Spanish',
        'nativeName': 'Español',
        'flag': '🇪🇸',
      },
      {
        'code': 'fr',
        'name': 'French',
        'nativeName': 'Français',
        'flag': '🇫🇷',
      },
      {
        'code': 'it',
        'name': 'Italian',
        'nativeName': 'Italiano',
        'flag': '🇮🇹',
      },
      {
        'code': 'ja',
        'name': 'Japanese',
        'nativeName': '日本語',
        'flag': '🇯🇵',
      },
      {
        'code': 'ko',
        'name': 'Korean',
        'nativeName': '한국어',
        'flag': '🇰🇷',
      },
      {
        'code': 'nl',
        'name': 'Dutch',
        'nativeName': 'Nederlands',
        'flag': '🇳🇱',
      },
      {
        'code': 'pt',
        'name': 'Portuguese',
        'nativeName': 'Português',
        'flag': '🇵🇹',
      },
      {
        'code': 'ru',
        'name': 'Russian',
        'nativeName': 'Русский',
        'flag': '🇷🇺',
      },
      {
        'code': 'tr',
        'name': 'Turkish',
        'nativeName': 'Türkçe',
        'flag': '🇹🇷',
      },
    ];
  }
}

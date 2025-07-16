import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class PexelsService {
  static final PexelsService _instance = PexelsService._internal();
  factory PexelsService() => _instance;
  PexelsService._internal();

  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  static const String _placeholderUrl = 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80';

  // In-memory cache for meal name to image URL
  final Map<String, String> _imageCache = {};
  // In-memory cache for translations
  final Map<String, String> _translationCache = {};

  /// Helper to translate a query to English if needed (LibreTranslate API)
  Future<String> _translateToEnglish(String query, Locale? locale) async {
    if (locale == null || locale.languageCode == 'en') return query;
    final cacheKey = '${query}_${locale.languageCode}_en';
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }
    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': query,
          'source': locale.languageCode,
          'target': 'en',
          'format': 'text',
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translated = data['translatedText'] as String?;
        if (translated != null && translated.isNotEmpty) {
          _translationCache[cacheKey] = translated;
          return translated;
        }
      }
    } catch (e) {
      // Handle error silently
    }
    return query; // fallback to original if translation fails
  }

  /// Advanced food-specific search queries optimized for logged meal names
  List<String> _buildFoodQueries(String baseQuery) {
    final queries = <String>[];
    final cleanQuery = baseQuery.toLowerCase().trim();
    
    // Primary: Exact food name with strong food context
    queries.add('$cleanQuery food dish meal');
    
    // Secondary: Food name with cooking context
    queries.add('$cleanQuery cooked prepared restaurant');
    
    // Tertiary: Food name with plating context
    queries.add('$cleanQuery plated served delicious');
    
    // Quaternary: Food name with photography context
    queries.add('$cleanQuery food photography high quality');
    
    // Quinary: Try with "meal" suffix for better food matching
    queries.add('$cleanQuery meal');
    
    // Senary: Try with "dish" suffix
    queries.add('$cleanQuery dish');
    
    // Septenary: Generic food search as last resort
    queries.add('$cleanQuery');
    
    // Octonary: If query has multiple words, try just the first word
    final words = cleanQuery.split(' ');
    if (words.length > 1) {
      queries.add('${words[0]} food dish meal');
      queries.add('${words[0]} meal');
    }
    
    return queries;
  }

  /// Checks if a meal name is gibberish or meaningless
  bool _isGibberishMealName(String mealName) {
    final cleanName = mealName.toLowerCase().trim();
    
    // Empty or very short names
    if (cleanName.isEmpty || cleanName.length < 2) return true;
    
    // Just numbers or symbols
    if (RegExp(r'^[0-9\s\-_\.]+$').hasMatch(cleanName)) return true;
    
    // Common gibberish patterns
    final gibberishPatterns = [
      'asdf', 'qwerty', 'test', 'abc', 'xyz', '123', 'aaa', 'bbb',
      'random', 'sample', 'example', 'demo', 'temp', 'tmp', 'dummy',
      'placeholder', 'unknown', 'n/a', 'na', 'none', 'null', 'empty',
      'test meal', 'sample food', 'example dish', 'demo meal',
    ];
    
    for (final pattern in gibberishPatterns) {
      if (cleanName.contains(pattern)) return true;
    }
    
    // Too many repeated characters (like "aaaaa")
    if (RegExp(r'(.)\1{3,}').hasMatch(cleanName)) return true;
    
    // No vowels (likely not a real word)
    if (!RegExp(r'[aeiou]').hasMatch(cleanName)) return true;
    
    return false;
  }

  /// Fetches a meal image URL from Pexels optimized for logged meal names.
  /// If the locale is not English, translates the query to English before searching.
  /// Returns a meal icon URL if not found or on error.
  Future<String?> fetchMealImage(String query, {Locale? locale}) async {
    final cacheKey = locale != null ? '${query}_${locale.languageCode}' : query;
    if (_imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey];
    }
    
    String searchQuery = query.trim();
    if (searchQuery.isEmpty) {
      _imageCache[cacheKey] = _placeholderUrl;
      return _placeholderUrl;
    }
    
    // Check if meal name is gibberish - use meal icon directly
    if (_isGibberishMealName(searchQuery)) {
      _imageCache[cacheKey] = _placeholderUrl;
      return _placeholderUrl;
    }
    
    // Translate if needed
    if (locale != null && locale.languageCode != 'en') {
      searchQuery = await _translateToEnglish(searchQuery, locale);
    }
    
    // Build multiple search strategies for logged meal names
    final searchQueries = _buildFoodQueries(searchQuery);
    
    // Try each search strategy until we find a good image
    for (final searchQuery in searchQueries) {
      try {
        final url = 'https://pexelsproxycallable-jlkcfxcyrq-uc.a.run.app';
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'query': searchQuery}),
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final photos = data['photos'] as List?;
          
          if (photos != null && photos.isNotEmpty) {
            // Try to find the best quality image
            String? bestImageUrl;
            
            for (final photo in photos) {
              final src = photo['src'] as Map<String, dynamic>?;
              if (src != null) {
                // Prefer medium size, fallback to large, then small
                bestImageUrl = src['medium'] ?? src['large'] ?? src['small'];
                if (bestImageUrl != null && bestImageUrl.isNotEmpty) {
                  break;
                }
              }
            }
            
            if (bestImageUrl != null && bestImageUrl.isNotEmpty) {
              _imageCache[cacheKey] = bestImageUrl;
              return bestImageUrl;
            }
          }
        }
      } catch (e) {
        // Continue to next search strategy
        continue;
      }
    }
    
    // If all strategies fail, use meal icon
    _imageCache[cacheKey] = _placeholderUrl;
    return _placeholderUrl;
  }

  // Static helper for backwards compatibility
  static Future<String?> staticFetchMealImage(String query, {Locale? locale}) {
    return PexelsService().fetchMealImage(query, locale: locale);
  }
}
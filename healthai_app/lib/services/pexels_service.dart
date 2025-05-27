import 'dart:convert';
import 'package:http/http.dart' as http;

class PexelsService {
  static const String _apiKey = 'UbGyuqFHEAVpQXNhB5w0EULIFgEYasDl9nmamS9kGiB89UiMNtx6KlWx';
  static const String _baseUrl = 'https://api.pexels.com/v1/search';
  static const String _placeholderUrl = 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80';

  // In-memory cache for meal name to image URL
  static final Map<String, String> _imageCache = {};

  /// Fetches a meal image URL from Pexels for the given query (meal name).
  /// Returns a placeholder image URL if not found or on error.
  static Future<String?> fetchMealImage(String query) async {
    if (_imageCache.containsKey(query)) {
      return _imageCache[query];
    }
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?query=${Uri.encodeComponent(query)}&per_page=1'),
        headers: {'Authorization': _apiKey},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final photos = data['photos'] as List?;
        if (photos != null && photos.isNotEmpty) {
          final url = photos[0]['src']?['medium'] as String?;
          if (url != null && url.isNotEmpty) {
            _imageCache[query] = url;
            return url;
          }
        }
      }
    } catch (e) {
      // Ignore and fall through to placeholder
    }
    _imageCache[query] = _placeholderUrl;
    return _placeholderUrl;
  }
} 
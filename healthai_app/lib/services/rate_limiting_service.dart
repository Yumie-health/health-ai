import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'logging_service.dart';

class RateLimitEntry {
  final DateTime timestamp;
  final String action;

  RateLimitEntry({required this.timestamp, required this.action});

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'action': action,
  };

  factory RateLimitEntry.fromJson(Map<String, dynamic> json) => RateLimitEntry(
    timestamp: DateTime.parse(json['timestamp']),
    action: json['action'],
  );
}

class RateLimitResult {
  final bool allowed;
  final String? message;
  final Duration? waitTime;

  RateLimitResult._({required this.allowed, this.message, this.waitTime});

  factory RateLimitResult.allowed() => RateLimitResult._(allowed: true);
  
  factory RateLimitResult.denied(String message, Duration waitTime) => 
      RateLimitResult._(allowed: false, message: message, waitTime: waitTime);
}

class RateLimitingService {
  static final RateLimitingService _instance = RateLimitingService._internal();
  factory RateLimitingService() => _instance;
  RateLimitingService._internal();

  final LoggingService _log = LoggingService();

  // Rate limit configurations
  static const Map<String, Map<String, dynamic>> _rateLimits = {
    'password_reset': {
      'max_attempts': 3,
      'window_minutes': 15, // 3 attempts per 15 minutes
      'cooldown_minutes': 60, // 1 hour cooldown after limit reached
    },
    'sign_in_attempt': {
      'max_attempts': 5,
      'window_minutes': 5, // 5 attempts per 5 minutes
      'cooldown_minutes': 15, // 15 minute cooldown
    },
    'sign_up_attempt': {
      'max_attempts': 3,
      'window_minutes': 10, // 3 attempts per 10 minutes
      'cooldown_minutes': 30, // 30 minute cooldown
    },
    'forgot_password_dialog': {
      'max_attempts': 5,
      'window_minutes': 30, // 5 attempts per 30 minutes
      'cooldown_minutes': 60, // 1 hour cooldown
    },
  };

  // Check if action is allowed
  Future<RateLimitResult> checkRateLimit(String action, {String? identifier}) async {
    try {
      final key = _getRateLimitKey(action, identifier);
      final config = _rateLimits[action];
      
      if (config == null) {
        // No rate limit configured for this action
        return RateLimitResult.allowed();
      }

      final maxAttempts = config['max_attempts'] as int;
      final windowMinutes = config['window_minutes'] as int;
      final cooldownMinutes = config['cooldown_minutes'] as int;

      final attempts = await _getRecentAttempts(key, windowMinutes);
      final now = DateTime.now();

      // Check if we're in a cooldown period
      final lastCooldownTime = await _getLastCooldownTime(key);
      if (lastCooldownTime != null) {
        final cooldownEnd = lastCooldownTime.add(Duration(minutes: cooldownMinutes));
        if (now.isBefore(cooldownEnd)) {
          final remainingTime = cooldownEnd.difference(now);
          return RateLimitResult.denied(
            'Too many requests. Please wait ${_formatDuration(remainingTime)} before trying again.',
            remainingTime,
          );
        } else {
          // Cooldown expired, clear it
          await _clearCooldown(key);
        }
      }

      // Check rate limit
      if (attempts.length >= maxAttempts) {
        // Rate limit exceeded, start cooldown
        await _setCooldown(key, now);
        final cooldownDuration = Duration(minutes: cooldownMinutes);
        
        _log.warning('Rate limit exceeded', {
          'action': action,
          'identifier': identifier,
          'attempts': attempts.length,
          'maxAttempts': maxAttempts,
          'cooldownMinutes': cooldownMinutes,
        });

        return RateLimitResult.denied(
          'Too many requests. Please wait ${_formatDuration(cooldownDuration)} before trying again.',
          cooldownDuration,
        );
      }

      return RateLimitResult.allowed();

    } catch (e) {
      _log.error('Error checking rate limit', e);
      // If there's an error, allow the action to prevent blocking legitimate users
      return RateLimitResult.allowed();
    }
  }

  // Record an attempt
  Future<void> recordAttempt(String action, {String? identifier}) async {
    try {
      final key = _getRateLimitKey(action, identifier);
      final entry = RateLimitEntry(timestamp: DateTime.now(), action: action);
      
      await _addAttempt(key, entry);
      
      _log.info('Rate limit attempt recorded', {
        'action': action,
        'identifier': identifier,
        'timestamp': entry.timestamp.toIso8601String(),
      });

    } catch (e) {
      _log.error('Error recording rate limit attempt', e);
    }
  }

  // Get rate limit key
  String _getRateLimitKey(String action, String? identifier) {
    return 'rate_limit_${action}_${identifier ?? 'global'}';
  }

  // Get recent attempts within the time window
  Future<List<RateLimitEntry>> _getRecentAttempts(String key, int windowMinutes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attemptsJson = prefs.getStringList('${key}_attempts') ?? [];
      
      final cutoffTime = DateTime.now().subtract(Duration(minutes: windowMinutes));
      
      final attempts = attemptsJson
          .map((json) => RateLimitEntry.fromJson(jsonDecode(json)))
          .where((entry) => entry.timestamp.isAfter(cutoffTime))
          .toList();

      // Clean up old attempts
      if (attempts.length != attemptsJson.length) {
        await _saveAttempts(key, attempts);
      }

      return attempts;
    } catch (e) {
      _log.error('Error getting recent attempts', e);
      return [];
    }
  }

  // Add an attempt
  Future<void> _addAttempt(String key, RateLimitEntry entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attemptsJson = prefs.getStringList('${key}_attempts') ?? [];
      
      attemptsJson.add(jsonEncode(entry.toJson()));
      await prefs.setStringList('${key}_attempts', attemptsJson);
    } catch (e) {
      _log.error('Error adding attempt', e);
    }
  }

  // Save attempts list
  Future<void> _saveAttempts(String key, List<RateLimitEntry> attempts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attemptsJson = attempts.map((entry) => jsonEncode(entry.toJson())).toList();
      await prefs.setStringList('${key}_attempts', attemptsJson);
    } catch (e) {
      _log.error('Error saving attempts', e);
    }
  }

  // Get last cooldown time
  Future<DateTime?> _getLastCooldownTime(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cooldownString = prefs.getString('${key}_cooldown');
      return cooldownString != null ? DateTime.parse(cooldownString) : null;
    } catch (e) {
      return null;
    }
  }

  // Set cooldown
  Future<void> _setCooldown(String key, DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${key}_cooldown', time.toIso8601String());
    } catch (e) {
      _log.error('Error setting cooldown', e);
    }
  }

  // Clear cooldown
  Future<void> _clearCooldown(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${key}_cooldown');
    } catch (e) {
      _log.error('Error clearing cooldown', e);
    }
  }

  // Format duration for user display
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${hours}h';
      }
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  // Clear all rate limit data (useful for logout)
  Future<void> clearAllRateLimitData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith('rate_limit_')) {
          await prefs.remove(key);
        }
      }
      
      _log.info('All rate limit data cleared');
    } catch (e) {
      _log.error('Error clearing rate limit data', e);
    }
  }

  // Get rate limit status for debugging
  Future<Map<String, dynamic>> getRateLimitStatus(String action, {String? identifier}) async {
    try {
      final key = _getRateLimitKey(action, identifier);
      final config = _rateLimits[action];
      
      if (config == null) {
        return {'action': action, 'status': 'no_limit_configured'};
      }

      final windowMinutes = config['window_minutes'] as int;
      final attempts = await _getRecentAttempts(key, windowMinutes);
      final lastCooldownTime = await _getLastCooldownTime(key);
      
      return {
        'action': action,
        'identifier': identifier,
        'max_attempts': config['max_attempts'],
        'window_minutes': windowMinutes,
        'current_attempts': attempts.length,
        'cooldown_active': lastCooldownTime != null,
        'last_cooldown': lastCooldownTime?.toIso8601String(),
        'recent_attempts': attempts.map((a) => a.toJson()).toList(),
      };
    } catch (e) {
      _log.error('Error getting rate limit status', e);
      return {'error': e.toString()};
    }
  }
}

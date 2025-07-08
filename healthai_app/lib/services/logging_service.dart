import 'package:logger/logger.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  late final Logger _logger;
  late final FirebaseAnalytics _analytics;

  void initialize() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
    _analytics = FirebaseAnalytics.instance;
  }

  // Info logging
  void info(String message, [Map<String, dynamic>? data]) {
    if (data != null) {
      _logger.i('$message - ${data.toString()}');
    } else {
      _logger.i(message);
    }
    if (data != null) {
      _analytics.logEvent(name: 'app_info', parameters: data);
    }
  }

  // Warning logging
  void warning(String message, [Map<String, dynamic>? data]) {
    if (data != null) {
      _logger.w('$message - ${data.toString()}');
    } else {
      _logger.w(message);
    }
    if (data != null) {
      _analytics.logEvent(name: 'app_warning', parameters: data);
    }
  }

  // Error logging
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'message': message,
        'error': error?.toString() ?? 'Unknown error',
      },
    );
  }

  // Debug logging (only in debug mode)
  void debug(String message, [Map<String, dynamic>? data]) {
    if (data != null) {
      _logger.d('$message - ${data.toString()}');
    } else {
      _logger.d(message);
    }
  }

  // User action logging
  void logUserAction(String action, [Map<String, dynamic>? parameters]) {
    if (parameters != null) {
      _logger.i('User Action: $action - ${parameters.toString()}');
    } else {
      _logger.i('User Action: $action');
    }
    _analytics.logEvent(
      name: 'user_action',
      parameters: {
        'action': action,
        ...?parameters,
      },
    );
  }

  // API call logging
  void logApiCall(String endpoint, {String? method, int? statusCode, String? error}) {
    final data = {
      'endpoint': endpoint,
      'method': method ?? 'GET',
      'status_code': statusCode,
      'error': error,
    };
    
    if (error != null) {
      _logger.e('API Error: $endpoint - ${data.toString()}');
      _analytics.logEvent(name: 'api_error', parameters: data);
    } else {
      _logger.i('API Call: $endpoint - ${data.toString()}');
      _analytics.logEvent(name: 'api_call', parameters: data);
    }
  }

  // Performance logging
  void logPerformance(String operation, Duration duration) {
    _logger.i('Performance: $operation took ${duration.inMilliseconds}ms');
    _analytics.logEvent(
      name: 'performance',
      parameters: {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
      },
    );
  }
}

// Global logger instance
final log = LoggingService(); 
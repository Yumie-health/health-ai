import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'logging_service.dart';
import '../l10n/app_localizations.dart';

class SecurityEvent {
  final String eventType;
  final DateTime timestamp;
  final String? userId;
  final String? email;
  final String deviceInfo;
  final String? location;
  final bool successful;
  final Map<String, dynamic> metadata;

  SecurityEvent({
    required this.eventType,
    required this.timestamp,
    this.userId,
    this.email,
    required this.deviceInfo,
    this.location,
    required this.successful,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'eventType': eventType,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'email': email,
      'deviceInfo': deviceInfo,
      'location': location,
      'successful': successful,
      'metadata': metadata,
    };
  }

  factory SecurityEvent.fromMap(Map<String, dynamic> map) {
    return SecurityEvent(
      eventType: map['eventType'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      userId: map['userId'],
      email: map['email'],
      deviceInfo: map['deviceInfo'] ?? '',
      location: map['location'],
      successful: map['successful'] ?? false,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
}

class SuspiciousActivityAlert {
  final String alertType;
  final String title;
  final String description;
  final DateTime timestamp;
  final List<SecurityEvent> relatedEvents;
  final String riskLevel; // low, medium, high, critical

  SuspiciousActivityAlert({
    required this.alertType,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.relatedEvents,
    required this.riskLevel,
  });
}

class SecurityMonitoringService {
  static final SecurityMonitoringService _instance = SecurityMonitoringService._internal();
  factory SecurityMonitoringService() => _instance;
  SecurityMonitoringService._internal();

  final LoggingService _log = LoggingService();
  String? _deviceId;
  String? _deviceInfo;

  // Suspicious activity thresholds
  static const int maxFailedSignInsPerHour = 5;
  static const int maxPasswordResetPerDay = 10;
  static const int suspiciousDeviceThreshold = 3; // Different devices in short time
  static const int unusualLocationThreshold = 2; // Different locations in short time

  // Initialize security monitoring
  Future<void> initialize() async {
    await _initializeDeviceInfo();
    await _cleanupOldEvents();
    _log.info('Security monitoring initialized');
  }

  // Initialize device information
  Future<void> _initializeDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final prefs = await SharedPreferences.getInstance();
      
      _deviceId = prefs.getString('device_security_id');

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceInfo = '${androidInfo.brand} ${androidInfo.model} (Android ${androidInfo.version.release})';
        
        if (_deviceId == null) {
          _deviceId = androidInfo.id;
          await prefs.setString('device_security_id', _deviceId!);
        }
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceInfo = '${iosInfo.name} ${iosInfo.model} (iOS ${iosInfo.systemVersion})';
        
        if (_deviceId == null) {
          _deviceId = iosInfo.identifierForVendor ?? 'unknown';
          await prefs.setString('device_security_id', _deviceId!);
        }
      } else {
        _deviceInfo = 'Unknown Device';
        _deviceId ??= 'unknown_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      _log.error('Error initializing device info', e);
      _deviceInfo = 'Unknown Device';
      _deviceId = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Record security event
  Future<void> recordSecurityEvent(
    String eventType, {
    String? userId,
    String? email,
    bool successful = true,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final event = SecurityEvent(
        eventType: eventType,
        timestamp: DateTime.now(),
        userId: userId,
        email: email,
        deviceInfo: _deviceInfo ?? 'Unknown Device',
        location: 'Unknown', // Could be enhanced with location services
        successful: successful,
        metadata: metadata ?? {},
      );

      // Store locally
      await _storeEventLocally(event);

      // Store in Firestore if user is authenticated
      if (userId != null) {
        await _storeEventInFirestore(event, userId);
      }

      // Check for suspicious patterns
      await _checkForSuspiciousActivity(event);

      _log.info('Security event recorded', {
        'eventType': eventType,
        'userId': userId,
        'email': email,
        'successful': successful,
      });

    } catch (e) {
      _log.error('Error recording security event', e);
    }
  }

  // Store event locally
  Future<void> _storeEventLocally(SecurityEvent event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getStringList('security_events') ?? [];
      
      eventsJson.add(jsonEncode(event.toMap()));
      
      // Keep only last 100 events locally
      if (eventsJson.length > 100) {
        eventsJson.removeRange(0, eventsJson.length - 100);
      }
      
      await prefs.setStringList('security_events', eventsJson);
    } catch (e) {
      _log.error('Error storing event locally', e);
    }
  }

  // Store event in Firestore
  Future<void> _storeEventInFirestore(SecurityEvent event, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('security_events')
          .add(event.toMap());
    } catch (e) {
      _log.error('Error storing event in Firestore', e);
    }
  }

  // Get recent local events
  Future<List<SecurityEvent>> _getRecentLocalEvents(int hours) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getStringList('security_events') ?? [];
      
      final cutoffTime = DateTime.now().subtract(Duration(hours: hours));
      
      return eventsJson
          .map((json) => SecurityEvent.fromMap(jsonDecode(json)))
          .where((event) => event.timestamp.isAfter(cutoffTime))
          .toList();
    } catch (e) {
      _log.error('Error getting recent local events', e);
      return [];
    }
  }

  // Check for suspicious activity patterns
  Future<void> _checkForSuspiciousActivity(SecurityEvent currentEvent) async {
    try {
      final alerts = <SuspiciousActivityAlert>[];

      // Check for multiple failed sign-ins
      if (currentEvent.eventType == 'sign_in_attempt' && !currentEvent.successful) {
        final recentEvents = await _getRecentLocalEvents(1);
        final failedSignIns = recentEvents
            .where((e) => e.eventType == 'sign_in_attempt' && !e.successful && e.email == currentEvent.email)
            .length;

        if (failedSignIns >= maxFailedSignInsPerHour) {
          alerts.add(SuspiciousActivityAlert(
            alertType: 'repeated_failed_signins',
            title: 'Multiple Failed Sign-in Attempts',
            description: 'Detected $failedSignIns failed sign-in attempts for ${currentEvent.email} in the last hour.',
            timestamp: DateTime.now(),
            relatedEvents: recentEvents.where((e) => e.email == currentEvent.email).toList(),
            riskLevel: failedSignIns > 10 ? 'high' : 'medium',
          ));
        }
      }

      // Check for unusual device activity
      if (currentEvent.eventType == 'sign_in_attempt' && currentEvent.successful) {
        final recentEvents = await _getRecentLocalEvents(24);
        final uniqueDevices = recentEvents
            .where((e) => e.eventType == 'sign_in_attempt' && e.successful && e.email == currentEvent.email)
            .map((e) => e.deviceInfo)
            .toSet();

        if (uniqueDevices.length >= suspiciousDeviceThreshold) {
          alerts.add(SuspiciousActivityAlert(
            alertType: 'multiple_devices',
            title: 'Multiple Device Sign-ins',
            description: 'Account accessed from ${uniqueDevices.length} different devices in the last 24 hours.',
            timestamp: DateTime.now(),
            relatedEvents: recentEvents.where((e) => e.email == currentEvent.email).toList(),
            riskLevel: uniqueDevices.length > 5 ? 'high' : 'medium',
          ));
        }
      }

      // Check for excessive password reset requests
      if (currentEvent.eventType == 'password_reset_request') {
        final recentEvents = await _getRecentLocalEvents(24);
        final passwordResets = recentEvents
            .where((e) => e.eventType == 'password_reset_request' && e.email == currentEvent.email)
            .length;

        if (passwordResets >= maxPasswordResetPerDay) {
          alerts.add(SuspiciousActivityAlert(
            alertType: 'excessive_password_resets',
            title: 'Excessive Password Reset Requests',
            description: 'Detected $passwordResets password reset requests for ${currentEvent.email} in the last 24 hours.',
            timestamp: DateTime.now(),
            relatedEvents: recentEvents.where((e) => e.email == currentEvent.email).toList(),
            riskLevel: passwordResets > 20 ? 'critical' : 'medium',
          ));
        }
      }

      // Process alerts
      for (final alert in alerts) {
        await _processSecurityAlert(alert);
      }

    } catch (e) {
      _log.error('Error checking for suspicious activity', e);
    }
  }

  // Process security alert
  Future<void> _processSecurityAlert(SuspiciousActivityAlert alert) async {
    try {
      _log.warning('Security alert triggered', {
        'alertType': alert.alertType,
        'riskLevel': alert.riskLevel,
        'title': alert.title,
        'description': alert.description,
      });

      // Store alert
      await _storeSecurityAlert(alert);

      // For high/critical risk alerts, consider additional actions
      if (alert.riskLevel == 'high' || alert.riskLevel == 'critical') {
        _log.error('High risk security alert', {
          'alertType': alert.alertType,
          'description': alert.description,
        });

        // Could implement additional security measures here:
        // - Send email notifications
        // - Temporarily lock account
        // - Force password reset
        // - Invalidate all sessions
      }

    } catch (e) {
      _log.error('Error processing security alert', e);
    }
  }

  // Store security alert
  Future<void> _storeSecurityAlert(SuspiciousActivityAlert alert) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('security_alerts')
            .add({
          'alertType': alert.alertType,
          'title': alert.title,
          'description': alert.description,
          'timestamp': alert.timestamp.toIso8601String(),
          'riskLevel': alert.riskLevel,
          'relatedEventsCount': alert.relatedEvents.length,
        });
      }

      // Also store locally
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = prefs.getStringList('security_alerts') ?? [];
      alertsJson.add(jsonEncode({
        'alertType': alert.alertType,
        'title': alert.title,
        'description': alert.description,
        'timestamp': alert.timestamp.toIso8601String(),
        'riskLevel': alert.riskLevel,
      }));

      // Keep only last 50 alerts locally
      if (alertsJson.length > 50) {
        alertsJson.removeRange(0, alertsJson.length - 50);
      }

      await prefs.setStringList('security_alerts', alertsJson);
    } catch (e) {
      _log.error('Error storing security alert', e);
    }
  }

  // Get recent security alerts
  Future<List<Map<String, dynamic>>> getRecentSecurityAlerts({int days = 7}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = prefs.getStringList('security_alerts') ?? [];
      
      final cutoffTime = DateTime.now().subtract(Duration(days: days));
      
      return alertsJson
          .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
          .where((alert) {
            final timestamp = DateTime.parse(alert['timestamp']);
            return timestamp.isAfter(cutoffTime);
          })
          .toList()
          ..sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
    } catch (e) {
      _log.error('Error getting recent security alerts', e);
      return [];
    }
  }

  // Show security alerts dialog
  Future<void> showSecurityAlertsDialog(BuildContext context) async {
    final alerts = await getRecentSecurityAlerts();
    
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => _SecurityAlertsDialog(alerts: alerts),
    );
  }

  // Clean up old events (older than 30 days)
  Future<void> _cleanupOldEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getStringList('security_events') ?? [];
      
      final cutoffTime = DateTime.now().subtract(Duration(days: 30));
      
      final recentEvents = eventsJson
          .map((json) => SecurityEvent.fromMap(jsonDecode(json)))
          .where((event) => event.timestamp.isAfter(cutoffTime))
          .map((event) => jsonEncode(event.toMap()))
          .toList();

      if (recentEvents.length != eventsJson.length) {
        await prefs.setStringList('security_events', recentEvents);
        _log.info('Cleaned up old security events', {
          'removed': eventsJson.length - recentEvents.length,
          'remaining': recentEvents.length,
        });
      }
    } catch (e) {
      _log.error('Error cleaning up old events', e);
    }
  }

  // Clear all security data (for logout)
  Future<void> clearSecurityData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('security_events');
      await prefs.remove('security_alerts');
      _log.info('Security data cleared');
    } catch (e) {
      _log.error('Error clearing security data', e);
    }
  }
}

// Security alerts dialog
class _SecurityAlertsDialog extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;

  const _SecurityAlertsDialog({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.security, color: Colors.orange),
          SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.securityAlerts),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (alerts.isEmpty)
              Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noSecurityAlertsFound,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      AppLocalizations.of(context)!.yourAccountLooksGood,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return _buildAlertCard(alert);
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.close),
        ),
      ],
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final riskLevel = alert['riskLevel'] ?? 'low';
    final timestamp = DateTime.parse(alert['timestamp']);
    
    Color getRiskColor() {
      switch (riskLevel) {
        case 'critical': return Colors.red;
        case 'high': return Colors.orange;
        case 'medium': return Colors.yellow[700]!;
        case 'low': return Colors.blue;
        default: return Colors.grey;
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getAlertIcon(alert['alertType']),
          color: getRiskColor(),
        ),
        title: Text(
          alert['title'] ?? 'Security Alert',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert['description'] ?? ''),
            SizedBox(height: 4),
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            riskLevel.toUpperCase(),
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
          backgroundColor: getRiskColor(),
        ),
      ),
    );
  }

  IconData _getAlertIcon(String? alertType) {
    switch (alertType) {
      case 'repeated_failed_signins': return Icons.login_outlined;
      case 'multiple_devices': return Icons.devices;
      case 'excessive_password_resets': return Icons.lock_reset;
      default: return Icons.warning;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

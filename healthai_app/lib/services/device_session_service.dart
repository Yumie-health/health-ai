import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logging_service.dart';
import 'auth_service.dart';
import '../l10n/app_localizations.dart';

class DeviceSessionInfo {
  final String deviceId;
  final String deviceName;
  final String platform;
  final DateTime lastActivity;
  final String location; // Could be IP-based or user-provided
  final bool isCurrentDevice;

  DeviceSessionInfo({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.lastActivity,
    required this.location,
    required this.isCurrentDevice,
  });

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'platform': platform,
      'lastActivity': lastActivity.toIso8601String(),
      'location': location,
    };
  }

  factory DeviceSessionInfo.fromMap(Map<String, dynamic> map, String currentDeviceId) {
    return DeviceSessionInfo(
      deviceId: map['deviceId'] ?? '',
      deviceName: map['deviceName'] ?? 'Unknown Device',
      platform: map['platform'] ?? 'Unknown',
      lastActivity: DateTime.parse(map['lastActivity'] ?? DateTime.now().toIso8601String()),
      location: map['location'] ?? 'Unknown',
      isCurrentDevice: map['deviceId'] == currentDeviceId,
    );
  }
}

class DeviceSessionService {
  static final DeviceSessionService _instance = DeviceSessionService._internal();
  factory DeviceSessionService() => _instance;
  DeviceSessionService._internal();

  static const int maxDeviceSessions = 5; // Maximum allowed concurrent sessions
  static const int sessionTimeoutDays = 30; // Sessions expire after 30 days
  
  final LoggingService _log = LoggingService();
  String? _currentDeviceId;
  String? _currentDeviceName;

  // Initialize device session tracking
  Future<void> initialize() async {
    await _generateDeviceInfo();
    await _updateCurrentSession();
    await _cleanupExpiredSessions();
    _log.info('Device session service initialized', {'deviceId': _currentDeviceId});
  }

  // Generate unique device identifier and name
  Future<void> _generateDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final prefs = await SharedPreferences.getInstance();
      
      // Try to get existing device ID first
      _currentDeviceId = prefs.getString('device_session_id');
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _currentDeviceName = '${androidInfo.brand} ${androidInfo.model}';
        
        // Generate device ID if not exists
        if (_currentDeviceId == null) {
          _currentDeviceId = '${androidInfo.id}_${DateTime.now().millisecondsSinceEpoch}';
          await prefs.setString('device_session_id', _currentDeviceId!);
        }
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _currentDeviceName = '${iosInfo.name} (${iosInfo.model})';
        
        // Generate device ID if not exists
        if (_currentDeviceId == null) {
          _currentDeviceId = '${iosInfo.identifierForVendor}_${DateTime.now().millisecondsSinceEpoch}';
          await prefs.setString('device_session_id', _currentDeviceId!);
        }
      } else {
        _currentDeviceName = 'Unknown Device';
        if (_currentDeviceId == null) {
          _currentDeviceId = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
          await prefs.setString('device_session_id', _currentDeviceId!);
        }
      }
    } catch (e) {
      _log.error('Error generating device info', e);
      _currentDeviceId = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
      _currentDeviceName = 'Unknown Device';
    }
  }

  // Update current session activity
  Future<void> _updateCurrentSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _currentDeviceId == null) return;

    try {
      final sessionData = DeviceSessionInfo(
        deviceId: _currentDeviceId!,
        deviceName: _currentDeviceName ?? 'Unknown Device',
        platform: Platform.operatingSystem,
        lastActivity: DateTime.now(),
        location: 'Unknown', // Could be enhanced with location services
        isCurrentDevice: true,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('device_sessions')
          .doc(_currentDeviceId)
          .set(sessionData.toMap(), SetOptions(merge: true));

      // Check for concurrent sessions and handle if needed
      await _checkConcurrentSessions();
      
    } catch (e) {
      _log.error('Error updating current session', e);
    }
  }

  // Check for too many concurrent sessions
  Future<void> _checkConcurrentSessions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final sessions = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('device_sessions')
          .orderBy('lastActivity', descending: true)
          .get();

      if (sessions.docs.length > maxDeviceSessions) {
        // Too many sessions - show warning
        _log.warning('Too many concurrent sessions detected', {
          'sessionCount': sessions.docs.length,
          'maxAllowed': maxDeviceSessions,
        });
      }
    } catch (e) {
      _log.error('Error checking concurrent sessions', e);
    }
  }

  // Clean up expired sessions
  Future<void> _cleanupExpiredSessions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: sessionTimeoutDays));
      final sessions = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('device_sessions')
          .where('lastActivity', isLessThan: cutoffDate.toIso8601String())
          .get();

      // Delete expired sessions
      for (final doc in sessions.docs) {
        await doc.reference.delete();
      }

      if (sessions.docs.isNotEmpty) {
        _log.info('Cleaned up expired sessions', {'count': sessions.docs.length});
      }
    } catch (e) {
      _log.error('Error cleaning up expired sessions', e);
    }
  }

  // Get all active sessions for current user
  Future<List<DeviceSessionInfo>> getActiveSessions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _currentDeviceId == null) return [];

    try {
      final sessions = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('device_sessions')
          .orderBy('lastActivity', descending: true)
          .get();

      return sessions.docs.map((doc) {
        return DeviceSessionInfo.fromMap(doc.data(), _currentDeviceId!);
      }).toList();
    } catch (e) {
      _log.error('Error getting active sessions', e);
      return [];
    }
  }

  // Revoke a specific session
  Future<void> revokeSession(String deviceId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('device_sessions')
          .doc(deviceId)
          .delete();

      _log.info('Session revoked', {'deviceId': deviceId});
    } catch (e) {
      _log.error('Error revoking session', e);
    }
  }

  // Revoke all other sessions (sign out other devices)
  Future<void> revokeAllOtherSessions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _currentDeviceId == null) return;

    try {
      final sessions = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('device_sessions')
          .get();

      int revokedCount = 0;
      for (final doc in sessions.docs) {
        if (doc.id != _currentDeviceId) {
          await doc.reference.delete();
          revokedCount++;
        }
      }

      _log.info('All other sessions revoked', {'count': revokedCount});
    } catch (e) {
      _log.error('Error revoking all other sessions', e);
    }
  }

  // Show session management dialog
  Future<void> showSessionManagementDialog(BuildContext context) async {
    final sessions = await getActiveSessions();
    
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => _SessionManagementDialog(
        sessions: sessions,
        onRevokeSession: revokeSession,
        onRevokeAllOthers: revokeAllOtherSessions,
      ),
    );
  }

  // Record activity (call this when user is active)
  Future<void> recordActivity() async {
    await _updateCurrentSession();
  }

  // Sign out from current device
  Future<void> signOutCurrentDevice() async {
    if (_currentDeviceId != null) {
      await revokeSession(_currentDeviceId!);
    }
    await AuthService().logout();
  }
}

// Session management dialog widget
class _SessionManagementDialog extends StatefulWidget {
  final List<DeviceSessionInfo> sessions;
  final Function(String) onRevokeSession;
  final VoidCallback onRevokeAllOthers;

  const _SessionManagementDialog({
    required this.sessions,
    required this.onRevokeSession,
    required this.onRevokeAllOthers,
  });

  @override
  State<_SessionManagementDialog> createState() => _SessionManagementDialogState();
}

class _SessionManagementDialogState extends State<_SessionManagementDialog> {
  List<DeviceSessionInfo> _sessions = [];

  @override
  void initState() {
    super.initState();
    _sessions = List.from(widget.sessions);
  }

  String _formatLastActivity(DateTime lastActivity) {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inMinutes < 1) {
      return 'Active now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.devices, color: Colors.blue),
          SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.activeSessions),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Manage your active sessions across different devices',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            if (_sessions.isEmpty)
              Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No active sessions found',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          _getDeviceIcon(session.platform),
                          color: session.isCurrentDevice ? Colors.green : Colors.grey,
                        ),
                        title: Text(
                          session.deviceName,
                          style: TextStyle(
                            fontWeight: session.isCurrentDevice ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${session.platform} • ${session.location}'),
                            Text(
                              _formatLastActivity(session.lastActivity),
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: session.isCurrentDevice
                            ? Chip(
                                label: Text(AppLocalizations.of(context)!.thisDevice, style: TextStyle(fontSize: 10)),
                                backgroundColor: Colors.green.withOpacity(0.1),
                                side: BorderSide(color: Colors.green.withOpacity(0.3)),
                              )
                            : IconButton(
                                icon: Icon(Icons.logout, color: Colors.red),
                                onPressed: () {
                                  widget.onRevokeSession(session.deviceId);
                                  setState(() {
                                    _sessions.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(AppLocalizations.of(context)!.sessionRevoked)),
                                  );
                                },
                              ),
                      ),
                    );
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
        if (_sessions.length > 1)
          ElevatedButton(
            onPressed: () {
              widget.onRevokeAllOthers();
              setState(() {
                _sessions.removeWhere((session) => !session.isCurrentDevice);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.allOtherSessionsSignedOut)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.signOutAllOthers, style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }

  IconData _getDeviceIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'windows':
        return Icons.desktop_windows;
      case 'macos':
        return Icons.laptop_mac;
      case 'linux':
        return Icons.laptop;
      default:
        return Icons.device_unknown;
    }
  }
}

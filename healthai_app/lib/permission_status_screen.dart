import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'services/permission_service.dart';
import 'utils/constants.dart';
import 'l10n/app_localizations.dart';

class PermissionStatusScreen extends StatefulWidget {
  @override
  _PermissionStatusScreenState createState() => _PermissionStatusScreenState();
}

class _PermissionStatusScreenState extends State<PermissionStatusScreen> {
  Map<ph.Permission, ph.PermissionStatus> _permissionStatuses = {};
  bool _isLoading = true;

  final List<ph.Permission> _permissions = [
    ph.Permission.camera,
    ph.Permission.photos,
    ph.Permission.notification,
  ];

  @override
  void initState() {
    super.initState();
    _loadPermissionStatuses();
  }

  Future<void> _loadPermissionStatuses() async {
    final statuses = await PermissionService.getPermissionStatuses();
    setState(() {
      _permissionStatuses = statuses;
      _isLoading = false;
    });
  }

  Future<void> _requestPermission(ph.Permission permission) async {
    final status = await PermissionService.requestPermission(permission);
    setState(() {
      _permissionStatuses[permission] = status;
    });
  }

  Future<void> _openAppSettings() async {
    await PermissionService.openAppSettings();
  }

  Color _getStatusColor(ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.granted:
        return kPrimaryGreen;
      case ph.PermissionStatus.denied:
        return Colors.orange;
      case ph.PermissionStatus.permanentlyDenied:
        return kWarningRed;
      case ph.PermissionStatus.restricted:
        return Colors.grey;
      case ph.PermissionStatus.limited:
        return Colors.blue;
      case ph.PermissionStatus.provisional:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appPermissions),
        backgroundColor: kPrimaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryGreen),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPermissionStatuses,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kPrimaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: kPrimaryGreen),
                            SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.permissionStatus,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryGreen,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.manageAppPermissions,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Permission List
                  ..._permissions.map((permission) {
                    final status = _permissionStatuses[permission] ?? ph.PermissionStatus.denied;
                    final isGranted = status.isGranted;
                    final isPermanentlyDenied = status.isPermanentlyDenied;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(status).withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    PermissionService.getPermissionIcon(permission),
                                    color: _getStatusColor(status),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        PermissionService.getPermissionName(permission, context),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _getPermissionDescription(permission),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    PermissionService.getPermissionStatusText(status),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _getStatusColor(status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (!isGranted) ...[
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  if (!isPermanentlyDenied)
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _requestPermission(permission),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: kPrimaryGreen,
                                          side: BorderSide(color: kPrimaryGreen),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(AppLocalizations.of(context)!.grantPermission),
                                      ),
                                    ),
                                  if (isPermanentlyDenied) ...[
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: _openAppSettings,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: kWarningRed,
                                          side: BorderSide(color: kWarningRed),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text('Open Settings'),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  // Footer
                  SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.help_outline, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              'Need Help?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'If permissions are permanently denied, you can enable them in your device settings.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _openAppSettings,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kPrimaryGreen,
                              side: BorderSide(color: kPrimaryGreen),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Open Device Settings'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _getPermissionDescription(ph.Permission permission) {
    switch (permission) {
      case ph.Permission.camera:
        return AppLocalizations.of(context)!.scanFoodItems;
      case ph.Permission.photos:
        return AppLocalizations.of(context)!.saveScannedImages;
      case ph.Permission.notification:
        return AppLocalizations.of(context)!.sendMealReminders;
      default:
        return 'App functionality';
    }
  }
}

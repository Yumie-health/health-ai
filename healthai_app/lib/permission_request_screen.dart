import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'services/permission_service.dart';
import 'utils/constants.dart';

class PermissionRequestScreen extends StatefulWidget {
  final VoidCallback onPermissionsComplete;
  
  const PermissionRequestScreen({
    Key? key,
    required this.onPermissionsComplete,
  }) : super(key: key);

  @override
  State<PermissionRequestScreen> createState() => _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  Map<ph.Permission, ph.PermissionStatus> _permissionStatuses = {};
  bool _isRequesting = false;
  int _currentStep = 0;
  
  final List<ph.Permission> _permissions = [
    ph.Permission.camera,
    ph.Permission.photos,
    ph.Permission.notification,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
    _loadPermissionStatuses();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPermissionStatuses() async {
    final statuses = await PermissionService.getPermissionStatuses();
    setState(() {
      _permissionStatuses = statuses;
    });
  }

  Future<void> _requestAllPermissions() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      final results = await PermissionService.requestPermissionsWithExplanation(context);
      setState(() {
        _permissionStatuses = results;
        _isRequesting = false;
      });
      
      // Show completion dialog
      _showCompletionDialog();
    } catch (e) {
      setState(() {
        _isRequesting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting permissions: $e')),
      );
    }
  }

  void _showCompletionDialog() {
    final grantedCount = _permissionStatuses.values
        .where((status) => status.isGranted)
        .length;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Permissions Complete!'),
        content: Text(
          grantedCount == _permissions.length
              ? 'All permissions granted! You\'re all set to use Yumie.'
              : '$grantedCount of ${_permissions.length} permissions granted. You can change permissions later in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onPermissionsComplete();
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Header
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: kPrimaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Icon(
                            Icons.security,
                            size: 60,
                            color: kPrimaryGreen,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome to Yumie!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'To provide you with the best experience, we need a few permissions.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Permission List
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _permissions.length,
                        itemBuilder: (context, index) {
                          final permission = _permissions[index];
                          final status = _permissionStatuses[permission] ?? ph.PermissionStatus.denied;
                          final isGranted = status.isGranted;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isGranted ? kPrimaryGreen.withOpacity(0.3) : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isGranted 
                                        ? kPrimaryGreen.withOpacity(0.1)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    PermissionService.getPermissionIcon(permission),
                                    color: isGranted ? kPrimaryGreen : Colors.grey[600],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        PermissionService.getPermissionName(permission),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
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
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isGranted 
                                        ? kPrimaryGreen.withOpacity(0.1)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    PermissionService.getPermissionStatusText(status),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isGranted ? kPrimaryGreen : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Action Buttons
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isRequesting ? null : _requestAllPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isRequesting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('Requesting Permissions...'),
                              ],
                            )
                          : Text(
                              'Grant Permissions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => widget.onPermissionsComplete(),
                    child: Text(
                      'Skip for Now',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getPermissionDescription(ph.Permission permission) {
    switch (permission) {
      case ph.Permission.camera:
        return 'Scan food items and take photos of meals';
      case ph.Permission.photos:
        return 'Save scanned images and select photos';
      case ph.Permission.notification:
        return 'Send meal reminders and health alerts';
      default:
        return 'App functionality';
    }
  }
}

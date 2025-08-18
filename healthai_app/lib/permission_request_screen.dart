import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
// removed unused SharedPreferences import to comply with iOS permissions flow
import 'services/permission_service.dart';
import 'utils/constants.dart';
import 'l10n/app_localizations.dart';

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
        SnackBar(content: Text('${AppLocalizations.of(context)!.errorRequestingPermissions}: $e')),
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
        title: Text(AppLocalizations.of(context)!.permissionsComplete),
        content: Text(
          grantedCount == _permissions.length
              ? AppLocalizations.of(context)!.allPermissionsGranted
              : '${grantedCount} of ${_permissions.length} permissions granted. You can change permissions later in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onPermissionsComplete();
            },
            child: Text(AppLocalizations.of(context)!.continueButton),
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
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Intro banner with image background explaining why we ask
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    'assets/food_app_image.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.60),
                                          Colors.black.withOpacity(0.35),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Why we ask for permissions',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          shadows: [Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0,1))],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'We use your camera to scan foods and barcodes, access photos when you upload images, and notifications to remind you to log meals and hydrate.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          height: 1.4,
                                          shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0,1))],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'On the next screen, you\'ll see the system prompts to grant access. You can change this anytime in Settings.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0,1))],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Header
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: kPrimaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.settings_applications,
                                  size: 30,
                                  color: kPrimaryGreen,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                AppLocalizations.of(context)!.welcomeToYumiePermissions,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context)!.provideBestExperience,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),

                          // Permission List (unboxed, scrollable page)
                          Column(
                            children: List.generate(_permissions.length, (index) {
                              final permission = _permissions[index];
                              final status = _permissionStatuses[permission] ?? ph.PermissionStatus.denied;
                              final isGranted = status.isGranted;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      PermissionService.getPermissionIcon(permission),
                                      color: isGranted ? kPrimaryGreen : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            PermissionService.getPermissionName(permission, context),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _getPermissionDescription(permission),
                                            style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            PermissionService.getPermissionStatusText(status, context),
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isGranted ? kPrimaryGreen : Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Footer with continue button
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
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
                              AppLocalizations.of(context)!.continueButton,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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

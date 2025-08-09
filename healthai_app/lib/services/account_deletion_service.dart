import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logging_service.dart';
import '../l10n/app_localizations.dart';

class AccountDeletionService {
  static final AccountDeletionService _instance = AccountDeletionService._internal();
  factory AccountDeletionService() => _instance;
  AccountDeletionService._internal();

  final LoggingService _log = LoggingService();

  // Show account deletion confirmation dialog
  Future<void> showAccountDeletionDialog(BuildContext context) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AccountDeletionDialog(),
    );

    if (shouldDelete == true) {
      await _performAccountDeletion(context);
    }
  }

  // Perform the actual account deletion
  Future<void> _performAccountDeletion(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DeletionProgressDialog(),
    );

    try {
      _log.info('Starting account deletion process', {'userId': user.uid});

      // Step 1: Delete user's Firestore data
      await _deleteFirestoreData(user.uid);

      // Step 2: Delete user's Storage files
      await _deleteStorageFiles(user.uid);

      // Step 3: Delete device sessions
      await _deleteDeviceSessions(user.uid);

      // Step 4: Clear local data
      await _clearLocalData();

      // Step 5: Delete Firebase Auth account
      await user.delete();

      _log.info('Account deletion completed successfully');

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show a success message first
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 64),
                SizedBox(height: 16),
                Text(
                  'Account Deleted Successfully',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'You will be redirected to the sign-in page',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close this dialog
                    
                    // Navigate to a redirect screen with a timer
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => _RedirectScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)!.continueButton),
                ),
              ],
            ),
          ),
        );
      }

    } catch (e) {
      _log.error('Account deletion failed', e);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.deletionFailed),
            content: Text(_getErrorMessage(e)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  // Delete all Firestore data for the user
  Future<void> _deleteFirestoreData(String userId) async {
    final batch = FirebaseFirestore.instance.batch();
    
    try {
      // Delete user document
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      batch.delete(userDoc);

      // Delete meals subcollection
      final mealsQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('meals')
          .get();
      
      for (final doc in mealsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete custom meals subcollection  
      final customMealsQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('custom_meals')
          .get();
      
      for (final doc in customMealsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete device sessions subcollection
      final sessionsQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('device_sessions')
          .get();
      
      for (final doc in sessionsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete any other user-related subcollections
      final subcollections = [
        'notifications',
        'preferences',
        'activity_log',
        'subscription_history',
      ];

      for (final subcollection in subcollections) {
        try {
          final query = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection(subcollection)
              .get();
          
          for (final doc in query.docs) {
            batch.delete(doc.reference);
          }
        } catch (e) {
          // Subcollection might not exist, continue
          _log.warning('Could not delete subcollection: $subcollection', {'error': e.toString()});
        }
      }

      await batch.commit();
      _log.info('Firestore data deleted successfully');

    } catch (e) {
      _log.error('Error deleting Firestore data', e);
      throw Exception('Failed to delete user data from database');
    }
  }

  // Delete all Storage files for the user
  Future<void> _deleteStorageFiles(String userId) async {
    try {
      final storage = FirebaseStorage.instance;
      
      // Delete user profile images
      try {
        await storage.ref('users/$userId/profile.jpg').delete();
      } catch (e) {
        // File might not exist
      }

      // Delete meal images
      try {
        final mealImagesRef = storage.ref('users/$userId/meals');
        final result = await mealImagesRef.listAll();
        
        for (final item in result.items) {
          await item.delete();
        }
      } catch (e) {
        // Directory might not exist
      }

      // Delete any other user files
      try {
        final userRef = storage.ref('users/$userId');
        final result = await userRef.listAll();
        
        for (final item in result.items) {
          await item.delete();
        }
        
        for (final folder in result.prefixes) {
          await _deleteStorageFolder(folder);
        }
      } catch (e) {
        // Directory might not exist
      }

      _log.info('Storage files deleted successfully');

    } catch (e) {
      _log.error('Error deleting storage files', e);
      // Don't throw here as this is not critical
    }
  }

  // Recursively delete storage folder
  Future<void> _deleteStorageFolder(Reference folderRef) async {
    try {
      final result = await folderRef.listAll();
      
      for (final item in result.items) {
        await item.delete();
      }
      
      for (final subfolder in result.prefixes) {
        await _deleteStorageFolder(subfolder);
      }
    } catch (e) {
      _log.warning('Error deleting storage folder: ${folderRef.fullPath}', {'error': e.toString()});
    }
  }

  // Delete device sessions
  Future<void> _deleteDeviceSessions(String userId) async {
    try {
      final sessions = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('device_sessions')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in sessions.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _log.info('Device sessions deleted successfully');
    } catch (e) {
      _log.error('Error deleting device sessions', e);
    }
  }

  // Clear all local data
  Future<void> _clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _log.info('Local data cleared successfully');
    } catch (e) {
      _log.error('Error clearing local data', e);
    }
  }

  // Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'requires-recent-login':
          return 'For security reasons, you need to sign in again before deleting your account. Please sign out and sign back in, then try again.';
        case 'user-not-found':
          return 'Account not found. It may have already been deleted.';
        default:
          return 'Authentication error: ${error.message ?? 'Unknown error'}';
      }
    }
    
    return 'An unexpected error occurred. Please try again later or contact support if the problem persists.';
  }
}

// Account deletion confirmation dialog
class _AccountDeletionDialog extends StatefulWidget {
  @override
  State<_AccountDeletionDialog> createState() => _AccountDeletionDialogState();
}

class _AccountDeletionDialogState extends State<_AccountDeletionDialog> {
  bool _confirmationChecked = false;
  final TextEditingController _confirmationController = TextEditingController();
  final String _confirmationText = 'DELETE';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.red, size: 28),
          SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.deleteAccountTitle),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.deleteAccountWarningTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.deleteAccountDataList,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            _buildDeletionItem(AppLocalizations.of(context)!.allMealLogsAndNutrition),
            _buildDeletionItem(AppLocalizations.of(context)!.profileAndPersonalInfo),
            _buildDeletionItem(AppLocalizations.of(context)!.allUploadedPhotos),
            _buildDeletionItem(AppLocalizations.of(context)!.customMealsAndRecipes),
            _buildDeletionItem(AppLocalizations.of(context)!.allAppPreferences),
            _buildDeletionItem(AppLocalizations.of(context)!.activeSessionsAllDevices),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange[700], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.exportDataWarning,
                      style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              value: _confirmationChecked,
              onChanged: (value) {
                setState(() {
                  _confirmationChecked = value ?? false;
                });
              },
              title: Text(
                AppLocalizations.of(context)!.understandActionPermanent,
                style: TextStyle(fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.typeDeleteToConfirm,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _confirmationController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.typeDeleteHere,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _canConfirmDeletion
              ? () => Navigator.pop(context, true)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(AppLocalizations.of(context)!.deleteForever),
        ),
      ],
    );
  }

  Widget _buildDeletionItem(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.remove, color: Colors.red, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  bool get _canConfirmDeletion {
    return _confirmationChecked && 
           _confirmationController.text.trim() == _confirmationText;
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }
}

// Progress dialog during deletion
class _DeletionProgressDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.deletingYourAccount,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.thisMayTakeAFewMoments,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// Simple redirect screen that shows success and redirects after a timer
class _RedirectScreen extends StatefulWidget {
  @override
  State<_RedirectScreen> createState() => _RedirectScreenState();
}

class _RedirectScreenState extends State<_RedirectScreen> {
  @override
  void initState() {
    super.initState();
    // Redirect after 2 seconds
    Timer(Duration(seconds: 2), () {
      if (mounted) {
        // Exit the app completely - user will need to restart to see sign-in
        // This is the cleanest approach since the Firebase user is already deleted
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => _ExitScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.accountDeleted,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.redirectingToSignIn,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// Exit screen that tells user to restart the app
class _ExitScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.accountSuccessfullyDeleted,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.pleaseCloseAndRestartApp,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Try to restart the app by clearing everything and going to root
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(AppLocalizations.of(context)!.restartApp),
            ),
          ],
        ),
      ),
    );
  }
}

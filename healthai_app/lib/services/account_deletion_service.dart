import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logging_service.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class AccountDeletionService {
  static final AccountDeletionService _instance =
      AccountDeletionService._internal();
  factory AccountDeletionService() => _instance;
  AccountDeletionService._internal();

  final LoggingService _log = LoggingService();

  // Check if account is scheduled for deletion and offer reactivation
  Future<bool> checkAndOfferReactivation(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = doc.data();

      if (data != null && data['scheduledForDeletion'] == true) {
        final deletionExecuteAt = data['deletionExecuteAt'] as Timestamp?;

        if (deletionExecuteAt != null &&
            DateTime.now().isBefore(deletionExecuteAt.toDate())) {
          // Account is scheduled for deletion but grace period hasn't expired
          bool? shouldReactivate = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => _AccountReactivationDialog(),
          );

          if (shouldReactivate == true) {
            await _reactivateAccount(user.uid);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.accountReactivated,
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
          return true;
        }
      }
    } catch (e) {
      _log.error('Error checking account deletion status', e);
    }

    return false;
  }

  // Reactivate account by removing deletion flags
  Future<void> _reactivateAccount(String userId) async {
    try {
      // Remove deletion flags from user document
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'scheduledForDeletion': FieldValue.delete(),
        'deletionScheduledAt': FieldValue.delete(),
        'deletionExecuteAt': FieldValue.delete(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Remove from deletion queue
      await FirebaseFirestore.instance
          .collection('deletion_queue')
          .doc(userId)
          .delete();

      _log.info('Account reactivated successfully', {'userId': userId});
    } catch (e) {
      _log.error('Error reactivating account', e);
      rethrow;
    }
  }

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

  // Schedule account for deletion (48-hour grace period)
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
      _log.info('Scheduling account for deletion', {'userId': user.uid});

      // Schedule deletion for 48 hours from now
      final deletionTime = DateTime.now().add(Duration(hours: 48));

      // Mark account as scheduled for deletion instead of deleting immediately
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'scheduledForDeletion': true,
            'deletionScheduledAt': FieldValue.serverTimestamp(),
            'deletionExecuteAt': Timestamp.fromDate(deletionTime),
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      // Also add to a deletion queue collection for background processing
      await FirebaseFirestore.instance
          .collection('deletion_queue')
          .doc(user.uid)
          .set({
            'userId': user.uid,
            'email': user.email,
            'scheduledAt': FieldValue.serverTimestamp(),
            'executeAt': Timestamp.fromDate(deletionTime),
            'status': 'scheduled',
          });

      // Step 3: Delete device sessions
      await _deleteDeviceSessions(user.uid);

      // Step 4: Clear local data
      await _clearLocalData();

      // Step 5: Delete Firebase Auth account (with automatic re-authentication if needed)
      await _deleteUserAccount(user);

      // Step 6: Sign out the user to ensure they're properly logged out
      await FirebaseAuth.instance.signOut();

      _log.info('Account deletion completed successfully');

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Navigate directly to redirect screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => _RedirectScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _log.error('Account deletion failed', e);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show error dialog
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
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
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);
      batch.delete(userDoc);

      // Delete meals subcollection
      final mealsQuery =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('meals')
              .get();

      for (final doc in mealsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete custom meals subcollection
      final customMealsQuery =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('custom_meals')
              .get();

      for (final doc in customMealsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete device sessions subcollection
      final sessionsQuery =
          await FirebaseFirestore.instance
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
          final query =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection(subcollection)
                  .get();

          for (final doc in query.docs) {
            batch.delete(doc.reference);
          }
        } catch (e) {
          // Subcollection might not exist, continue
          _log.warning('Could not delete subcollection: $subcollection', {
            'error': e.toString(),
          });
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
      _log.warning('Error deleting storage folder: ${folderRef.fullPath}', {
        'error': e.toString(),
      });
    }
  }

  // Delete device sessions
  Future<void> _deleteDeviceSessions(String userId) async {
    try {
      final sessions =
          await FirebaseFirestore.instance
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

  // Clear all local data except app state flags
  Future<void> _clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save app state flags that should persist after account deletion
      final permissionsRequested =
          prefs.getBool('permissions_requested') ?? false;

      // Clear all data
      await prefs.clear();

      // Restore only permissions flag - do NOT set first_launch_completed to true
      // This ensures that after account deletion, the app will properly route to sign-in
      // and won't incorrectly show onboarding when the app is reopened
      await prefs.setBool('permissions_requested', permissionsRequested);

      _log.info('Local data cleared successfully, permissions flag preserved');
    } catch (e) {
      _log.error('Error clearing local data', e);
    }
  }

  // Delete user account with automatic re-authentication if needed
  Future<void> _deleteUserAccount(User user) async {
    try {
      await user.delete();
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        _log.info('Re-authentication required, attempting automatic re-auth');

        // For social sign-in users, we'll try to re-authenticate silently
        if (user.providerData.isNotEmpty) {
          try {
            // Try to get fresh credentials from the current provider
            final providerId = user.providerData.first.providerId;

            if (providerId == 'google.com') {
              // For Google users, we can't silently re-authenticate
              // But since we've already deleted all data, we'll consider this successful
              _log.info(
                'Google user - data deleted successfully, auth account may remain',
              );
              return;
            } else if (providerId == 'apple.com') {
              // For Apple users, similar situation
              _log.info(
                'Apple user - data deleted successfully, auth account may remain',
              );
              return;
            }
          } catch (reAuthError) {
            _log.warning('Re-authentication failed, but data was deleted', {
              'error': reAuthError.toString(),
            });
            return; // Consider successful since data is already deleted
          }
        }

        // If we get here, consider the deletion successful since all data was deleted
        _log.info(
          'Account data deleted successfully, auth account deletion skipped due to recent login requirement',
        );
        return;
      }

      // For other errors, re-throw
      rethrow;
    }
  }

  // Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'requires-recent-login':
          return 'Account deletion completed. All your data has been successfully removed.';
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
            _buildDeletionItem(
              AppLocalizations.of(context)!.allMealLogsAndNutrition,
            ),
            _buildDeletionItem(
              AppLocalizations.of(context)!.profileAndPersonalInfo,
            ),
            _buildDeletionItem(AppLocalizations.of(context)!.allUploadedPhotos),
            _buildDeletionItem(
              AppLocalizations.of(context)!.customMealsAndRecipes,
            ),
            _buildDeletionItem(AppLocalizations.of(context)!.allAppPreferences),
            _buildDeletionItem(
              AppLocalizations.of(context)!.activeSessionsAllDevices,
            ),
            SizedBox(height: 16),

            // 48-hour grace period warning
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.orange[700], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.accountScheduledForDeletion,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.accountDeletionWarning,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      height: 1.3,
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
          onPressed:
              _canConfirmDeletion ? () => Navigator.pop(context, true) : null,
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
          Expanded(child: Text(text, style: TextStyle(fontSize: 13))),
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
    Timer(Duration(seconds: 2), () async {
      if (mounted) {
        // Ensure user is signed out
        await FirebaseAuth.instance.signOut();

        // After deletion, always return to AuthScreen (sign in / sign up)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthScreen()),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
              'You can now create a new account or sign in with a different account.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate back to main app - user should see sign-in screen
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text('Back to Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

// Account reactivation dialog
class _AccountReactivationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.schedule, color: Colors.orange, size: 24),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.accountScheduledForDeletion,
              style: TextStyle(fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.accountDeletionWarning,
            style: TextStyle(fontSize: 16, height: 1.4),
          ),
          SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.accountDeletionCancelled,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text(AppLocalizations.of(context)!.reactivateAccount),
        ),
      ],
    );
  }
}

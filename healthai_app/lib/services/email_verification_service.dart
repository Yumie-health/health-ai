import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';

class EmailVerificationService {
  static final EmailVerificationService _instance = EmailVerificationService._internal();
  factory EmailVerificationService() => _instance;
  EmailVerificationService._internal();

  // Show email verification dialog and handle the verification flow
  Future<bool> showEmailVerificationDialog(BuildContext context, User user) async {
    // Force reload user to get latest verification status
    await user.reload();
    final currentUser = FirebaseAuth.instance.currentUser;
    
    // If already verified (Google accounts are often pre-verified), skip dialog
    if (currentUser != null && currentUser.emailVerified) {
      return true;
    }
    
    // Check if verification email was already sent for this email
    final prefs = await SharedPreferences.getInstance();
    final lastSentKey = 'verification_sent_${user.email}';
    final lastSentTime = prefs.getInt(lastSentKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const fiveMinutes = 5 * 60 * 1000;
    
    bool alreadySent = (now - lastSentTime) < fiveMinutes;
    
    if (!alreadySent) {
      // Send verification email
      try {
        await user.sendEmailVerification();
        await prefs.setInt(lastSentKey, now);
        alreadySent = false;
      } catch (e) {
        // Handle error
        if (context.mounted) {
          // Use a try-catch to handle cases where there's no Scaffold in the widget tree
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${AppLocalizations.of(context)!.failedToSendVerificationEmail}: $e'),
                backgroundColor: Colors.red,
              ),
            );
          } catch (_) {
            // Ignore if no Scaffold is available
          }
        }
        return false;
      }
    }

    // Show verification dialog
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EmailVerificationDialog(
        user: user,
        alreadySent: alreadySent,
      ),
    );

    return result ?? false;
  }

  // Check if user needs email verification on app start
  Future<bool> checkVerificationOnStartup(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // Skip verification for review team accounts
    final reviewAccounts = ['apple@applereview.com', 'google.develop@gmail.com'];
    if (user.email != null && reviewAccounts.contains(user.email!.toLowerCase())) {
      return false; // Skip verification for review accounts
    }

    // Skip verification for Apple and Google sign-in (trusted providers)
    final providerData = user.providerData;
    final isAppleUser = providerData.any((provider) => provider.providerId == 'apple.com');
    final isGoogleUser = providerData.any((provider) => provider.providerId == 'google.com');
    if (isAppleUser || isGoogleUser) return false;

    // Check if email is verified
    await user.reload(); // Refresh user data
    if (!user.emailVerified) {
      // Show verification dialog
      return await showEmailVerificationDialog(context, user);
    }

    return false; // Email is verified, no dialog needed
  }
}

// Email verification dialog
class _EmailVerificationDialog extends StatefulWidget {
  final User user;
  final bool alreadySent;

  const _EmailVerificationDialog({
    Key? key,
    required this.user,
    required this.alreadySent,
  }) : super(key: key);

  @override
  State<_EmailVerificationDialog> createState() => _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<_EmailVerificationDialog> {
  bool isWaiting = false;
  bool canResend = false;
  Timer? _checkTimer;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    if (!widget.alreadySent) {
      _startWaiting();
    } else {
      _startResendTimer();
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startWaiting() {
    setState(() {
      isWaiting = true;
    });

    // Check verification status every 2 seconds
    _checkTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      try {
        // Force reload user data from Firebase
        await widget.user.reload();
        final currentUser = FirebaseAuth.instance.currentUser;
        
        if (currentUser != null && currentUser.emailVerified) {
          timer.cancel();
          if (mounted) {
            // Show success message briefly
            try {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.emailVerified),
                  backgroundColor: kPrimaryGreen,
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (_) {
              // Ignore if no Scaffold is available
            }
            Navigator.of(context).pop(true); // Email verified
          }
        }
      } catch (e) {
        // Handle reload errors gracefully
        print('Error checking verification status: $e');
      }
    });

    // Allow resend after 1 minute
    _resendTimer = Timer(Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          canResend = true;
        });
      }
    });
  }

  void _startResendTimer() {
    // Allow resend after 1 minute for already sent emails
    _resendTimer = Timer(Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          canResend = true;
        });
      }
    });
  }

  Future<void> _resendVerification() async {
    try {
      await widget.user.sendEmailVerification();
      
      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('verification_sent_${widget.user.email}', DateTime.now().millisecondsSinceEpoch);
      
      setState(() {
        canResend = false;
      });
      
      _startWaiting();
      
      if (mounted) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.verificationEmailSent),
              backgroundColor: kPrimaryGreen,
            ),
          );
        } catch (_) {
          // Ignore if no Scaffold is available
        }
      }
    } catch (e) {
      if (mounted) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.failedToResendVerificationEmail),
              backgroundColor: Colors.red,
            ),
          );
        } catch (_) {
          // Ignore if no Scaffold is available
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button dismissal
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.email, color: kPrimaryGreen, size: 28),
            SizedBox(width: 8),
            Expanded(child: Text(AppLocalizations.of(context)!.emailVerificationRequired)),
            IconButton(
              icon: Icon(Icons.close, color: Colors.grey[600]),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.pleaseVerifyEmail,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            if (widget.alreadySent) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[700], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.verificationLinkAlreadySent,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ] else ...[
              Text(
                AppLocalizations.of(context)!.verificationEmailSent,
                style: TextStyle(fontSize: 14, height: 1.4),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
            ],
            if (isWaiting) ...[
              CircularProgressIndicator(color: kPrimaryGreen),
              SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.waitingForVerification,
                style: TextStyle(
                  fontSize: 14,
                  color: kPrimaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.checkYourEmail,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          if (canResend)
            TextButton(
              onPressed: _resendVerification,
              child: Text(
                AppLocalizations.of(context)!.resendVerificationEmail,
                style: TextStyle(color: kPrimaryGreen),
              ),
            ),
          if (!isWaiting)
            ElevatedButton(
              onPressed: () async {
                try {
                  // Force reload and check verification
                  await widget.user.reload();
                  final currentUser = FirebaseAuth.instance.currentUser;
                  
                  if (currentUser != null && currentUser.emailVerified) {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.emailVerified),
                          backgroundColor: kPrimaryGreen,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (_) {
                      // Ignore if no Scaffold is available
                    }
                    Navigator.of(context).pop(true);
                  } else {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.emailNotVerified),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (_) {
                      // Ignore if no Scaffold is available
                    }
                    _startWaiting();
                  }
                } catch (e) {
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${AppLocalizations.of(context)!.errorCheckingVerification}: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } catch (_) {
                    // Ignore if no Scaffold is available
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.continueToApp),
            ),
        ],
      ),
    );
  }
}
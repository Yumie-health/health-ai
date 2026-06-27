import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import '../utils/constants.dart';
import 'dialog_coordinator.dart';
import '../l10n/app_localizations.dart';

class BirthdayService {
  static final BirthdayService _instance = BirthdayService._internal();
  factory BirthdayService() => _instance;
  BirthdayService._internal();

  // Check if it's user's birthday and show celebration
  Future<void> checkAndCelebrateBirthday(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = doc.data();

      if (data != null &&
          data['birthMonth'] != null &&
          data['birthDay'] != null) {
        final int birthMonth = data['birthMonth'];
        final int birthDay = data['birthDay'];
        final int storedAge = data['age'] ?? 18;
        final int? lastCelebrationYear = data['lastBirthdayCelebrationYear'];

        final now = DateTime.now();
        final isBirthday = (now.month == birthMonth && now.day == birthDay);

        if (isBirthday) {
          // Check if we already celebrated this year (using Firestore, not SharedPreferences)
          if (lastCelebrationYear != now.year) {
            // Check if user signed up today (on their birthday)
            final createdAt = data['createdAt'] as Timestamp?;
            final isSignupDay =
                createdAt != null &&
                createdAt.toDate().year == now.year &&
                createdAt.toDate().month == now.month &&
                createdAt.toDate().day == now.day;

            // Calculate correct age to display
            int displayAge = storedAge;
            if (!isSignupDay) {
              // Only increment age if it's not the signup day
              displayAge = storedAge + 1;
            }

            // Show birthday celebration
            await _showBirthdayDialog(context, displayAge);

            // Update Firestore with the celebration year and potentially new age
            final updateData = {
              'lastBirthdayCelebrationYear': now.year,
              'lastUpdated': FieldValue.serverTimestamp(),
            };

            // Only update age if it's not the signup day
            if (!isSignupDay) {
              updateData['age'] = displayAge;
            }

            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update(updateData);
          }
        }
      }
    } catch (e) {
      print('Error checking birthday: $e');
    }
  }

  Future<void> _showBirthdayDialog(BuildContext context, int newAge) async {
    await DialogCoordinator.instance.showExclusiveDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BirthdayDialog(newAge: newAge),
    );
  }
}

class _BirthdayDialog extends StatefulWidget {
  final int newAge;

  const _BirthdayDialog({Key? key, required this.newAge}) : super(key: key);

  @override
  State<_BirthdayDialog> createState() => _BirthdayDialogState();
}

class _BirthdayDialogState extends State<_BirthdayDialog>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(duration: Duration(seconds: 3));
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _scaleController.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14 / 2, // Down
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            maxBlastForce: 100,
            minBlastForce: 80,
            gravity: 0.3,
          ),
        ),
        // Dialog
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange[50]!, Colors.pink[50]!],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Birthday emoji
                  Text('🎂', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  // Happy birthday title
                  Text(
                    AppLocalizations.of(context)!.happyBirthday,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  // Birthday message
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.birthdayMessage(widget.newAge),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.continueButton,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

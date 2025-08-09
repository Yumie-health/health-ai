import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'improved_height_selector.dart';

class ImprovedHeightStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final bool useMetric;
  final double? heightCm;
  final int heightFeet;
  final int heightInches;
  final void Function(bool) onUnitToggle;
  final void Function(double) onSelectCm;
  final void Function(int, int) onSelectFtIn;
  final VoidCallback? onContinue;
  final VoidCallback onBack;

  const ImprovedHeightStep({
    Key? key,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.useMetric,
    required this.heightCm,
    required this.heightFeet,
    required this.heightInches,
    required this.onUnitToggle,
    required this.onSelectCm,
    required this.onSelectFtIn,
    required this.onContinue,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 28),
              onPressed: onBack,
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ),
        ),
        
        SizedBox(height: 32),
        
        // Title with animation
        FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.yourHeight,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.helpUsCalculateYourHealthGoals,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 48),
        
        // Height selector with animation
        FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: ImprovedHeightSelector(
              useMetric: useMetric,
              heightCm: heightCm,
              heightFeet: heightFeet,
              heightInches: heightInches,
              onUnitToggle: onUnitToggle,
              onSelectCm: onSelectCm,
              onSelectFtIn: onSelectFtIn,
            ),
          ),
        ),
        
        Spacer(),
        
        // Continue button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Text(AppLocalizations.of(context)!.continueButton),
          ),
        ),
      ],
    );
  }
}

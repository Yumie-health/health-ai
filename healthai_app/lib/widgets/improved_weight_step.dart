import 'package:flutter/material.dart';
import 'improved_weight_selector.dart';
import '../l10n/app_localizations.dart';

class ImprovedWeightStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final bool useMetric;
  final double? weightKg;
  final double weightLb;
  final void Function(bool) onUnitToggle;
  final void Function(double) onSelectKg;
  final void Function(double) onSelectLb;
  final VoidCallback? onContinue;
  final VoidCallback onBack;
  final bool isSmallScreen;

  const ImprovedWeightStep({
    Key? key,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.useMetric,
    required this.weightKg,
    required this.weightLb,
    required this.onUnitToggle,
    required this.onSelectKg,
    required this.onSelectLb,
    required this.onContinue,
    required this.onBack,
    required this.isSmallScreen,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700 || screenWidth < 400;
    
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
        
        SizedBox(height: isSmallScreen ? 16 : 32),
        
        // Title with animation
        FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.yourCurrentWeight,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 24 : 32,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.thisHelpsUsTrackYourProgress,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 20 : 40),
        
        // Weight selector with animation
        FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: ImprovedWeightSelector(
              useMetric: useMetric,
              weightKg: weightKg,
              weightLb: weightLb,
              onUnitToggle: onUnitToggle,
              onSelectKg: onSelectKg,
              onSelectLb: onSelectLb,
            ),
          ),
        ),
        
        Spacer(flex: isSmallScreen ? 1 : 2),
        
        // Continue button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              textStyle: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold),
            ),
            child: Text(AppLocalizations.of(context)!.continueButton),
          ),
        ),
      ],
    );
  }
}

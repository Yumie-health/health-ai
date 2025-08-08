import 'package:flutter/material.dart';
import 'improved_weight_selector.dart';

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
  }) : super(key: key);

  double _calculateBMI() {
    final weightKg = this.weightKg ?? 70.0;
    // Using a default height of 170cm for BMI calculation
    // In a real implementation, you'd get this from the previous step
    final heightM = 1.70;
    return weightKg / (heightM * heightM);
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal weight";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  Color _getBMIColor(double bmi, BuildContext context) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Theme.of(context).primaryColor;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bmi = _calculateBMI();
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
                  'Your current weight',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 24 : 32,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'This helps us track your progress',
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
        
        SizedBox(height: isSmallScreen ? 15 : 30),
        
        // BMI Display
        if (weightKg != null)
          FadeTransition(
            opacity: fadeAnimation,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: _getBMIColor(bmi, context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _getBMIColor(bmi, context).withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getBMIColor(bmi, context).withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Your BMI:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    bmi.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: _getBMIColor(bmi, context),
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getBMICategory(bmi),
                    style: TextStyle(
                      fontSize: 16,
                      color: _getBMIColor(bmi, context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
            child: Text('Continue'),
          ),
        ),
      ],
    );
  }
}

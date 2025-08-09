import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../l10n/app_localizations.dart';

class ImprovedGoalWeightStep extends StatefulWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final bool useMetric;
  final double goalWeightKg;
  final double currentWeightKg;
  final void Function(double) onGoalWeightChanged;
  final VoidCallback? onContinue;
  final VoidCallback onBack;
  final String? selectedGoal;

  const ImprovedGoalWeightStep({
    Key? key,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.useMetric,
    required this.goalWeightKg,
    required this.currentWeightKg,
    required this.onGoalWeightChanged,
    required this.onContinue,
    required this.onBack,
    required this.selectedGoal,
  }) : super(key: key);

  @override
  State<ImprovedGoalWeightStep> createState() => _ImprovedGoalWeightStepState();
}

class _ImprovedGoalWeightStepState extends State<ImprovedGoalWeightStep>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  Timer? _continuousTimer;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    
    // Auto-set goal weight for build muscle and eat healthier, and ensure it's within bounds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedGoal == 'Build muscle' || widget.selectedGoal == 'Eat healthier') {
        widget.onGoalWeightChanged(widget.currentWeightKg);
      } else {
        // Ensure the current goal weight is within the slider bounds
        final currentDisplay = widget.useMetric ? widget.goalWeightKg : widget.goalWeightKg * 2.20462;
        final minVal = _getMinValue();
        final maxVal = _getMaxValue();
        
        if (currentDisplay < minVal || currentDisplay > maxVal) {
          // Reset to current weight if out of bounds
          widget.onGoalWeightChanged(widget.currentWeightKg);
        }
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _continuousTimer?.cancel();
    super.dispose();
  }

  void _changeWeight(double delta) {
    HapticFeedback.selectionClick();
    _bounceController.forward().then((_) => _bounceController.reverse());
    
    // Apply delta in kg (always work in kg internally)
    final deltaKg = widget.useMetric ? delta : delta / 2.20462;
    final newWeightKg = widget.goalWeightKg + deltaKg;
    
    // Convert to display units for bounds checking
    final newWeightDisplay = widget.useMetric ? newWeightKg : newWeightKg * 2.20462;
    final minVal = _getMinValue();
    final maxVal = _getMaxValue();
    
    // Clamp in display units, then convert back to kg
    final clampedDisplay = newWeightDisplay.clamp(minVal, maxVal);
    final clampedWeightKg = widget.useMetric ? clampedDisplay : clampedDisplay / 2.20462;
    
    widget.onGoalWeightChanged(clampedWeightKg);
  }

  void _startContinuousChange(double delta) {
    _continuousTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _changeWeight(delta);
    });
  }

  void _stopContinuousChange() {
    _continuousTimer?.cancel();
  }

  void _onSliderChanged(double value) {
    HapticFeedback.selectionClick();
    _bounceController.forward().then((_) => _bounceController.reverse());
    
    final goalKg = widget.useMetric ? value : value / 2.20462;
    widget.onGoalWeightChanged(goalKg);
  }

  double _getCurrentSliderValue() {
    final sliderValue = widget.useMetric ? widget.goalWeightKg : widget.goalWeightKg * 2.20462;
    final minVal = _getMinValue();
    final maxVal = _getMaxValue();
    
    // Clamp the value to ensure it's within the slider bounds
    return sliderValue.clamp(minVal, maxVal);
  }

  double _getMinValue() {
    final currentDisplay = widget.useMetric ? widget.currentWeightKg : widget.currentWeightKg * 2.20462;
    
    if (widget.selectedGoal == 'Lose body weight') {
      return widget.useMetric ? 30.0 : 66.0;
    } else if (widget.selectedGoal == 'Gain weight') {
      return currentDisplay;
    } else if (widget.selectedGoal == 'Build muscle' || widget.selectedGoal == 'Eat healthier') {
      return currentDisplay;
    } else {
      return widget.useMetric ? 30.0 : 66.0;
    }
  }

  double _getMaxValue() {
    final currentDisplay = widget.useMetric ? widget.currentWeightKg : widget.currentWeightKg * 2.20462;
    
    if (widget.selectedGoal == 'Lose body weight') {
      return currentDisplay;
    } else if (widget.selectedGoal == 'Gain weight') {
      return widget.useMetric ? 200.0 : 440.0;
    } else if (widget.selectedGoal == 'Build muscle' || widget.selectedGoal == 'Eat healthier') {
      return currentDisplay;
    } else {
      return widget.useMetric ? 200.0 : 440.0;
    }
  }

  String _getDisplayWeight() {
    final weight = widget.useMetric ? widget.goalWeightKg : widget.goalWeightKg * 2.20462;
    return "${weight.toStringAsFixed(1)}";
  }

  String _getSubtitle() {
    if (widget.selectedGoal == 'Build muscle' || widget.selectedGoal == 'Eat healthier') {
      return AppLocalizations.of(context)!.yourTargetWeightIsSetToCurrent;
    }
    return AppLocalizations.of(context)!.setARealisticGoalForYourJourney;
  }

  bool _shouldShowSlider() {
    return widget.selectedGoal != 'Build muscle' && widget.selectedGoal != 'Eat healthier';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentSliderValue = _getCurrentSliderValue();
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
              onPressed: widget.onBack,
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 16 : 32),
        
        // Title with animation
        FadeTransition(
          opacity: widget.fadeAnimation,
          child: SlideTransition(
            position: widget.slideAnimation,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.yourGoalWeight,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 24 : 32,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  _getSubtitle(),
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
        
        // Beautiful weight display
        FadeTransition(
          opacity: widget.fadeAnimation,
          child: SlideTransition(
            position: widget.slideAnimation,
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primaryColor.withOpacity(0.1),
                          theme.primaryColor.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.1),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDisplayWeight(),
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.useMetric ? "kilograms" : "pounds",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 20 : 40),
        
        // Slider controls (only show if not build muscle or eat healthier)
        if (_shouldShowSlider())
          FadeTransition(
            opacity: widget.fadeAnimation,
            child: SlideTransition(
              position: widget.slideAnimation,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Precise control buttons with longer slider
                    Row(
                      children: [
                        // Decrease button
                        GestureDetector(
                          onTap: () => _changeWeight(-0.5),
                          onLongPressStart: (_) => _startContinuousChange(-0.5),
                          onLongPressEnd: (_) => _stopContinuousChange(),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.primaryColor.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.remove,
                              color: theme.primaryColor,
                              size: 28,
                            ),
                          ),
                        ),
                        
                        SizedBox(width: 12),
                        
                        // Slider takes up most of the space - much longer
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 8.0,
                              thumbShape: CustomSliderThumbShape(),
                              overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                              activeTrackColor: theme.primaryColor,
                              inactiveTrackColor: theme.primaryColor.withOpacity(0.2),
                              thumbColor: theme.primaryColor,
                              overlayColor: theme.primaryColor.withOpacity(0.1),
                            ),
                            child: Slider(
                              value: currentSliderValue,
                              min: _getMinValue(),
                              max: _getMaxValue(),
                              divisions: (_getMaxValue() - _getMinValue()).toInt(),
                              onChanged: _onSliderChanged,
                            ),
                          ),
                        ),
                        
                        SizedBox(width: 12),
                        
                        // Increase button
                        GestureDetector(
                          onTap: () => _changeWeight(0.5),
                          onLongPressStart: (_) => _startContinuousChange(0.5),
                          onLongPressEnd: (_) => _stopContinuousChange(),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.primaryColor.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add,
                              color: theme.primaryColor,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Increment labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.useMetric ? '-0.5 kg' : '-0.5 lbs',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.primaryColor.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.useMetric ? '+0.5 kg' : '+0.5 lbs',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.primaryColor.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        Spacer(flex: isSmallScreen ? 1 : 2),
        
        // Continue button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onContinue,
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

class CustomSliderThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(48.0, 48.0);  // Much larger touch target
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    
    // Draw outer circle (white with shadow)
    final Paint outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);
    
    // Draw shadow - larger
    canvas.drawCircle(center + Offset(0, 1), 18.0, shadowPaint);
    
    // Draw outer white circle - larger
    canvas.drawCircle(center, 18.0, outerPaint);
    
    // Draw inner colored circle - larger
    final Paint innerPaint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 14.0, innerPaint);
  }
}

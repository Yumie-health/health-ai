import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class ImprovedWeightSelector extends StatefulWidget {
  final bool useMetric;
  final double? weightKg;
  final double weightLb;
  final void Function(bool)? onUnitToggle;
  final void Function(double) onSelectKg;
  final void Function(double) onSelectLb;

  const ImprovedWeightSelector({
    Key? key,
    required this.useMetric,
    required this.weightKg,
    required this.weightLb,
    this.onUnitToggle,
    required this.onSelectKg,
    required this.onSelectLb,
  }) : super(key: key);

  @override
  State<ImprovedWeightSelector> createState() => _ImprovedWeightSelectorState();
}

class _ImprovedWeightSelectorState extends State<ImprovedWeightSelector>
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
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _continuousTimer?.cancel();
    super.dispose();
  }

  void _onSliderChanged(double value) {
    HapticFeedback.selectionClick();
    _bounceController.forward().then((_) => _bounceController.reverse());

    if (widget.useMetric) {
      widget.onSelectKg(value);
      // Update lb value
      widget.onSelectLb(value * 2.20462);
    } else {
      widget.onSelectLb(value);
      // Update kg value
      widget.onSelectKg(value / 2.20462);
    }
  }

  double _getCurrentSliderValue() {
    if (widget.useMetric) {
      return widget.weightKg ?? 70.0;
    } else {
      return widget.weightLb;
    }
  }

  double _getMinValue() => widget.useMetric ? 30.0 : 66.0; // 30kg = ~66lbs
  double _getMaxValue() => widget.useMetric ? 200.0 : 440.0; // 200kg = ~440lbs

  void _changeWeight(double delta) {
    HapticFeedback.selectionClick();
    _bounceController.forward().then((_) => _bounceController.reverse());

    if (widget.useMetric) {
      final newWeight = (widget.weightKg ?? 70.0) + delta;
      final clampedWeight = newWeight.clamp(_getMinValue(), _getMaxValue());
      widget.onSelectKg(clampedWeight);
      widget.onSelectLb(clampedWeight * 2.20462);
    } else {
      final newWeight = widget.weightLb + delta;
      final clampedWeight = newWeight.clamp(_getMinValue(), _getMaxValue());
      widget.onSelectLb(clampedWeight);
      widget.onSelectKg(clampedWeight / 2.20462);
    }
  }

  void _startContinuousChange(double delta) {
    _continuousTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _changeWeight(delta);
    });
  }

  void _stopContinuousChange() {
    _continuousTimer?.cancel();
  }

  String _getDisplayWeight() {
    if (widget.useMetric) {
      final weight = widget.weightKg ?? 70.0;
      return "${weight.toStringAsFixed(1)}";
    } else {
      return "${widget.weightLb.toStringAsFixed(1)}";
    }
  }

  double _calculateBMI() {
    final weightKg = widget.weightKg ?? 70.0;
    // You'll need to get height from parent component
    // For now, using a default height of 170cm
    final heightM = 1.70; // This should come from the actual height
    return weightKg / (heightM * heightM);
  }

  @override
  Widget build(BuildContext context) {
    final currentWeightKg = widget.weightKg ?? 70.0;
    final currentSliderValue = _getCurrentSliderValue();

    // Get screen size for responsive design
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700 || screenWidth < 360;

    return Column(
      children: [
        // Unit toggle buttons (lb first, then kg) - completely hidden when locked by height
        if (false)
          Row(
            // Always hide since units are locked by height selection
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => widget.onUnitToggle?.call(false),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color:
                        !widget.useMetric
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    boxShadow:
                        !widget.useMetric
                            ? [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ]
                            : null,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                    vertical: isSmallScreen ? 10 : 12,
                  ),
                  child: Text(
                    "lb",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color:
                          !widget.useMetric
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              GestureDetector(
                onTap: () => widget.onUnitToggle?.call(true),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color:
                        widget.useMetric
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    boxShadow:
                        widget.useMetric
                            ? [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ]
                            : null,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                    vertical: isSmallScreen ? 10 : 12,
                  ),
                  child: Text(
                    "kg",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color:
                          widget.useMetric
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),

        SizedBox(height: isSmallScreen ? 30 : 50),

        // Weight display
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnimation.value,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 30,
                  vertical: isSmallScreen ? 16 : 24,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      widget.useMetric
                          ? "${currentWeightKg.toStringAsFixed(1)} kg"
                          : "${widget.weightLb.toStringAsFixed(1)} lb",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 32 : 42,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Text(
                      widget.useMetric ? "kilograms" : "pounds",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        SizedBox(height: isSmallScreen ? 30 : 50),

        // Slider with buttons
        Container(
          margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 30),
          child: Column(
            children: [
              // Slider takes full width
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: isSmallScreen ? 6.0 : 8.0,
                  thumbShape: CustomSliderThumbShape(
                    isSmallScreen: isSmallScreen,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: isSmallScreen ? 24.0 : 20.0,
                  ),
                  activeTrackColor: Theme.of(context).primaryColor,
                  inactiveTrackColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  thumbColor: Theme.of(context).primaryColor,
                  overlayColor: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: Slider(
                  value: currentSliderValue,
                  min: _getMinValue(),
                  max: _getMaxValue(),
                  divisions:
                      widget.useMetric ? 340 : 748, // 0.5kg or 0.5lbs precision
                  onChanged: _onSliderChanged,
                ),
              ),

              SizedBox(height: isSmallScreen ? 16 : 20),

              // Buttons below slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.remove,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ),
                  ),

                  // Increase button
                  GestureDetector(
                    onTap: () => _changeWeight(0.5),
                    onLongPressStart: (_) => _startContinuousChange(0.5),
                    onLongPressEnd: (_) => _stopContinuousChange(),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isSmallScreen ? 16 : 20),

              // Increment labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.useMetric ? '-0.5 kg' : '-0.5 lbs',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Theme.of(context).primaryColor.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.useMetric ? '+0.5 kg' : '+0.5 lbs',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Theme.of(context).primaryColor.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomSliderThumbShape extends SliderComponentShape {
  final bool isSmallScreen;

  CustomSliderThumbShape({this.isSmallScreen = false});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(isSmallScreen ? 24.0 : 24.0, isSmallScreen ? 24.0 : 24.0);
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
    final Paint outerPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final Paint shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);

    // Draw shadow
    canvas.drawCircle(center + Offset(0, 2), 14.0, shadowPaint);

    // Draw outer white circle
    canvas.drawCircle(center, 14.0, outerPaint);

    // Draw inner colored circle
    final Paint innerPaint =
        Paint()
          ..color = sliderTheme.thumbColor!
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 10.0, innerPaint);
  }
}

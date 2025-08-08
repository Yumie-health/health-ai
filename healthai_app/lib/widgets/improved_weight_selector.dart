import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class ImprovedWeightSelector extends StatefulWidget {
  final bool useMetric;
  final double? weightKg;
  final double weightLb;
  final void Function(bool) onUnitToggle;
  final void Function(double) onSelectKg;
  final void Function(double) onSelectLb;

  const ImprovedWeightSelector({
    Key? key,
    required this.useMetric,
    required this.weightKg,
    required this.weightLb,
    required this.onUnitToggle,
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
    final currentSliderValue = _getCurrentSliderValue();
    
    return Column(
      children: [
        
        SizedBox(height: 20),
        
        // Beautiful weight display
        AnimatedBuilder(
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
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.2),
                    ],
                  ),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getDisplayWeight(),
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.useMetric ? "kilograms" : "pounds",
                      style: TextStyle(
                        fontSize: 16,
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
        
        SizedBox(height: 40),
        
                // Custom beautiful slider with precise controls
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Precise control buttons with much longer slider
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
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                  
                  SizedBox(width: 12),
                  
                  // Slider takes up most of the space - much longer
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3.0,
                        thumbShape: CustomSliderThumbShape(),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 50.0),
                        activeTrackColor: Theme.of(context).primaryColor,
                        inactiveTrackColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        thumbColor: Theme.of(context).primaryColor,
                        overlayColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      child: Slider(
                        value: currentSliderValue,
                        min: _getMinValue(),
                        max: _getMaxValue(),
                        divisions: widget.useMetric ? 340 : 748, // 0.5kg or 0.5lbs precision
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
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
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
              
              SizedBox(height: 20),
              
              // Increment labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.useMetric ? '-0.5 kg' : '-0.5 lbs',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColor.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.useMetric ? '+0.5 kg' : '+0.5 lbs',
                    style: TextStyle(
                      fontSize: 14,
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
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(18.0, 18.0);  // Smaller visual size
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
    
    // Draw shadow - smaller
    canvas.drawCircle(center + Offset(0, 1), 10.0, shadowPaint);
    
    // Draw outer white circle - smaller
    canvas.drawCircle(center, 10.0, outerPaint);
    
    // Draw inner colored circle - smaller
    final Paint innerPaint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 7.0, innerPaint);
  }
}

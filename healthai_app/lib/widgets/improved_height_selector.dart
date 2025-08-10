import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImprovedHeightSelector extends StatefulWidget {
  final bool useMetric;
  final double? heightCm;
  final int heightFeet;
  final int heightInches;
  final void Function(bool) onUnitToggle;
  final void Function(double) onSelectCm;
  final void Function(int, int) onSelectFtIn;

  const ImprovedHeightSelector({
    Key? key,
    required this.useMetric,
    required this.heightCm,
    required this.heightFeet,
    required this.heightInches,
    required this.onUnitToggle,
    required this.onSelectCm,
    required this.onSelectFtIn,
  }) : super(key: key);

  @override
  State<ImprovedHeightSelector> createState() => _ImprovedHeightSelectorState();
}

class _ImprovedHeightSelectorState extends State<ImprovedHeightSelector>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

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
    super.dispose();
  }

  void _onSliderChanged(double value) {
    HapticFeedback.selectionClick();
    _bounceController.forward().then((_) => _bounceController.reverse());
    
    if (widget.useMetric) {
      widget.onSelectCm(value);
    } else {
      // Convert slider value (in inches) to feet and inches
      final totalInches = value.round();
      final feet = totalInches ~/ 12;
      final inches = totalInches % 12;
      widget.onSelectFtIn(feet, inches);
    }
  }

  double _getCurrentSliderValue() {
    if (widget.useMetric) {
      return widget.heightCm ?? 170.0;
    } else {
      // Convert feet/inches to total inches for slider
      return (widget.heightFeet * 12 + widget.heightInches).toDouble();
    }
  }

  double _getMinValue() => widget.useMetric ? 100.0 : 36.0; // 3'0"
  double _getMaxValue() => widget.useMetric ? 220.0 : 87.0; // 7'3"

  @override
  Widget build(BuildContext context) {
    final currentHeightCm = widget.heightCm ?? 170.0;
    final currentSliderValue = _getCurrentSliderValue();
    
    // Get screen size for responsive design
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700 || screenWidth < 360;
    
    return Column(
      children: [
        // Unit toggle buttons (ft first, then cm)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => widget.onUnitToggle(false),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: !widget.useMetric ? Theme.of(context).primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                  boxShadow: !widget.useMetric ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ] : null,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 20, 
                  vertical: isSmallScreen ? 10 : 12
                ),
                child: Text(
                  "ft",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: !widget.useMetric ? Colors.white : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            GestureDetector(
              onTap: () => widget.onUnitToggle(true),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: widget.useMetric ? Theme.of(context).primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                  boxShadow: widget.useMetric ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ] : null,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 20, 
                  vertical: isSmallScreen ? 10 : 12
                ),
                child: Text(
                  "cm",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: widget.useMetric ? Colors.white : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: isSmallScreen ? 30 : 50),
        
        // Height display
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnimation.value,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 30, 
                  vertical: isSmallScreen ? 16 : 24
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
                        ? "${currentHeightCm.round()} cm"
                        : "${widget.heightFeet}'${widget.heightInches.toString().padLeft(2, '0')}\"",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 32 : 42,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Text(
                      widget.useMetric ? "centimeters" : "feet",
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
        
        // Custom beautiful slider
        Container(
          margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 30),
          child: Column(
            children: [
              // Slider track with custom design
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: isSmallScreen ? 6.0 : 8.0,
                  thumbShape: CustomSliderThumbShape(isSmallScreen: isSmallScreen),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: isSmallScreen ? 24.0 : 20.0
                  ),
                  activeTrackColor: Theme.of(context).primaryColor,
                  inactiveTrackColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  thumbColor: Theme.of(context).primaryColor,
                  overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
                child: Slider(
                  value: currentSliderValue,
                  min: _getMinValue(),
                  max: _getMaxValue(),
                  divisions: widget.useMetric ? 120 : 51, // 1cm or 1inch precision
                  onChanged: _onSliderChanged,
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Min and max labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      widget.useMetric ? '100 cm' : '3\'0"',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Theme.of(context).primaryColor.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      widget.useMetric ? '220 cm' : '7\'3"',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Theme.of(context).primaryColor.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
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
    final Paint outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);
    
    // Draw shadow
    canvas.drawCircle(center + Offset(0, 2), 14.0, shadowPaint);
    
    // Draw outer white circle
    canvas.drawCircle(center, 14.0, outerPaint);
    
    // Draw inner colored circle
    final Paint innerPaint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 10.0, innerPaint);
  }
}

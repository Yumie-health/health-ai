import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final double overlayOpacity;
  final Rect frameRect;

  const ScannerOverlay({
    required this.frameRect,
    this.borderRadius = 32,
    this.borderWidth = 4,
    this.borderColor = Colors.greenAccent,
    this.overlayOpacity = 0.7,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return CustomPaint(
          size: size,
          painter: _ScannerOverlayPainter(
            frameRect: frameRect,
            borderRadius: borderRadius,
            borderWidth: borderWidth,
            borderColor: borderColor,
            overlayOpacity: overlayOpacity,
          ),
        );
      },
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Rect frameRect;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final double overlayOpacity;

  _ScannerOverlayPainter({
    required this.frameRect,
    required this.borderRadius,
    required this.borderWidth,
    required this.borderColor,
    required this.overlayOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final screenRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw the semi-transparent overlay
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(overlayOpacity)
      ..style = PaintingStyle.fill;
    final overlayPath = Path()..addRect(screenRect);
    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(frameRect, Radius.circular(borderRadius)));
    final combined = Path.combine(PathOperation.difference, overlayPath, holePath);
    canvas.drawPath(combined, overlayPaint);

    // Draw the border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, Radius.circular(borderRadius)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 
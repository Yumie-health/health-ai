import 'package:flutter/material.dart';

class ResponsiveText {
  static double getScaledFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate scale factor based on screen size
    double scaleFactor = 1.0;

    // For very small screens (width < 320px or height < 600px)
    if (screenWidth < 320 || screenHeight < 600) {
      scaleFactor = 0.8;
    }
    // For small screens (width < 360px or height < 700px)
    else if (screenWidth < 360 || screenHeight < 700) {
      scaleFactor = 0.85;
    }
    // For medium screens (width < 400px or height < 800px)
    else if (screenWidth < 400 || screenHeight < 800) {
      scaleFactor = 0.9;
    }
    // For large screens (width > 600px or height > 1000px)
    else if (screenWidth > 600 || screenHeight > 1000) {
      scaleFactor = 1.1;
    }

    return baseFontSize * scaleFactor;
  }

  static TextStyle getResponsiveTextStyle(
    BuildContext context, {
    required double baseFontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
    Paint? foreground,
  }) {
    return TextStyle(
      fontSize: getScaledFontSize(context, baseFontSize),
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
      foreground: foreground,
    );
  }

  static Widget responsiveText(
    BuildContext context,
    String text, {
    required double baseFontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextAlign? textAlign,
    TextDecoration? decoration,
    Paint? foreground,
    int? maxLines,
    TextOverflow? overflow,
    bool softWrap = true,
  }) {
    return Text(
      text,
      style: getResponsiveTextStyle(
        context,
        baseFontSize: baseFontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
        foreground: foreground,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }

  static Widget fittedText(
    BuildContext context,
    String text, {
    required double baseFontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextAlign? textAlign,
    TextDecoration? decoration,
    Paint? foreground,
    BoxFit fit = BoxFit.scaleDown,
  }) {
    return FittedBox(
      fit: fit,
      child: Text(
        text,
        style: getResponsiveTextStyle(
          context,
          baseFontSize: baseFontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
          decoration: decoration,
          foreground: foreground,
        ),
        textAlign: textAlign,
      ),
    );
  }
}

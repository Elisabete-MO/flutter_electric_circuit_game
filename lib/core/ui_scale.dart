import 'package:flutter/material.dart';

/// Class utility to handle responsive layout scaling across different screen sizes
/// (mobile, tablet, desktop, and large displays).
class UiScale {
  final double screenWidth;
  final double screenHeight;

  UiScale._({required this.screenWidth, required this.screenHeight});

  /// Factory from BuildContext
  factory UiScale.of(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return UiScale._(screenWidth: size.width, screenHeight: size.height);
  }

  /// Factory from raw dimensions
  factory UiScale.fromSize(double width, double height) {
    return UiScale._(screenWidth: width, screenHeight: height);
  }

  /// Returns whether the device screen width qualifies as mobile (< 600px)
  bool get isMobile => screenWidth < 600;

  /// Returns whether the device screen width qualifies as tablet (600px - 1100px)
  bool get isTablet => screenWidth >= 600 && screenWidth <= 1100;

  /// Returns whether the device screen width qualifies as desktop/large (> 1100px)
  bool get isDesktop => screenWidth > 1100;

  /// Multiplier factor relative to standard reference width
  double get scaleFactor {
    if (screenWidth < 600) {
      return 1.0;
    } else if (screenWidth <= 1100) {
      return 1.15;
    } else if (screenWidth <= 1600) {
      return 1.35;
    } else {
      return (screenWidth / 1280.0).clamp(1.35, 2.2);
    }
  }

  /// Scale a base size using the device scale factor
  double size(double baseSize) {
    return baseSize * scaleFactor;
  }

  /// Scale font size within safe bounds
  double font(double baseFont, {double min = 10.0, double max = 36.0}) {
    return (baseFont * scaleFactor).clamp(min, max);
  }

  /// Safely scale a value with custom dynamic min and max upper caps according to screen width
  double clampScaled(double baseValue, double minVal, double maxVal) {
    final expandedMax = maxVal * (isDesktop ? scaleFactor : 1.0);
    return (baseValue * (isDesktop ? scaleFactor : 1.0)).clamp(minVal, expandedMax);
  }
}

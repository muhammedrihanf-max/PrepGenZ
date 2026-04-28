import 'package:flutter/material.dart';
import 'dart:ui';

class GlassTheme {
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color accentColor = Color(0xFFA855F7);
  static const Color backgroundColor = Color(0xFF0F172A);
  
  static BoxDecoration glassDecoration({
    double opacity = 0.1,
    double blur = 16,
    double borderRadius = 24,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(opacity * 2),
        width: 1.5,
      ),
    );
  }

  static Widget glassWrapper({
    required Widget child,
    double blur = 16,
    double borderRadius = 24,
    double opacity = 0.05,
    EdgeInsets? padding,
    Color? borderColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: glassDecoration(
            opacity: opacity, 
            blur: blur, 
            borderRadius: borderRadius,
            borderColor: borderColor,
          ),
          child: child,
        ),
      ),
    );
  }
}

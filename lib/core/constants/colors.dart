import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  AppColors._();
  
  // Primary colors
  static const Color primary = Color(0xFF1A1A2E);
  static const Color accent = Color(0xFFFFD700);
  static const Color secondary = Color(0xFF16213E);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  
  // Feedback colors
  static const Color guidanceGood = Color(0xFF4CAF50);
  static const Color guidanceAdjusting = Color(0xFFFFC107);
  static const Color guidanceFar = Color(0xFFFF5252);
  
  // Overlay
  static const Color overlayBackground = Color(0x80000000);
  static const Color gridLine = Color(0x80FFFFFF);
}

/// Composition grid styles
enum GridStyle {
  ruleOfThirds,
  goldenRatio,
  diagonal,
  centerPoint,
}

extension GridStyleExtension on GridStyle {
  String get displayName {
    switch (this) {
      case GridStyle.ruleOfThirds:
        return '三分法';
      case GridStyle.goldenRatio:
        return '黄金比例';
      case GridStyle.diagonal:
        return '对角线';
      case GridStyle.centerPoint:
        return '中心点';
    }
  }
}

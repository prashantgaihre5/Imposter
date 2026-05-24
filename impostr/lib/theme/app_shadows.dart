import 'package:flutter/material.dart';

import 'app_theme.dart';

class AppShadows {
  static List<BoxShadow> glass({double alpha = 0.08}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: alpha),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> neon(Color color, {double alpha = 0.2}) => [
        BoxShadow(
          color: color.withValues(alpha: alpha),
          blurRadius: 20,
          spreadRadius: 1,
        ),
      ];

  static List<BoxShadow> accentGlow({Color color = AppColors.accentPurple, double alpha = 0.15}) => [
        BoxShadow(
          color: color.withValues(alpha: alpha),
          blurRadius: 18,
          spreadRadius: 0.5,
        ),
      ];

  static List<BoxShadow> detectiveGlow({double alpha = 0.14}) => [
        BoxShadow(
          color: AppColors.detectiveBlue.withValues(alpha: alpha),
          blurRadius: 20,
          spreadRadius: 0.25,
        ),
      ];

  static List<BoxShadow> suspectGlow({double alpha = 0.14}) => [
        BoxShadow(
          color: AppColors.suspectRed.withValues(alpha: alpha),
          blurRadius: 20,
          spreadRadius: 0.25,
        ),
      ];
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_animations.dart';
import '../theme/app_gradients.dart';
import '../theme/app_radius.dart';
import '../theme/app_theme.dart';
import '../theme/app_shadows.dart';

class AppNeonButton extends StatelessWidget {
  const AppNeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.active = true,
    this.activeGradient = AppGradients.glassButton,
    this.inactiveColor = AppColors.bgSurface,
    this.activeTextColor = AppColors.textPrimary,
    this.inactiveTextColor = AppColors.textSecondary,
    this.height = 52,
    this.borderRadius = AppRadius.full,
    this.borderColor,
    this.borderWidth = 0.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final String label;
  final VoidCallback? onPressed;
  final bool active;
  final Gradient activeGradient;
  final Color inactiveColor;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final double height;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isEnabled = active && onPressed != null;
    final background = isEnabled ? activeGradient : null;
    final fillColor = isEnabled ? null : inactiveColor;
    final textColor = isEnabled ? activeTextColor : inactiveTextColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: fillColor,
            gradient: background,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? (isEnabled ? Colors.transparent : AppColors.borderSide.color),
              width: borderWidth,
            ),
            boxShadow: isEnabled
                ? AppShadows.detectiveGlow(alpha: 0.08)
                : AppShadows.glass(alpha: 0.06),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ).animate(target: 1).fadeIn(duration: AppDurations.fast),
        ),
      ),
    );
  }
}

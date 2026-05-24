import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_animations.dart';
import '../theme/app_gradients.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_theme.dart';

class AppAnimatedChip extends StatelessWidget {
  const AppAnimatedChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.leadingIcon,
    this.backgroundColor,
    this.selectedGradient = AppGradients.purpleGlow,
    this.textColor = AppColors.textPrimary,
    this.selectedTextColor = AppColors.textPrimary,
    this.borderColor,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? leadingIcon;
  final Color? backgroundColor;
  final Gradient selectedGradient;
  final Color textColor;
  final Color selectedTextColor;
  final Color? borderColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final baseColor = borderColor ?? AppColors.borderSide.color;

    return AnimatedScale(
      scale: selected ? 1.0 : 0.985,
      duration: AppDurations.fast,
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 14,
              vertical: compact ? 8 : 10,
            ),
            decoration: BoxDecoration(
              color: selected ? null : (backgroundColor ?? AppColors.bgSurface),
              gradient: selected ? selectedGradient : null,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: selected ? Colors.transparent : baseColor,
                width: selected ? 0 : 0.6,
              ),
              boxShadow: selected
                  ? AppShadows.accentGlow(color: AppColors.accentPurple, alpha: 0.14)
                  : AppShadows.glass(alpha: 0.04),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  Icon(
                    leadingIcon,
                    size: compact ? 14 : 16,
                    color: selected ? selectedTextColor : textColor.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: GoogleFonts.spaceMono(
                    fontSize: compact ? 10 : 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: selected ? selectedTextColor : textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppDurations.fast).slideX(begin: 0.03, end: 0);
  }
}
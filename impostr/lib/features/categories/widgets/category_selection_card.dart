import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/word_category.dart';
import '../../../theme/app_animations.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_animated_chip.dart';
import '../../../widgets/app_glass_card.dart';

class CategorySelectionCard extends StatelessWidget {
  const CategorySelectionCard({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final WordCategory category;
  final bool selected;
  final VoidCallback onTap;

  IconData get _iconData {
    switch (category.icon) {
      case 'verified':
        return Icons.verified;
      case 'pets':
        return Icons.pets;
      case 'nutrition':
        return Icons.restaurant;
      case 'restaurant':
        return Icons.restaurant;
      case 'category':
        return Icons.category;
      case 'star':
        return Icons.star;
      case 'location_city':
        return Icons.location_city;
      case 'public':
        return Icons.public;
      case 'favorite':
        return Icons.favorite;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'theaters':
        return Icons.theaters;
      case 'animation':
        return Icons.animation;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'directions_car':
        return Icons.directions_car;
      case 'music_note':
        return Icons.music_note;
      case 'home':
        return Icons.home;
      case 'memory':
        return Icons.memory;
      case 'checkroom':
        return Icons.checkroom;
      case 'flight_takeoff':
        return Icons.flight_takeoff;
      case 'cloud':
        return Icons.cloud;
      case 'shuffle':
        return Icons.shuffle;
      default:
        return Icons.category;
    }
  }

  Widget _buildCountBadge(Color baseColor, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: baseColor.withValues(alpha: 0.18), width: 0.7),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.spaceMono(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: selected ? baseColor : AppColors.textSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Color(category.color);
    final wordCount = category.words.length;

    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: AppCurves.standard,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: selected
            ? AppShadows.neon(baseColor, alpha: 0.12)
            : AppShadows.glass(alpha: 0.03),
      ),
      child: AnimatedScale(
        scale: selected ? 1.0 : 0.985,
        duration: AppDurations.fast,
        curve: AppCurves.standard,
        child: GestureDetector(
          onTap: onTap,
          child: AppGlassCard(
            padding: const EdgeInsets.all(14),
            borderRadius: AppRadius.lg,
            borderColor: selected ? baseColor : AppColors.borderSide.color,
            borderWidth: selected ? 1.4 : 0.6,
            shadowAlpha: selected ? 0.12 : 0.06,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: selected
                            ? LinearGradient(
                                colors: [
                                  baseColor.withValues(alpha: 0.30),
                                  baseColor.withValues(alpha: 0.10),
                                ],
                              )
                            : null,
                        color: selected ? null : AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: selected ? AppShadows.accentGlow(color: baseColor, alpha: 0.14) : null,
                      ),
                      child: Icon(_iconData, color: selected ? baseColor : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (category.premium) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.workspace_premium, size: 14, color: AppColors.accentAmber),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            category.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: AppDurations.fast,
                      child: selected
                          ? Icon(Icons.check_circle, key: const ValueKey('selected'), color: baseColor, size: 20)
                          : Icon(Icons.radio_button_unchecked, key: const ValueKey('unselected'), color: AppColors.textSecondary.withValues(alpha: 0.6), size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    AppAnimatedChip(
                      label: selected ? 'Selected' : 'Tap to add',
                      selected: selected,
                      compact: true,
                      borderColor: baseColor,
                      leadingIcon: selected ? Icons.check_rounded : Icons.add_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildCountBadge(baseColor, wordCount),
                    if (category.premium) ...[
                      const SizedBox(width: 8),
                      AppAnimatedChip(
                        label: 'VIP',
                        selected: true,
                        compact: true,
                        selectedGradient: LinearGradient(
                          colors: [baseColor.withValues(alpha: 0.9), const Color(0xFFB8860B)],
                        ),
                        leadingIcon: Icons.star_rounded,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(target: selected ? 1 : 0.96).fadeIn(duration: AppDurations.fast);
  }
}

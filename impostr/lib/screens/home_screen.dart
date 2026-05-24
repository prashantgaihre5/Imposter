import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_animations.dart';
import '../theme/app_gradients.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_theme.dart';
import '../widgets/app_animated_chip.dart';
import '../widgets/app_glass_card.dart';
import '../widgets/app_neon_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(gradient: AppGradients.background),
              ),
            ),
            Positioned.fill(child: _buildBackgroundOrbs()),

            // Main content, fill the stack so Column has bounded constraints
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopChrome(context),
                    const SizedBox(height: 18),
                    _buildHeroCard(),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        AppAnimatedChip(
                          label: 'Local Only',
                          selected: true,
                          compact: true,
                          leadingIcon: Icons.wifi_tethering_off_rounded,
                        ),
                        AppAnimatedChip(
                          label: 'Viral',
                          selected: true,
                          compact: true,
                          leadingIcon: Icons.flash_on_rounded,
                        ),
                        AppAnimatedChip(
                          label: 'Chaotic',
                          selected: true,
                          compact: true,
                          leadingIcon: Icons.auto_awesome_rounded,
                        ),
                      ],
                    ).animate().fadeIn(delay: 420.ms, duration: AppDurations.medium),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'SELECT MODE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceMono(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const AppAnimatedChip(
                          label: 'Classic ready',
                          selected: true,
                          compact: true,
                          leadingIcon: Icons.check_circle_rounded,
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth < 720 ? 1 : 2;
                        final childAspectRatio = crossAxisCount == 1 ? 1.55 : 0.9;
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: childAspectRatio,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildModeCard(
                              context: context,
                              title: 'Classic Social',
                              description: 'The clean detective-first version for mixed groups.',
                              isActive: true,
                              color: AppColors.detectiveBlue,
                              icon: Icons.search_rounded,
                              onTap: () => context.push('/setup'),
                            ),
                            _buildModeCard(
                              context: context,
                              title: 'Undercover',
                              description: 'A tense suspect-focused variation with sharper reads.',
                              isActive: false,
                              color: AppColors.suspectRed,
                              icon: Icons.visibility_off_rounded,
                            ),
                            _buildModeCard(
                              context: context,
                              title: 'Interrogation',
                              description: 'Faster rounds, tighter clues, and less room to hide.',
                              isActive: false,
                              color: AppColors.accentAmber,
                              icon: Icons.timer_outlined,
                            ),
                            _buildModeCard(
                              context: context,
                              title: 'Chaos Mode',
                              description: 'Multiple impostors and enough noise to fracture the room.',
                              isActive: false,
                              color: AppColors.accentGreen,
                              icon: Icons.cyclone,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppNeonButton(
                          label: 'PLAY NOW',
                          onPressed: () => context.push('/setup'),
                        ).animate().scale(delay: 800.ms, duration: 400.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 12),
                        AppNeonButton(
                          label: 'HOW TO PLAY',
                          active: false,
                          onPressed: () => _showHowToPlay(context),
                        ).animate().fadeIn(delay: 1000.ms),
                      ],
                    ),
                    const SizedBox(height: 26),
                    _buildFooterLinks(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopChrome(BuildContext context) {
    return AppGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: AppRadius.full,
      backgroundColor: AppColors.bgSurface.withValues(alpha: 0.62),
      borderColor: AppColors.borderSide.color.withValues(alpha: 0.85),
      shadowAlpha: 0.07,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 8,
        children: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_rounded, color: AppColors.textPrimary),
            tooltip: 'Settings',
          ),
          TextButton.icon(
            onPressed: () => _showRatePrompt(context),
            icon: const Icon(Icons.star_rounded, size: 18),
            label: Text(
              'RATE APP',
              style: GoogleFonts.spaceMono(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accentAmber,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppDurations.medium).slideY(begin: -0.04, end: 0);
  }

  Widget _buildHeroCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;
        final heroHeight = compact ? 280.0 : 240.0;
        final titleFontSize = compact ? 34.0 : 44.0;
        return SizedBox(
          height: heroHeight,
          child: AppGlassCard(
            padding: EdgeInsets.zero,
            borderRadius: AppRadius.xl,
            backgroundColor: AppColors.bgSurface.withValues(alpha: 0.54),
            borderColor: AppColors.borderSide.color.withValues(alpha: 0.78),
            shadowAlpha: 0.09,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Row(
                      children: [
                        Expanded(
                          child: DecoratedBox(
                            decoration: const BoxDecoration(gradient: AppGradients.splitDetective),
                          ),
                        ),
                        Expanded(
                          child: DecoratedBox(
                            decoration: const BoxDecoration(gradient: AppGradients.splitSuspect),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(gradient: AppGradients.cinematicOverlay),
                    ),
                  ),
                  Positioned(
                    left: -18,
                    top: -12,
                    child: _heroGlow(
                      size: 120,
                      color: AppColors.detectiveBlue,
                      alpha: 0.24,
                    ),
                  ),
                  Positioned(
                    right: -16,
                    bottom: -12,
                    child: _heroGlow(
                      size: 128,
                      color: AppColors.suspectRed,
                      alpha: 0.22,
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _heroTag(
                                label: 'LEFT: DETECTIVE',
                                color: AppColors.detectiveBlue,
                                icon: Icons.manage_search_rounded,
                              ),
                              _heroTag(
                                label: 'RIGHT: SUSPECT',
                                color: AppColors.suspectRed,
                                icon: Icons.report_gmailerrorred_rounded,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Shhh! Who Is It?',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.2,
                                    color: AppColors.textPrimary,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0xAA000000),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.16, end: 0),
                              const SizedBox(height: 6),
                              Text(
                                'SPY. MYSTERY. UNDERCOVER PARTY DETECTIVE.',
                                maxLines: compact ? 2 : 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.spaceMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.7,
                                  color: AppColors.textPrimary.withValues(alpha: 0.82),
                                ),
                              ).animate().fadeIn(delay: 220.ms, duration: 700.ms),
                            ],
                          ),
                          Text(
                            'Split-screen atmosphere for suspicion, bluffing, and fast reads.',
                            maxLines: compact ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ).animate().fadeIn(delay: 360.ms, duration: 700.ms),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _heroTag({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.24), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroGlow({
    required double size,
    required Color color,
    required double alpha,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0.04),
            Colors.transparent,
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
      ),
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    const mutedColor = Color(0xFF4B5563);

    TextStyle linkStyle = GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: mutedColor,
      height: 1.0,
    );

    Widget link(String label, String route) {
      return InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(label, style: linkStyle),
        ),
      );
    }

    Widget separator() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('·', style: linkStyle),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            link('About', '/about'),
            separator(),
            link('Privacy Policy', '/privacy-policy'),
            separator(),
            link('Terms & Conditions', '/terms'),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundOrbs() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -30,
          child: _heroGlow(size: 210, color: AppColors.detectiveBlue, alpha: 0.18),
        ),
        Positioned(
          top: 140,
          right: -60,
          child: _heroGlow(size: 240, color: AppColors.suspectRed, alpha: 0.16),
        ),
        Positioned(
          bottom: 90,
          left: 24,
          child: _heroGlow(size: 160, color: AppColors.accentAmber, alpha: 0.08),
        ),
      ],
    );
  }

  void _showRatePrompt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.bgSurface,
        content: Text(
          'Rate Shhh! Who Is It? will open when store integration is added.',
          style: GoogleFonts.inter(color: AppColors.accentAmber),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required String title,
    required String description,
    required bool isActive,
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isActive
          ? onTap
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.bgSurface,
                  content: Text(
                    '$title is locked for now.',
                    style: GoogleFonts.inter(color: AppColors.accentAmber),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
      child: AppGlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: AppRadius.lg,
        borderColor: isActive ? color : AppColors.borderSide.color,
        borderWidth: isActive ? 1.2 : 0.6,
        shadowAlpha: isActive ? 0.1 : 0.05,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive ? color.withValues(alpha: 0.16) : AppColors.bgPrimary.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: isActive
                        ? (color == AppColors.suspectRed
                            ? AppShadows.suspectGlow(alpha: 0.12)
                            : AppShadows.detectiveGlow(alpha: 0.12))
                        : null,
                  ),
                  child: Icon(icon, color: isActive ? color : AppColors.textSecondary, size: 22),
                ),
                if (!isActive)
                  const Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                    size: 16,
                  )
                else
                  AppAnimatedChip(
                    label: 'Classic',
                    selected: true,
                    compact: true,
                    borderColor: color,
                    leadingIcon: Icons.bolt_rounded,
                  ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate(target: isActive ? 1.0 : 0.95).scale(duration: 300.ms);
  }

  void _showHowToPlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF243144), width: 0.5),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'HOW TO PLAY',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.detectiveBlue,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTutorialStep(
                  stepNum: '1',
                  title: 'Pass the Phone',
                  desc: 'Gather 3-15 players. Set names, categories, and start. Pass the phone around secretly.',
                ),
                _buildTutorialStep(
                  stepNum: '2',
                  title: 'Secret Roles',
                  desc: 'Civilians get a Secret Word. Impostors get the category context plus a broad hint, so they have something to work with without seeing the answer.',
                ),
                _buildTutorialStep(
                  stepNum: '3',
                  title: 'Give Clues',
                  desc: 'In turns, everyone says ONE word/phrase related to their card. Impostors must blend in!',
                ),
                _buildTutorialStep(
                  stepNum: '4',
                  title: 'Vote & Deduce',
                  desc: 'Discuss and vote out the suspect. If you catch the Impostor, they get ONE guess at the Secret Word to steal the win!',
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.detectiveBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'GOT IT!',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTutorialStep({
    required String stepNum,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.detectiveBlue.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.detectiveBlue, width: 1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNum,
                style: GoogleFonts.spaceMono(
                  fontWeight: FontWeight.bold,
                  color: AppColors.detectiveBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

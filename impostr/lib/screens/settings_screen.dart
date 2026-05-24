import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/app_settings_provider.dart';
import '../theme/app_radius.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'SETTINGS',
          style: GoogleFonts.spaceMono(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: AppColors.accentPurple,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _Section(
              title: 'ADS',
              children: [
                _SwitchTile(
                  title: 'Enable ads',
                  subtitle: 'Reserved for future monetization',
                  value: settings.adsEnabled,
                  onChanged: (value) => ref.read(appSettingsProvider.notifier).setAdsEnabled(value),
                ),
                _SwitchTile(
                  title: 'Personalized ads',
                  subtitle: 'Ads tailored to your profile',
                  value: settings.personalizedAds,
                  onChanged: (value) => ref.read(appSettingsProvider.notifier).setPersonalizedAds(value),
                ),
              ],
            ),
            _Section(
              title: 'GAME',
              children: [
                _SwitchTile(
                  title: 'Vibration',
                  subtitle: 'Haptic feedback for key moments',
                  value: settings.vibrationEnabled,
                  onChanged: (value) => ref.read(appSettingsProvider.notifier).setVibrationEnabled(value),
                ),
                _SwitchTile(
                  title: 'Animations',
                  subtitle: 'Light UI motion and transitions',
                  value: settings.animationsEnabled,
                  onChanged: (value) => ref.read(appSettingsProvider.notifier).setAnimationsEnabled(value),
                ),
                _SwitchTile(
                  title: 'Low performance mode',
                  subtitle: 'Reduce visual effects for weaker devices',
                  value: settings.lowPerformanceMode,
                  onChanged: (value) => ref.read(appSettingsProvider.notifier).setLowPerformanceMode(value),
                ),
              ],
            ),
            _Section(
              title: 'LEGAL',
              children: [
                _ActionTile(title: 'Privacy Policy', onTap: () => context.push('/privacy-policy')),
                _ActionTile(title: 'Terms', onTap: () => context.push('/terms')),
                _ActionTile(title: 'About', onTap: () => context.push('/about')),
                _ActionTile(title: 'Version', onTap: () => _showInfo(context, 'Version 1.0.0')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.bgSurface,
        content: Text(message, style: GoogleFonts.inter(color: AppColors.textPrimary)),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.accentPurple,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.borderSide.color, width: 0.6),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.spaceGrotesk(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

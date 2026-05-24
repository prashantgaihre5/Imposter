import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/app_settings_provider.dart';
import '../theme/app_radius.dart';
import '../theme/app_theme.dart';

class SettingsBottomSheet extends ConsumerWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('SETTINGS', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _Section(title: 'ADS', children: [
              SwitchListTile.adaptive(
                value: settings.adsEnabled,
                contentPadding: EdgeInsets.zero,
                title: const Text('Ads enabled'),
                onChanged: (value) => ref.read(appSettingsProvider.notifier).setAdsEnabled(value),
              ),
              SwitchListTile.adaptive(
                value: settings.personalizedAds,
                contentPadding: EdgeInsets.zero,
                title: const Text('Personalized ads'),
                onChanged: (value) => ref.read(appSettingsProvider.notifier).setPersonalizedAds(value),
              ),
            ]),
            _Section(title: 'GAME', children: [
              SwitchListTile.adaptive(
                value: settings.vibrationEnabled,
                contentPadding: EdgeInsets.zero,
                title: const Text('Vibration'),
                onChanged: (value) => ref.read(appSettingsProvider.notifier).setVibrationEnabled(value),
              ),
              SwitchListTile.adaptive(
                value: settings.animationsEnabled,
                contentPadding: EdgeInsets.zero,
                title: const Text('Animations'),
                onChanged: (value) => ref.read(appSettingsProvider.notifier).setAnimationsEnabled(value),
              ),
              SwitchListTile.adaptive(
                value: settings.lowPerformanceMode,
                contentPadding: EdgeInsets.zero,
                title: const Text('Low performance mode'),
                onChanged: (value) => ref.read(appSettingsProvider.notifier).setLowPerformanceMode(value),
              ),
            ]),
            _Section(title: 'LEGAL', children: [
              _ActionRow(label: 'Privacy Policy', onTap: () => context.push('/privacy-policy')),
              _ActionRow(label: 'Terms & Conditions', onTap: () => context.push('/terms')),
              _ActionRow(label: 'About', onTap: () => context.push('/about')),
              _ActionRow(label: 'Version', onTap: () => _showInfo(context, 'Version 1.0.0')),
            ]),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: GoogleFonts.spaceMono(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accentPurple)),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}

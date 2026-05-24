import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'PRIVACY POLICY',
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
          children: const [
            _PolicyHeader(
              title: 'Privacy Policy',
              subtitle: 'How Shhh! Who Is It? handles information on your device.',
              lastUpdated: 'Last updated: June 2025',
            ),
            _PolicySection(
              title: 'Introduction & Who We Are',
              body:
                  'Shhh! Who Is It? is a local party game designed for offline play. This Privacy Policy explains how the app works and what happens to information while you use it. The short version is simple: the free version is built to run locally, without accounts, without cloud sync, and without collecting personal data for marketing or profiling.',
            ),
            _PolicySection(
              title: 'What Data We Collect',
              body:
                  'We do not collect personal data in the app. Shhh! Who Is It? does not ask you to create an account, does not require your name or email address, and does not send gameplay data to our servers. In the free version, the app is fully local and offline, so the information you enter stays on the device you are holding.',
            ),
            _PolicySection(
              title: 'How We Use Data',
              body:
                  'We do not use your data because we do not collect it. There are no online gameplay servers, no analytics dashboards in the free version, and no advertising profile built from your activity. The app only uses local device storage to keep simple preferences and game state where needed.',
            ),
            _PolicySection(
              title: 'Third Party Services',
              body:
                  'The only third party service we rely on is Google Fonts CDN, which is used to load fonts for the app interface. Google Fonts is used for typography only; it is not used to identify you, track gameplay, or build a user profile.',
            ),
            _PolicySection(
              title: 'Children\'s Privacy',
              body:
                  'Shhh! Who Is It? is intended for players aged 13 and older. If a child under 13 uses the app, we recommend parental or guardian guidance. Because the app does not collect personal data or maintain online accounts, there is no child data stored on our servers.',
            ),
            _PolicySection(
              title: 'Data Storage',
              body:
                  'Any saved settings or lightweight game preferences are stored locally on the device only, using SharedPreferences. This means your data remains on your phone or tablet until you remove the app or clear the app data from your device settings.',
            ),
            _PolicySection(
              title: 'Your Rights',
              body:
                  'You have the right to delete the app at any time. Because the app stores data locally on your device only, uninstalling the app or clearing its storage will remove the saved information associated with it.',
            ),
            _PolicySection(
              title: 'Contact Us',
              body:
                  'If you have any privacy questions, please contact us at privacy@shhhwhoisit.app.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyHeader extends StatelessWidget {
  const _PolicyHeader({
    required this.title,
    required this.subtitle,
    required this.lastUpdated,
  });

  final String title;
  final String subtitle;
  final String lastUpdated;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderSide.color, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lastUpdated,
            style: GoogleFonts.spaceMono(
              color: AppColors.accentPurple,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSide.color, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}
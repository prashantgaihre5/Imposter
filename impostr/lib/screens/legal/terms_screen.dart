import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'TERMS & CONDITIONS',
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
            _TermsHeader(
              title: 'Terms & Conditions',
              subtitle: 'The rules for using Shhh! Who Is It? as a local party game.',
              lastUpdated: 'Last updated: June 2025',
            ),
            _TermsSection(
              title: 'Acceptance of Terms',
              body:
                  'By downloading, opening, or using Shhh! Who Is It?, you agree to these Terms & Conditions. If you do not agree with any part of the terms, please do not use the app.',
            ),
            _TermsSection(
              title: 'Description of the App',
              body:
                  'Shhh! Who Is It? is a local party game designed for social play. Version 1 does not include online multiplayer, account systems, leaderboards, or other network-based features.',
            ),
            _TermsSection(
              title: 'Permitted Use',
              body:
                  'You may use the app for personal, non-commercial entertainment. The app is meant for friends, family, and private gatherings where everyone is playing for fun.',
            ),
            _TermsSection(
              title: 'Prohibited Use',
              body:
                  'You may not reverse engineer, decompile, modify, redistribute, or resell the app or its content without permission. You may not use the app in any way that violates law or interferes with the experience of other players.',
            ),
            _TermsSection(
              title: 'Intellectual Property',
              body:
                  'All game content, visual design, brand elements, and written materials in Shhh! Who Is It? are owned by the Shhh! Who Is It? team or its licensors and are protected by applicable intellectual property laws.',
            ),
            _TermsSection(
              title: 'Disclaimer of Warranties',
              body:
                  'The app is provided on an "as is" and "as available" basis. We do not guarantee that the app will always be uninterrupted, error-free, or compatible with every device, although we aim to keep it stable and enjoyable.',
            ),
            _TermsSection(
              title: 'Limitation of Liability',
              body:
                  'To the maximum extent permitted by law, the Shhh! Who Is It? team will not be liable for indirect, incidental, special, or consequential damages arising from the use or inability to use the app.',
            ),
            _TermsSection(
              title: 'Changes to Terms',
              body:
                  'We may update these Terms & Conditions from time to time. When we do, we will revise the Last Updated date and publish the new version in the app or in other official channels as needed.',
            ),
            _TermsSection(
              title: 'Governing Law',
              body:
                  'These terms are intended to be interpreted under International / general jurisdiction principles, subject to any mandatory local laws that apply to you.',
            ),
            _TermsSection(
              title: 'Contact',
              body:
                  'For legal questions, please contact legal@shhhwhoisit.app.',
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsHeader extends StatelessWidget {
  const _TermsHeader({
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

class _TermsSection extends StatelessWidget {
  const _TermsSection({required this.title, required this.body});

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
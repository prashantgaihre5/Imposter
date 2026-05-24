import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  static const _messages = [
    'Finding suspects...',
    'Preparing chaos...',
    'Gathering mystery...',
    'Loading words...',
  ];

  Timer? _timer;
  Timer? _advanceTimer;
  int _index = 0;
  bool _flip = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 650), (_) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % _messages.length;
        _flip = !_flip;
      });
    });
    _advanceTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      context.go('/');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _advanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = _messages[_index];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.borderSide.color, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPurple.withValues(alpha: 0.12),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _flip
                      ? const Icon(Icons.question_mark_rounded, key: ValueKey('question'), size: 48, color: AppColors.accentAmber)
                      : const Icon(Icons.style_rounded, key: ValueKey('card'), size: 48, color: AppColors.accentPurple),
                ),
              ).animate().fadeIn(duration: 260.ms).scale(duration: 260.ms, curve: Curves.easeOutBack).shimmer(delay: 520.ms, duration: 900.ms),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  message,
                  key: ValueKey(message),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ).animate().fadeIn(duration: 180.ms).slideY(begin: 0.08, end: 0),
              ),
              const SizedBox(height: 10),
              Text(
                'Detective mode on.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceMono(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

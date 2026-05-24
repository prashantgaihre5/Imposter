import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../data/models/player.dart';

class CardRevealScreen extends ConsumerStatefulWidget {
  const CardRevealScreen({super.key});

  @override
  ConsumerState<CardRevealScreen> createState() => _CardRevealScreenState();
}

class _CardRevealScreenState extends ConsumerState<CardRevealScreen> {
  late final AppLifecycleListener _lifecycleListener;
  bool _isRevealed = false;
  Timer? _safetyTimer;
  int _secondsRemaining = 4;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Anti-cheat: immediately hide card if app is paused or backgrounds
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
          _hideCard();
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _cancelTimers();
    super.dispose();
  }

  void _cancelTimers() {
    _safetyTimer?.cancel();
    _countdownTimer?.cancel();
  }

  void _revealCard() {
    if (_isRevealed) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _isRevealed = true;
      _secondsRemaining = 4;
    });

    _cancelTimers();
    
    // Safety countdown timer (visual helper)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _countdownTimer?.cancel();
      }
    });

    // Anti-cheat: auto-flip back after 4 seconds
    _safetyTimer = Timer(const Duration(seconds: 4), () {
      _hideCard();
    });
  }

  void _hideCard() {
    if (!_isRevealed) return;
    HapticFeedback.lightImpact();
    _cancelTimers();
    setState(() {
      _isRevealed = false;
    });
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: AppColors.borderSide,
        ),
        title: Text(
          'QUIT GAME?',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.accentRed,
            letterSpacing: 1.5,
          ),
        ),
        content: Text(
          'Are you sure you want to exit and abandon this round? All current progress will be lost.',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'KEEP PLAYING',
              style: GoogleFonts.spaceMono(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              ref.read(gameProvider.notifier).resetGame();
              context.go('/'); // Navigate home
            },
            child: Text(
              'EXIT ROUND',
              style: GoogleFonts.spaceMono(
                color: AppColors.accentRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    // Safeguard
    if (session.players.isEmpty || session.activePlayerRevealIndex >= session.players.length) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activePlayer = session.players[session.activePlayerRevealIndex];
    final isLastPlayer = session.activePlayerRevealIndex == session.players.length - 1;
    final categoryWords = session.categoriesEnabled && session.selectedCategory != null
        ? session.selectedCategory!.words.map((word) => word.text).toList(growable: false)
        : const <String>[];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitDialog();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Active player index header indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CARD REVEAL',
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'PLAYER ${session.activePlayerRevealIndex + 1}/${session.players.length}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentPurple,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),

                // Passing instruction label
                Center(
                  child: Column(
                    children: [
                      Text(
                        'PASS PHONE TO',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceMono(
                          fontSize: 12,
                          letterSpacing: 2,
                          color: AppColors.textSecondary,
                        ),
                      ).animate(key: ValueKey('${activePlayer.id}-prompt')).fadeIn().slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          activePlayer.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: AppColors.accentPurple,
                          ),
                        ),
                      ).animate(key: ValueKey('${activePlayer.id}-name')).fadeIn().scale(curve: Curves.easeOutBack),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Card Layout - 280x420px
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: AspectRatio(
                      aspectRatio: 280 / 420,
                      child: GestureDetector(
                        onTapDown: (_) => _revealCard(),
                        onTapUp: (_) => _hideCard(),
                        onTapCancel: () => _hideCard(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.bgSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isRevealed
                                  ? (activePlayer.role == PlayerRole.impostor
                                      ? AppColors.accentRed
                                      : AppColors.accentGreen)
                                  : AppColors.accentPurple,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _isRevealed
                                    ? (activePlayer.role == PlayerRole.impostor
                                        ? AppColors.accentRed.withValues(alpha: 0.15)
                                        : AppColors.accentGreen.withValues(alpha: 0.15))
                                    : AppColors.accentPurple.withValues(alpha: 0.15),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Stack(
                        children: [
                          // 1. Back of the Card (Unrevealed state)
                          if (!_isRevealed)
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.fingerprint,
                                    size: 80,
                                    color: AppColors.accentPurple,
                                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                                   .scale(end: const Offset(1.1, 1.1), duration: 1000.ms, curve: Curves.easeInOut),
                                  const SizedBox(height: 24),
                                  Text(
                                    'HOLD TO REVEAL',
                                    style: GoogleFonts.spaceMono(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                    child: Text(
                                      'Keep screen hidden from other players!',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // 2. Front of the Card (Revealed state)
                          if (_isRevealed)
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'SHHH SYSTEM',
                                        style: GoogleFonts.spaceMono(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.bgInput,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.fromBorderSide(AppColors.borderSide),
                                        ),
                                        child: Text(
                                          '${_secondsRemaining}s SECURE',
                                          style: GoogleFonts.spaceMono(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.accentAmber,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(flex: 2),

                                  // Core secrets
                                  if (activePlayer.role == PlayerRole.civilian) ...[
                                    Center(
                                      child: Icon(
                                        Icons.verified_user_outlined,
                                        size: 64,
                                        color: AppColors.accentGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: Text(
                                        'YOU ARE CIVILIAN',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.spaceMono(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          color: AppColors.accentGreen,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Center(
                                      child: Text(
                                        'SECRET WORD',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.spaceMono(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Center(
                                      child: Text(
                                        activePlayer.word ?? '',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    Center(
                                      child: Icon(
                                        Icons.warning_amber_rounded,
                                        size: 64,
                                        color: AppColors.accentRed,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: Text(
                                        'YOU ARE IMPOSTOR',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.spaceMono(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          color: AppColors.accentRed,
                                        ),
                                      ),
                                    ),
                                    if (session.categoriesEnabled && session.selectedCategory != null) ...[
                                      const SizedBox(height: 12),
                                      Center(
                                        child: Text(
                                          'CATEGORY',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.spaceMono(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Center(
                                        child: Text(
                                          session.selectedCategory!.name.toUpperCase(),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                    ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: Text(
                                          'POSSIBLE WORDS',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.spaceMono(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Center(
                                        child: Text(
                                          categoryWords.join(' • '),
                                          textAlign: TextAlign.center,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.textPrimary,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ] else ...[
                                      const SizedBox(height: 16),
                                    ],
                                    Center(
                                      child: Text(
                                        'VAGUE HINT',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.spaceMono(
                                          fontSize: 10,
                                          color: AppColors.accentAmber,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Center(
                                      child: Text(
                                        activePlayer.hint ?? '',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],

                                  const Spacer(flex: 3),
                                  Center(
                                    child: Text(
                                      'RELEASE TO HIDE',
                                      style: GoogleFonts.spaceMono(
                                        fontSize: 10,
                                        letterSpacing: 1,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 200.ms),
                        ],
                      ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Action button: Next Player / Finish Reveal
                GestureDetector(
                  onTap: _isRevealed
                      ? null
                      : () {
                          if (isLastPlayer) {
                            notifier.nextReveal(); // Automatically advances phase to Play
                            context.pushReplacement('/play');
                          } else {
                            notifier.nextReveal();
                            setState(() {
                              _isRevealed = false;
                            });
                          }
                        },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: _isRevealed ? AppColors.bgSurface : AppColors.accentPurple,
                      borderRadius: BorderRadius.circular(99),
                        border: _isRevealed
                          ? Border.fromBorderSide(AppColors.borderSide)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        isLastPlayer ? 'START ROUND' : 'NEXT PLAYER',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: _isRevealed ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

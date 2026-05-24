import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../data/models/game_session.dart';

class PlayScreen extends ConsumerWidget {
  const PlayScreen({super.key});

  void _showExitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: AppColors.borderSide,
        ),
        title: Text(
          'QUIT ROUND?',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.accentRed,
            letterSpacing: 1.5,
          ),
        ),
        content: Text(
          'Are you sure you want to end this round and return to setup?',
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
              'CONTINUE',
              style: GoogleFonts.spaceMono(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(gameProvider.notifier).resetGame();
              context.go('/');
            },
            child: Text(
              'QUIT GAME',
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
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    // Reactive route listener: jump to VoteScreen when phase changes to vote
    ref.listen<GameSession>(gameProvider, (previous, next) {
      if (next.phase == GamePhase.reveal && next.roundNumber == 1) {
        context.pushReplacement('/reveal');
        return;
      }
      if (next.phase == GamePhase.vote) {
        context.pushReplacement('/vote');
      }
    });

    if (session.speakerList.isEmpty || session.speakingPlayerIndex >= session.speakerList.length) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentSpeakerId = session.speakerList[session.speakingPlayerIndex];
    final firstSpeakerId = session.speakerList.first;
    final currentSpeakerMatches = session.players.where((p) => p.id == currentSpeakerId).toList();
    final firstSpeakerMatches = session.players.where((p) => p.id == firstSpeakerId).toList();

    if (currentSpeakerMatches.isEmpty || firstSpeakerMatches.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentSpeaker = currentSpeakerMatches.first;
    final firstSpeakerName = firstSpeakerMatches.first.name;

    final bool isLowTime = session.timerEnabled && session.elapsedSeconds <= 5;
    final waitingForAdvance = session.awaitingRoundAdvance;
    final currentRound = waitingForAdvance ? session.completedRounds : session.completedRounds + 1;
    final readyForVote = waitingForAdvance && session.completedRounds >= session.totalRounds;
    
    // Trigger tiny haptic pulse when timer is low
    if (isLowTime && session.elapsedSeconds > 0) {
      HapticFeedback.lightImpact();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitDialog(context, ref);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () => _showExitDialog(context, ref),
          ),
          title: Text(
            'DESCRIBE CLUES',
            style: GoogleFonts.spaceMono(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: AppColors.accentPurple,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {
                notifier.forceEndRound();
              },
              child: Text(
                'END ROUND',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentAmber,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Neon First Speaker Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.3), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentPurple.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.volume_up, color: AppColors.accentPurple, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FIRST SPEAKER IS',
                              style: GoogleFonts.spaceMono(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              firstSpeakerName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ROUND $currentRound OF ${session.totalRounds}',
                              style: GoogleFonts.spaceMono(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentAmber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                 .custom(
                   duration: 1500.ms,
                   builder: (context, value, child) {
                     return Container(
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(16),
                         boxShadow: [
                           BoxShadow(
                             color: AppColors.accentPurple.withValues(alpha: 0.08 * value),
                             blurRadius: 10 * value,
                             spreadRadius: 1,
                           ),
                         ],
                       ),
                       child: child,
                     );
                   },
                 ),
                
                const SizedBox(height: 24),

                // 2. Active Speaker Card
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isLowTime ? AppColors.accentRed : AppColors.accentPurple,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isLowTime
                              ? AppColors.accentRed.withValues(alpha: 0.15)
                              : AppColors.accentPurple.withValues(alpha: 0.05),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'CURRENT SPEAKER',
                          style: GoogleFonts.spaceMono(
                            fontSize: 11,
                            letterSpacing: 2,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            currentSpeaker.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                        ).animate(key: ValueKey(currentSpeaker.id)).fadeIn().scale(curve: Curves.easeOutBack),
                        
                        const SizedBox(height: 24),

                        // Optional Timer Ring / Text
                        if (session.timerEnabled) ...[
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(
                                  value: session.elapsedSeconds / session.timerSeconds,
                                  strokeWidth: 6,
                                  backgroundColor: AppColors.bgInput,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isLowTime ? AppColors.accentRed : AppColors.accentGreen,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${session.elapsedSeconds}',
                                      maxLines: 1,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: isLowTime ? AppColors.accentRed : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'seconds',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ).animate(target: isLowTime ? 1.0 : 0.0)
                           .shake(duration: 500.ms, hz: 4)
                           .scaleXY(end: 1.05, duration: 250.ms, curve: Curves.easeInOut),
                        ] else ...[
                          const Icon(
                            Icons.mic_none,
                            size: 64,
                            color: AppColors.accentPurple,
                          ).animate(onPlay: (c) => c.repeat(reverse: true))
                           .scale(end: const Offset(1.1, 1.1), duration: 1200.ms, curve: Curves.easeInOut),
                        ],
                        
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Say ONE word or simple phrase to describe your card. Do not write or say the word itself!',
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Speaker Timeline List
                Text(
                  'SPEAKER TIMELINE',
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.fromBorderSide(AppColors.borderSide),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: ListView.builder(
                      itemCount: session.speakerList.length,
                      itemBuilder: (context, index) {
                        final id = session.speakerList[index];
                          final matches = session.players.where((player) => player.id == id).toList();
                          if (matches.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final p = matches.first;
                        
                        final isSpoken = index < session.speakingPlayerIndex;
                        final isCurrent = index == session.speakingPlayerIndex;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isCurrent ? AppColors.accentPurple.withValues(alpha: 0.08) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isCurrent
                                  ? Border.all(color: AppColors.accentPurple, width: 0.5)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '#${index + 1}',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 12,
                                    color: isCurrent ? AppColors.accentPurple : AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSpoken
                                          ? AppColors.textSecondary.withValues(alpha: 0.5)
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (isSpoken)
                                  const Icon(Icons.check_circle_outline, color: AppColors.accentGreen, size: 18)
                                else if (isCurrent)
                                  const Icon(Icons.mic, color: AppColors.accentPurple, size: 18)
                                else
                                  Icon(Icons.hourglass_empty, color: AppColors.textSecondary.withValues(alpha: 0.3), size: 18),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 4. Next Speaker Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    if (waitingForAdvance) {
                      if (readyForVote) {
                        notifier.continueToNextRound();
                      } else {
                        notifier.startNextRound(roundsSinceVote: 0);
                      }
                    } else {
                      notifier.nextSpeaker();
                    }
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Center(
                      child: Text(
                        waitingForAdvance
                            ? (readyForVote ? 'TIME TO VOTE →' : 'NEXT ROUND')
                            : 'NEXT SPEAKER',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

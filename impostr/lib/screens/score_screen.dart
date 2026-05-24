import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../data/models/game_session.dart';
import '../data/models/player.dart';
import '../widgets/app_glass_card.dart';

class ScoreScreen extends ConsumerWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    // Reactive route listener: transition to setup screen when phase resets
    ref.listen<GameSession>(gameProvider, (previous, next) {
      if (next.phase == GamePhase.setup || next.phase == GamePhase.home) {
        context.go('/setup');
      }
    });

    if (session.players.isEmpty || session.eliminatedPlayerId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Sort players by score (descending)
    final sortedPlayers = [...session.players]..sort((a, b) => b.score.compareTo(a.score));
    final maxScore = sortedPlayers.first.score == 0 ? 1 : sortedPlayers.first.score;

    final votedOutIds = session.eliminatedPlayerIds.isNotEmpty
      ? session.eliminatedPlayerIds
      : (session.eliminatedPlayerId == null ? <String>[] : [session.eliminatedPlayerId!]);
    final votedOutNames = votedOutIds
      .map((id) => session.players.where((player) => player.id == id).map((player) => player.name).toList())
      .expand((names) => names)
      .toList();
    final remainingImpostors = session.players.where((player) => player.role == PlayerRole.impostor && !player.isEliminated).length;
    final gameOver = remainingImpostors == 0 || session.completedRounds >= session.totalRounds;

    final impostorMatches = session.players.where((p) => p.role == PlayerRole.impostor).toList();
    if (impostorMatches.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final impostorPlayer = impostorMatches.first;

    final eliminatedMatches = session.players.where((p) => p.id == session.eliminatedPlayerId).toList();
    if (eliminatedMatches.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final eliminatedPlayer = eliminatedMatches.first;

    // Deducing win state
    final caughtImpostor = eliminatedPlayer.role == PlayerRole.impostor;
    final impostorGuessedWord = session.impostorGuessedCorrectly ?? false;
    final civilianTeamWon = caughtImpostor && !impostorGuessedWord;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Suspenseful outcome banner
              Center(
                child: Column(
                  children: [
                    Text(
                      'ROUND COMPLETED',
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        civilianTeamWon ? 'CIVILIANS WIN' : 'IMPOSTOR WINS',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: civilianTeamWon ? AppColors.accentGreen : AppColors.accentRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 1. Round breakdown card
              AppGlassCard(
                padding: const EdgeInsets.all(20),
                borderColor: civilianTeamWon ? AppColors.accentGreen : AppColors.accentRed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ROUND STATISTICS',
                      style: GoogleFonts.spaceMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                    const Divider(color: Color(0xFF2E2E38), height: 20, thickness: 0.5),
                    _buildStatRow('Secret Word', session.secretWord ?? '', isHighlight: true),
                    _buildStatRow('Voted Out', votedOutNames.isEmpty ? 'None' : votedOutNames.join(', ')),
                    _buildStatRow('Impostor', impostorPlayer.name, color: AppColors.accentRed),
                    _buildStatRow(
                      'Impostor Guess',
                      impostorGuessedWord ? 'Correct' : 'Incorrect / None',
                      color: impostorGuessedWord ? AppColors.accentGreen : AppColors.textSecondary,
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: 32),

              // 2. Leaderboard Title
              Text(
                'RANKINGS LEADERBOARD',
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Animated ranking bars
              AppGlassCard(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedPlayers.length,
                  itemBuilder: (context, index) {
                    final player = sortedPlayers[index];
                    final rank = index + 1;
                    final isTopRank = rank == 1;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '#$rank',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceMono(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isTopRank ? AppColors.accentAmber : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  player.name.toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${player.score} PTS',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isTopRank ? AppColors.accentPurple : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          
                          // Score ratio bar
                          Stack(
                            children: [
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.bgInput,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final width = constraints.maxWidth * (player.score / maxScore);
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.easeOutCubic,
                                    width: width,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isTopRank ? AppColors.accentPurple : AppColors.accentGreen,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 32),

              // 3. Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _shareResults(context, sortedPlayers);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                          side: AppColors.borderSide,
                        ),
                        backgroundColor: AppColors.bgSurface,
                      ),
                      child: Text(
                        'SHARE',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        if (gameOver) {
                          notifier.playAgain();
                          context.go('/setup');
                        } else {
                          notifier.startNextRound(roundsSinceVote: 0);
                          context.go('/play');
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                        ),
                        backgroundColor: AppColors.accentPurple,
                      ),
                      child: Text(
                        gameOver ? 'PLAY AGAIN' : 'NEXT ROUND',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Full Reset / Restart Button
              TextButton(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  notifier.resetGame();
                  notifier.playAgain();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                child: Text(
                  'RESET ENTIRE GAME',
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentRed,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceMono(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isHighlight
                    ? GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold, color: color ?? AppColors.textPrimary)
                    : GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareResults(BuildContext context, List<Player> rankings) {
    // Generate text summaries
    final StringBuffer shareText = StringBuffer();
    shareText.writeln('🏆 Shhh! Who Is It? Leaderboard 🏆');
    for (int i = 0; i < rankings.length; i++) {
      shareText.writeln('#${i + 1} ${rankings[i].name} - ${rankings[i].score} pts');
    }
    shareText.writeln('\nPlay Shhh! Who Is It? on Android!');

    Clipboard.setData(ClipboardData(text: shareText.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.bgSurface,
        content: Text(
          'Rankings copied to clipboard! Share it with your friends.',
          style: GoogleFonts.inter(color: AppColors.accentPurple),
        ),
      ),
    );
  }
}

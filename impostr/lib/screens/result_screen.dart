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
import '../utils/game_engine.dart';
import '../widgets/app_glass_card.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final TextEditingController _guessController = TextEditingController();
  bool _revealed = false;

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  void _revealRole() {
    if (_revealed) return;
    HapticFeedback.vibrate();
    setState(() {
      _revealed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    // Reactive route listener: transition to ScoreScreen when phase is score
    ref.listen<GameSession>(gameProvider, (previous, next) {
      if (next.phase == GamePhase.score) {
        context.pushReplacement('/score');
      }
    });

    final votedPlayerIds = session.eliminatedPlayerIds.isNotEmpty
        ? session.eliminatedPlayerIds
        : (session.eliminatedPlayerId == null ? <String>[] : [session.eliminatedPlayerId!]);
    final selectedPlayers = session.players.where((player) => votedPlayerIds.contains(player.id)).toList();
    final activeImpostorIds = session.players
        .where((player) => player.role == PlayerRole.impostor && !player.isEliminated)
        .map((player) => player.id)
        .toList();
    final voteResult = session.voteResult ?? GameEngine.checkVoteResult(votedPlayerIds, activeImpostorIds);
    final hasCaughtImpostor = selectedPlayers.any((player) => player.role == PlayerRole.impostor);

    // Safeguards
    if (session.players.isEmpty || votedPlayerIds.isEmpty || selectedPlayers.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final primarySelectedPlayer = selectedPlayers.first;
  final primaryIsImpostor = primarySelectedPlayer.role == PlayerRole.impostor;
  final allImpostorsCaught = voteResult == 'full_win';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Eliminating suspense banner
              Center(
                child: Text(
                  'VOTED PLAYER INQUEST',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Dramatic Suspense Card
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: AspectRatio(
                    aspectRatio: 280 / 320,
                    child: GestureDetector(
                      onTap: _revealRole,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _revealed
                                ? (primaryIsImpostor ? AppColors.accentGreen : AppColors.accentRed)
                                : AppColors.accentPurple,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _revealed
                                  ? (primaryIsImpostor
                                      ? AppColors.accentGreen.withValues(alpha: 0.1)
                                      : AppColors.accentRed.withValues(alpha: 0.1))
                                  : AppColors.accentPurple.withValues(alpha: 0.05),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Stack(
                      children: [
                        if (!_revealed)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.lock_open,
                                  size: 64,
                                  color: AppColors.accentPurple,
                                ).animate(onPlay: (c) => c.repeat(reverse: true))
                                .scale(end: const Offset(1.1, 1.1), duration: 1000.ms, curve: Curves.easeInOut),
                                const SizedBox(height: 16),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    primarySelectedPlayer.name.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'TAP TO REVEAL ROLE',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: AppColors.accentPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_revealed)
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Icon(
                                    primaryIsImpostor ? Icons.gavel : Icons.heart_broken,
                                    size: 64,
                                    color: primaryIsImpostor ? AppColors.accentGreen : AppColors.accentRed,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: Text(
                                    primarySelectedPlayer.name.toUpperCase(),
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: primaryIsImpostor
                                          ? AppColors.accentGreen.withValues(alpha: 0.15)
                                          : AppColors.accentRed.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(99),
                                      border: Border.all(
                                          color: primaryIsImpostor ? AppColors.accentGreen : AppColors.accentRed,
                                        width: 0.5,
                                      ),
                                    ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          primaryIsImpostor ? 'WAS THE IMPOSTOR' : 'WAS CIVILIAN',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.spaceMono(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: primaryIsImpostor ? AppColors.accentGreen : AppColors.accentRed,
                                          ),
                                        ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 300.ms).scale(duration: 300.ms, curve: Curves.easeOutBack),
                      ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Conditional Results Action Inputs
              if (_revealed) ...[
                AppGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'SELECTED PLAYERS',
                        style: GoogleFonts.spaceMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...selectedPlayers.map((player) {
                        final isImpostorPlayer = player.role == PlayerRole.impostor;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  player.name.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isImpostorPlayer
                                      ? AppColors.accentGreen.withValues(alpha: 0.15)
                                      : AppColors.accentRed.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: isImpostorPlayer ? AppColors.accentGreen : AppColors.accentRed,
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  isImpostorPlayer ? 'IMPOSTOR' : 'CIVILIAN',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isImpostorPlayer ? AppColors.accentGreen : AppColors.accentRed,
                                  ),
                                ),
                              ),
                            ],
                          ).animate(delay: (80 * selectedPlayers.indexOf(player)).ms).fadeIn().slideX(begin: 0.05, end: 0),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                AppGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'POINTS BREAKDOWN',
                        style: GoogleFonts.spaceMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (voteResult == 'wrong_vote') ...[
                        ...session.players.where((player) => player.role == PlayerRole.impostor && !player.isEliminated).map((player) {
                          return _buildScoreLine(player.name, '+2', AppColors.accentGreen);
                        }),
                      ] else ...[
                        ...session.players.where((player) => player.role == PlayerRole.civilian).map((player) {
                          final delta = session.voteResult == 'full_win' || session.voteResult == 'partial_win'
                              ? (session.impostorGuessedCorrectly == true ? '+1' : '+2')
                              : '+0';
                          final color = session.impostorGuessedCorrectly == true ? AppColors.accentAmber : AppColors.accentGreen;
                          return _buildScoreLine(player.name, delta, color);
                        }),
                        ...selectedPlayers.where((player) => player.role == PlayerRole.impostor).map((player) {
                          final delta = session.impostorGuessedCorrectly == true ? '+1' : '+0';
                          return _buildScoreLine(player.name, delta, AppColors.accentPurple);
                        }),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (voteResult == 'wrong_vote') ...[
                  AppGlassCard(
                    padding: const EdgeInsets.all(20),
                    borderColor: AppColors.accentRed,
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.accentRed, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'IMPOSTORS WIN!',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentRed,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'The Civilians mistakenly banished an innocent teammate. The Impostors successfully blended in!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.skipImpostorGuess();
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Center(
                        child: Text(
                          'SEE LEADERBOARD',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ] else ...[
                  Text(
                    hasCaughtImpostor
                        ? (allImpostorsCaught ? 'LAST GASP GUESS' : 'CAUGHT IMPOSTOR GUESSES')
                        : 'LAST GASP GUESS',
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.fromBorderSide(AppColors.borderSide),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          allImpostorsCaught
                              ? 'The Civilians caught every Impostor in the vote! One final guess can still swing the leaderboard.'
                              : 'At least one selected player was an Impostor. They get one last chance to guess the secret word and steal points.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _guessController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'Enter your guess here...',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  notifier.skipImpostorGuess();
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(99),
                                    side: AppColors.borderSide,
                                  ),
                                  backgroundColor: AppColors.bgInput,
                                ),
                                child: Text(
                                  'GIVE UP',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  final guess = _guessController.text.trim();
                                  if (guess.isNotEmpty) {
                                    HapticFeedback.mediumImpact();
                                    notifier.submitImpostorGuess(guess);
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  backgroundColor: AppColors.accentGreen,
                                ),
                                child: Text(
                                  'SUBMIT GUESS',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreLine(String name, String delta, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            delta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceMono(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.04, end: 0);
  }
}

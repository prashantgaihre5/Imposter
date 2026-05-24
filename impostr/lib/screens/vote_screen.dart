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

class VoteScreen extends ConsumerStatefulWidget {
  const VoteScreen({super.key});

  @override
  ConsumerState<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends ConsumerState<VoteScreen> {
  final Set<String> _selectedPlayerIds = <String>{};

  void _confirmElimination(BuildContext context, List<Player> targets) {
    HapticFeedback.mediumImpact();
    final targetNames = targets.map((player) => player.name.toUpperCase()).join(', ');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.accentRed, width: 0.5),
        ),
        title: Text(
          'ELIMINATE $targetNames?',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.accentRed,
            letterSpacing: 1.5,
          ),
        ),
        content: Text(
          'Are you absolutely sure you want to eliminate these players? This will reveal all selected roles at once.',
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
              'CANCEL',
              style: GoogleFonts.spaceMono(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              ref.read(gameProvider.notifier).eliminatePlayers(targets.map((player) => player.id).toList());
            },
            child: Text(
              'CONFIRM',
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

    // Reactive route listener: transition to results when phase is result
    ref.listen<GameSession>(gameProvider, (previous, next) {
      if (next.phase == GamePhase.result) {
        context.pushReplacement('/result');
      }
    });

    final activePlayers = session.players.where((p) => !p.isEliminated).toList();
    final aliveImpostors = session.players.where((p) => p.role == PlayerRole.impostor && !p.isEliminated).length;
    final selectionLimit = aliveImpostors;
    final selectedPlayers = activePlayers.where((p) => _selectedPlayerIds.contains(p.id)).toList();
    final selectedCount = selectedPlayers.length;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Suspense header
              Center(
                child: Column(
                  children: [
                    Text(
                      'THE ROUND VOTE',
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
                        'ELIMINATE SUSPECT',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: AppColors.accentRed,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Discuss together, then select up to $selectionLimit players you believe are the Impostors.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Player Grids to Vote
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: activePlayers.length,
                  itemBuilder: (context, index) {
                    final player = activePlayers[index];
                    final isSelected = _selectedPlayerIds.contains(player.id);

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          if (_selectedPlayerIds.contains(player.id)) {
                            _selectedPlayerIds.remove(player.id);
                          } else if (_selectedPlayerIds.length < selectionLimit) {
                            _selectedPlayerIds.add(player.id);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.accentRed : const Color(0xFF2E2E38),
                            width: isSelected ? 2.0 : 0.5,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppColors.accentRed.withValues(alpha: 0.15),
                                blurRadius: 10,
                              ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.face,
                                  color: isSelected ? AppColors.accentRed : AppColors.textSecondary,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      player.name.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                              if (isSelected)
                              const Positioned(
                                top: 0,
                                right: 0,
                                child: Icon(
                                  Icons.gps_fixed,
                                  color: AppColors.accentRed,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              Text(
                '$selectedCount selected / $selectionLimit allowed',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceMono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 12),

              // Eliminate Button
              GestureDetector(
                onTap: selectedPlayers.isEmpty
                    ? null
                    : () {
                        _confirmElimination(context, selectedPlayers);
                      },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: selectedPlayers.isNotEmpty ? AppColors.accentRed : AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(99),
                    border: selectedPlayers.isNotEmpty ? null : Border.fromBorderSide(AppColors.borderSide),
                    boxShadow: [
                      if (selectedPlayers.isNotEmpty)
                        BoxShadow(
                          color: AppColors.accentRed.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'ELIMINATE',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: selectedPlayers.isNotEmpty ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ).animate(target: selectedPlayers.isNotEmpty ? 1.0 : 0.95).scale(duration: 200.ms),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

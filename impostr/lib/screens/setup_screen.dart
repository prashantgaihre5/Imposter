import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_glass_card.dart';
import '../widgets/app_neon_button.dart';
import '../widgets/app_animated_chip.dart';
import '../features/categories/widgets/category_selection_card.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final TextEditingController _playerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void dispose() {
    _playerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _playerController.text.trim();
    if (name.isNotEmpty) {
      ref.read(gameProvider.notifier).addPlayer(name);
      _playerController.clear();
      // Scroll to the end of player list
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    final categories = ref.watch(allCategoriesProvider);
    final impostorCount = notifier.setupImpostorCount;
    final maxImpostorCount = notifier.maxImpostorCount;
    final totalRounds = session.totalRounds;
    final canStart = session.players.length >= 3;

    final filteredCategories = categories.where((cat) {
      return cat.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cat.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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
          'ROUND SETUP',
          style: GoogleFonts.spaceMono(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: AppColors.accentPurple,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
              // 1. Players Section
              _buildSectionHeader('PLAYERS', '${session.players.length}/15'),
              const SizedBox(height: 8),
              
              // Input Field
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 360;
                  final addButton = GestureDetector(
                    onTap: _addPlayer,
                    child: Container(
                      width: stacked ? double.infinity : 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.add, color: AppColors.textPrimary),
                    ),
                  );

                  final textField = TextField(
                    controller: _playerController,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 12,
                    buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                    onSubmitted: (_) => _addPlayer(),
                    decoration: const InputDecoration(
                      hintText: 'Enter player name...',
                    ),
                  );

                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        textField,
                        const SizedBox(height: 12),
                        addButton,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: textField),
                      const SizedBox(width: 12),
                      addButton,
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),

              // Chip list
              if (session.players.isEmpty)
                AppGlassCard(
                  child: Center(
                      child: Text(
                        'No players added yet. Add at least 3!',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                      ),
                  ),
                )
              else
                AppGlassCard(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: session.players.length,
                    itemBuilder: (context, index) {
                      final player = session.players[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.bgInput,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.fromBorderSide(AppColors.borderSide),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                player.name,
                                style: GoogleFonts.spaceMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => notifier.removePlayer(player.id),
                                child: const Icon(
                                  Icons.cancel,
                                  size: 14,
                                  color: AppColors.accentRed,
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

              Column(
                children: [
                  Container(
                    width: double.infinity,
                    clipBehavior: Clip.hardEdge,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2D2D35), width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IMPOSTORS',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: LayoutBuilder(builder: (context, constraints) {
                            // If there's plenty of horizontal space, keep controls in a row,
                            // otherwise stack vertically to avoid overflow.
                            final useRow = constraints.maxWidth > 360;
                            return useRow
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: impostorCount > 1 ? () => notifier.setImpostorCount(impostorCount - 1) : null,
                                        child: Opacity(
                                          opacity: impostorCount > 1 ? 1.0 : 0.3,
                                          child: Container(
                                            width: 48,
                                            height: 48,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF242429),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.remove, color: Color(0xFF7C3AED), size: 20),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Flexible(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                '$impostorCount',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.spaceGrotesk(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFFF9FAFB),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                impostorCount == 1 ? '1 Impostor' : '$impostorCount Impostors',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.spaceGrotesk(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(0xFF9CA3AF),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'Max ${session.players.length - 1}',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.spaceMono(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(0xFF4B5563),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      GestureDetector(
                                        onTap: impostorCount < maxImpostorCount ? () => notifier.setImpostorCount(impostorCount + 1) : null,
                                        child: Opacity(
                                          opacity: impostorCount < maxImpostorCount ? 1.0 : 0.3,
                                          child: Container(
                                            width: 48,
                                            height: 48,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF242429),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.add, color: Color(0xFF7C3AED), size: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: impostorCount > 1 ? () => notifier.setImpostorCount(impostorCount - 1) : null,
                                            child: Opacity(
                                              opacity: impostorCount > 1 ? 1.0 : 0.3,
                                              child: Container(
                                                width: 48,
                                                height: 48,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF242429),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.remove, color: Color(0xFF7C3AED), size: 20),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Flexible(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    '$impostorCount',
                                                    style: GoogleFonts.spaceGrotesk(
                                                      fontSize: 28,
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(0xFFF9FAFB),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    impostorCount == 1 ? '1 Impostor' : '$impostorCount Impostors',
                                                    style: GoogleFonts.spaceGrotesk(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: const Color(0xFF9CA3AF),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          GestureDetector(
                                            onTap: impostorCount < maxImpostorCount ? () => notifier.setImpostorCount(impostorCount + 1) : null,
                                            child: Opacity(
                                              opacity: impostorCount < maxImpostorCount ? 1.0 : 0.3,
                                              child: Container(
                                                width: 48,
                                                height: 48,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF242429),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.add, color: Color(0xFF7C3AED), size: 20),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Max ${session.players.length - 1}',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.spaceMono(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF4B5563),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    clipBehavior: Clip.hardEdge,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.fromBorderSide(AppColors.borderSide),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CLUE TIMER',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.spaceMono(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                              width: 36,
                              child: Switch(
                                value: session.timerEnabled,
                                onChanged: (val) => notifier.toggleTimer(val),
                                activeThumbColor: AppColors.accentPurple,
                                activeTrackColor: AppColors.accentPurple.withValues(alpha: 0.3),
                                inactiveThumbColor: AppColors.textSecondary,
                                inactiveTrackColor: AppColors.bgInput,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(builder: (context, constraints) {
                          final useRow = constraints.maxWidth > 300;
                          return useRow
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: session.timerEnabled && session.timerSeconds > 15
                                          ? () => notifier.setTimerSeconds(session.timerSeconds - 15)
                                          : null,
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.bgInput,
                                          shape: BoxShape.circle,
                                          border: Border.fromBorderSide(AppColors.borderSide),
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          size: 20,
                                          color: session.timerEnabled && session.timerSeconds > 15
                                              ? AppColors.textPrimary
                                              : AppColors.textSecondary.withValues(alpha: 0.3),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${session.timerSeconds}s',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: session.timerEnabled ? AppColors.accentGreen : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: session.timerEnabled && session.timerSeconds < 120
                                          ? () => notifier.setTimerSeconds(session.timerSeconds + 15)
                                          : null,
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.bgInput,
                                          shape: BoxShape.circle,
                                          border: Border.fromBorderSide(AppColors.borderSide),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 20,
                                          color: session.timerEnabled && session.timerSeconds < 120
                                              ? AppColors.textPrimary
                                              : AppColors.textSecondary.withValues(alpha: 0.3),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: session.timerEnabled && session.timerSeconds > 15
                                              ? () => notifier.setTimerSeconds(session.timerSeconds - 15)
                                              : null,
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: AppColors.bgInput,
                                              shape: BoxShape.circle,
                                              border: Border.fromBorderSide(AppColors.borderSide),
                                            ),
                                            child: Icon(
                                              Icons.remove,
                                              size: 20,
                                              color: session.timerEnabled && session.timerSeconds > 15
                                                  ? AppColors.textPrimary
                                                  : AppColors.textSecondary.withValues(alpha: 0.3),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '${session.timerSeconds}s',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: session.timerEnabled ? AppColors.accentGreen : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        GestureDetector(
                                          onTap: session.timerEnabled && session.timerSeconds < 120
                                              ? () => notifier.setTimerSeconds(session.timerSeconds + 15)
                                              : null,
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: AppColors.bgInput,
                                              shape: BoxShape.circle,
                                              border: Border.fromBorderSide(AppColors.borderSide),
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              size: 20,
                                              color: session.timerEnabled && session.timerSeconds < 120
                                                  ? AppColors.textPrimary
                                                  : AppColors.textSecondary.withValues(alpha: 0.3),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    clipBehavior: Clip.hardEdge,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2D2D35), width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ROUNDS',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: totalRounds > 1 ? () => notifier.setTotalRounds(totalRounds - 1) : null,
                                child: Opacity(
                                  opacity: totalRounds > 1 ? 1.0 : 0.3,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF242429),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.remove, color: Color(0xFF7C3AED), size: 20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 32),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$totalRounds',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFF9FAFB),
                                    ),
                                  ),
                                  Text(
                                    totalRounds == 1 ? '1 Round' : '$totalRounds Rounds',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                  Text(
                                    'Max 5',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 32),
                              GestureDetector(
                                onTap: totalRounds < 5 ? () => notifier.setTotalRounds(totalRounds + 1) : null,
                                child: Opacity(
                                  opacity: totalRounds < 5 ? 1.0 : 0.3,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF242429),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add, color: Color(0xFF7C3AED), size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Category Grid Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('CATEGORY', ''),
                  Row(
                    children: [
                      Text(
                        session.categoriesEnabled ? 'ON' : 'OFF',
                        style: GoogleFonts.spaceMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: session.categoriesEnabled ? AppColors.accentGreen : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: session.categoriesEnabled,
                        onChanged: notifier.toggleCategoryMode,
                        activeThumbColor: AppColors.accentGreen,
                        activeTrackColor: AppColors.accentGreen.withValues(alpha: 0.3),
                        inactiveThumbColor: AppColors.textSecondary,
                        inactiveTrackColor: AppColors.bgInput,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppNeonButton(
                label: 'START GAME',
                active: canStart,
                borderColor: canStart ? null : AppColors.borderSide.color,
                onPressed: () {
                  notifier.startGame();
                  if (context.mounted) {
                    context.push('/reveal');
                  }
                },
              ),
              const SizedBox(height: 12),
              if (!session.categoriesEnabled)
                AppGlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category mode is off',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'The engine will mix words from every category for a less predictable round.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    if (session.selectedCategoryIds.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'SELECTED CATEGORIES',
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: session.selectedCategoryIds.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final categoryId = session.selectedCategoryIds[index];
                            final matching = categories.where((cat) => cat.id == categoryId).toList();
                            if (matching.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            final category = matching.first;
                            return AppAnimatedChip(
                              label: category.name,
                              selected: true,
                              compact: true,
                              borderColor: Color(category.color),
                              leadingIcon: Icons.check_rounded,
                              onTap: () => notifier.selectCategory(category),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Select All + count
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppAnimatedChip(
                          label: 'Select All',
                          selected: session.selectedCategoryIds.length == categories.length,
                          leadingIcon: Icons.select_all_rounded,
                          onTap: () => notifier.selectAllCategories(true),
                        ),
                        AppAnimatedChip(
                          label: '${session.selectedCategoryIds.length} selected',
                          selected: true,
                          leadingIcon: Icons.category_rounded,
                          compact: true,
                        ),
                        AppAnimatedChip(
                          label: 'Multi select',
                          selected: true,
                          compact: true,
                          leadingIcon: Icons.layers_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Category search bar
                    TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search categories...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (filteredCategories.isEmpty)
                      AppGlassCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No categories found',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Clear the search or use a different keyword to reveal the party word pool.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth >= 900
                              ? 3
                              : constraints.maxWidth >= 560
                                  ? 2
                                  : 1;
                          final mainAxisExtent = crossAxisCount == 1 ? 120.0 : 136.0;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisExtent: mainAxisExtent,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filteredCategories.length,
                            itemBuilder: (context, index) {
                              final cat = filteredCategories[index];
                              final isSelected = session.selectedCategoryIds.contains(cat.id);
                              return CategorySelectionCard(
                                category: cat,
                                selected: isSelected,
                                onTap: () => notifier.selectCategory(cat),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              const SizedBox(height: 32),

              // 4. Start Button
              AppNeonButton(
                label: 'START GAME',
                active: canStart,
                borderColor: canStart ? null : AppColors.borderSide.color,
                onPressed: () {
                  // Initialize round (category will be chosen from selected set or all categories)
                  notifier.startGame();
                  if (context.mounted) {
                    // Router transition
                    context.push('/reveal');
                  }
                },
              ).animate().shimmer(delay: 5000.ms, duration: 1500.ms),
              const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceMono(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: GoogleFonts.spaceMono(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.accentPurple,
            ),
          ),
      ],
    );
  }
}

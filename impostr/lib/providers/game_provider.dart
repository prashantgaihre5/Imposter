import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/models/game_session.dart';
import '../data/models/player.dart';
import '../data/models/word_category.dart';
import '../utils/game_engine.dart';
import '../utils/random_engine.dart';
import '../features/categories/repository/category_repository.dart';

final List<WordCategory> builtInCategories = categoryRepository.getAllCategories();

final allCategoriesProvider = Provider<List<WordCategory>>((ref) {
  return builtInCategories;
});

class GameNotifier extends StateNotifier<GameSession> {
  GameNotifier() : super(const GameSession()) {
    // Add 4 default players to make it quick to start
    addPlayer('Alice');
    addPlayer('Bob');
    addPlayer('Charlie');
    addPlayer('Dave');
  }

  static const _uuid = Uuid();
  Timer? _timer;
  final RandomEngine _randomEngine = RandomEngine();

  int get setupImpostorCount => state.impostorCount;

  int get maxImpostorCount {
    final maxByPlayers = state.players.length - 1;
    return maxByPlayers < 1 ? 1 : maxByPlayers;
  }

  int get totalRounds => state.totalRounds;

  int _clampImpostorCount(int playerCount, int count) {
    final effectiveMax = playerCount - 1 < 1 ? 1 : playerCount - 1;
    if (count < 1) return 1;
    if (count > effectiveMax) return effectiveMax;
    return count;
  }

  int _clampTotalRounds(int count) {
    if (count < 1) return 1;
    if (count > 5) return 5;
    return count;
  }

  void _syncImpostorCount() {
    final clamped = _clampImpostorCount(state.players.length, state.impostorCount);
    if (clamped != state.impostorCount) {
      state = state.copyWith(impostorCount: clamped);
    }
  }

  void addPlayer(String name) {
    if (name.trim().isEmpty) return;
    final newPlayer = Player(
      id: _uuid.v4(),
      name: name.trim(),
    );
    state = state.copyWith(
      players: [...state.players, newPlayer],
    );
    _syncImpostorCount();
  }

  void removePlayer(String id) {
    // Minimum 3 players, but we allow removing as long as we keep track of bounds
    state = state.copyWith(
      players: state.players.where((p) => p.id != id).toList(),
    );
    _syncImpostorCount();
  }

  void selectCategory(WordCategory category) {
    // Toggle selection of category in selectedCategoryIds
    final ids = List<String>.from(state.selectedCategoryIds);
    if (ids.contains(category.id)) {
      ids.remove(category.id);
    } else {
      ids.add(category.id);
    }
    state = state.copyWith(selectedCategoryIds: ids);
  }

  void selectAllCategories(bool select) {
    if (select) {
      final allIds = builtInCategories.map((c) => c.id).toList();
      state = state.copyWith(selectedCategoryIds: allIds);
    } else {
      state = state.copyWith(selectedCategoryIds: []);
    }
  }

  void toggleCategoryMode(bool enabled) {
    state = state.copyWith(categoriesEnabled: enabled);
  }

  void setTimerSeconds(int seconds) {
    state = state.copyWith(
      timerSeconds: seconds,
      elapsedSeconds: seconds,
    );
  }

  void toggleTimer(bool enabled) {
    state = state.copyWith(timerEnabled: enabled);
  }

  void setImpostorCount(int count) {
    state = state.copyWith(
      impostorCount: _clampImpostorCount(state.players.length, count),
    );
  }

  void setTotalRounds(int count) {
    state = state.copyWith(
      totalRounds: _clampTotalRounds(count),
    );
  }

  void startGame() {
    _stopTimer();
    final players = state.players;

    if (players.length < 3) {
      throw Exception('Need at least 3 players to start!');
    }

    final impostorCount = _clampImpostorCount(players.length, state.impostorCount);
    debugPrint('Impostor count selected: $impostorCount');

    final categoryPool = state.categoriesEnabled && state.selectedCategoryIds.isNotEmpty
        ? builtInCategories.where((c) => state.selectedCategoryIds.contains(c.id)).toList()
        : builtInCategories;
    final category = _randomEngine.getRandomCategory(categoryPool);

    // 1. Pick a secret word using replay-safe selection
    final wordEntry = state.categoriesEnabled && state.selectedCategoryIds.isNotEmpty
        ? _randomEngine.getRandomWordFromCategory(category)
        : _randomEngine.getRandomWordFromAllCategories(builtInCategories);

    // 2. Assign impostors
    final assignedPlayers = GameEngine.assignImpostors(players, impostorCount);

    // 3. Update player roles and information
    final updatedPlayers = assignedPlayers.map((player) {
      final isImpostor = player.role == PlayerRole.impostor;
      return player.copyWith(
        isEliminated: false,
        word: isImpostor ? null : wordEntry.text,
        hint: isImpostor ? wordEntry.hint : null,
      );
    }).toList();

    state = state.copyWith(
      players: updatedPlayers,
      secretWord: wordEntry.text,
      impostorWordHint: wordEntry.hint,
      selectedCategory: category,
      impostorCount: impostorCount,
      totalRounds: _clampTotalRounds(state.totalRounds),
      completedRounds: 0,
      eliminatedImpostorCount: 0,
      activePlayerRevealIndex: 0,
      roundNumber: 1,
      roundsSinceVote: 0,
      awaitingRoundAdvance: false,
      phase: GamePhase.reveal,
      speakerList: [],
      speakingPlayerIndex: 0,
      elapsedSeconds: state.timerSeconds,
      eliminatedPlayerId: null,
      impostorGuessedCorrectly: null,
    );
  }

  void startRound() {
    startGame();
  }

  void startNextRound({required int roundsSinceVote}) {
    _stopTimer();
    final activePlayers = state.players.where((p) => !p.isEliminated).toList();

    if (activePlayers.isEmpty) {
      return;
    }

    final firstSpeaker = GameEngine.pickFirstSpeaker(activePlayers);
    final otherPlayers = activePlayers.where((p) => p.id != firstSpeaker.id).toList();
    otherPlayers.shuffle();
    final orderedSpeakerIds = [firstSpeaker.id, ...otherPlayers.map((p) => p.id)];

    state = state.copyWith(
      roundNumber: state.completedRounds + 1,
      roundsSinceVote: roundsSinceVote,
      awaitingRoundAdvance: false,
      phase: GamePhase.play,
      speakerList: orderedSpeakerIds,
      speakingPlayerIndex: 0,
      elapsedSeconds: state.timerSeconds,
      activePlayerRevealIndex: 0,
      eliminatedPlayerId: null,
      eliminatedPlayerIds: [],
      voteResult: null,
      impostorGuessedCorrectly: null,
    );

    if (state.timerEnabled) {
      _startTimer();
    }
  }

  void finishRound() {
    _stopTimer();
    final nextCompletedRounds = state.completedRounds + 1;
    state = state.copyWith(
      roundNumber: nextCompletedRounds,
      completedRounds: nextCompletedRounds,
      awaitingRoundAdvance: true,
      roundsSinceVote: nextCompletedRounds,
      phase: GamePhase.play,
    );
  }

  void nextReveal() {
    final nextIndex = state.activePlayerRevealIndex + 1;
    if (nextIndex >= state.players.length) {
      // Completed reveals, transition to play phase
      startPlayPhase();
    } else {
      state = state.copyWith(activePlayerRevealIndex: nextIndex);
    }
  }

  void startPlayPhase() {
    final activePlayers = state.players.where((p) => !p.isEliminated).toList();
    
    // Pick the first speaker using engine function
    final firstSpeaker = GameEngine.pickFirstSpeaker(activePlayers);
    
    // Prepare speaker list starting with the first speaker, then others shuffled
    final otherPlayers = activePlayers.where((p) => p.id != firstSpeaker.id).toList();
    otherPlayers.shuffle();
    final orderedSpeakerIds = [firstSpeaker.id, ...otherPlayers.map((p) => p.id)];

    state = state.copyWith(
      phase: GamePhase.play,
      speakerList: orderedSpeakerIds,
      speakingPlayerIndex: 0,
      elapsedSeconds: state.timerSeconds,
    );

    if (state.timerEnabled) {
      _startTimer();
    }
  }

  void nextSpeaker() {
    _stopTimer();
    final nextIndex = state.speakingPlayerIndex + 1;
    if (nextIndex >= state.speakerList.length) {
      // All players have spoken; wait for the round-advance action.
      finishRound();
    } else {
      state = state.copyWith(
        speakingPlayerIndex: nextIndex,
        elapsedSeconds: state.timerSeconds,
      );
      if (state.timerEnabled) {
        _startTimer();
      }
    }
  }

  void eliminatePlayer(String playerId) {
    eliminatePlayers([playerId]);
  }

  void eliminatePlayers(List<String> playerIds) {
    _stopTimer();

    final activeImpostorIds = state.players
        .where((p) => p.role == PlayerRole.impostor && !p.isEliminated)
        .map((p) => p.id)
        .toList();
    final voteResult = GameEngine.checkVoteResult(playerIds, activeImpostorIds);
    final shouldEliminate = voteResult != 'wrong_vote';

    final updatedPlayers = shouldEliminate
        ? state.players.map((p) {
            if (playerIds.contains(p.id)) {
              return p.copyWith(isEliminated: true);
            }
            return p;
          }).toList()
        : state.players;

    final nextEliminatedImpostorCount = shouldEliminate
        ? state.eliminatedImpostorCount + state.players.where((p) => p.role == PlayerRole.impostor && playerIds.contains(p.id)).length
        : state.eliminatedImpostorCount;

    state = state.copyWith(
      players: updatedPlayers,
      eliminatedPlayerIds: playerIds,
      eliminatedPlayerId: playerIds.isNotEmpty ? playerIds.first : null,
      voteResult: voteResult,
      eliminatedImpostorCount: nextEliminatedImpostorCount,
      phase: GamePhase.result,
    );
  }

  void forceEndRound() {
    finishRound();
  }

  void submitImpostorGuess(String guess) {
    final isCorrect = GameEngine.checkImpostorGuess(guess, state.secretWord ?? '');
    
    final impostorIds = state.players
        .where((p) => p.role == PlayerRole.impostor)
        .map((p) => p.id)
        .toList();
    final votedIds = state.eliminatedPlayerIds.isNotEmpty
        ? state.eliminatedPlayerIds
        : (state.eliminatedPlayerId == null ? <String>[] : [state.eliminatedPlayerId!]);

    // Calculate scores
    final updatedPlayers = GameEngine.calculateScores(
      players: state.players,
      impostorIds: impostorIds,
      eliminatedIds: votedIds,
      voteResult: state.voteResult ?? GameEngine.checkVoteResult(votedIds, impostorIds),
      impostorGuessedCorrectly: isCorrect,
    );

    state = state.copyWith(
      players: updatedPlayers,
      impostorGuessedCorrectly: isCorrect,
      phase: GamePhase.score,
    );
  }

  void skipImpostorGuess() {
    // If not guessing or not caught, calculate standard scores
    final impostorIds = state.players
        .where((p) => p.role == PlayerRole.impostor)
        .map((p) => p.id)
        .toList();
    final votedIds = state.eliminatedPlayerIds.isNotEmpty
        ? state.eliminatedPlayerIds
        : (state.eliminatedPlayerId == null ? <String>[] : [state.eliminatedPlayerId!]);

    final updatedPlayers = GameEngine.calculateScores(
      players: state.players,
      impostorIds: impostorIds,
      eliminatedIds: votedIds,
      voteResult: state.voteResult ?? GameEngine.checkVoteResult(votedIds, impostorIds),
      impostorGuessedCorrectly: false,
    );

    state = state.copyWith(
      players: updatedPlayers,
      impostorGuessedCorrectly: false,
      phase: GamePhase.score,
    );
  }

  void continueToNextRound() {
    if (state.completedRounds >= state.totalRounds) {
      state = state.copyWith(
        eliminatedPlayerId: null,
        eliminatedPlayerIds: [],
        voteResult: null,
        impostorGuessedCorrectly: null,
        awaitingRoundAdvance: false,
        phase: GamePhase.vote,
      );
      return;
    }

    state = state.copyWith(
      eliminatedPlayerId: null,
      eliminatedPlayerIds: [],
      voteResult: null,
      impostorGuessedCorrectly: null,
      phase: GamePhase.play,
    );
    startNextRound(roundsSinceVote: 0);
  }

  void playAgain() {
    // Keep scores, go back to setup screen
    state = state.copyWith(
      phase: GamePhase.setup,
      secretWord: null,
      impostorWordHint: null,
      eliminatedPlayerId: null,
      eliminatedPlayerIds: [],
      voteResult: null,
      impostorGuessedCorrectly: null,
      speakerList: [],
      roundNumber: 0,
      roundsSinceVote: 0,
      impostorCount: 1,
      eliminatedImpostorCount: 0,
      totalRounds: 2,
      completedRounds: 0,
      awaitingRoundAdvance: false,
    );
  }

  void resetGame() {
    _stopTimer();
    final resetPlayers = state.players.map((p) => p.copyWith(score: 0, isEliminated: false)).toList();
    state = GameSession(
      players: resetPlayers,
      selectedCategory: state.selectedCategory,
      selectedCategoryIds: state.selectedCategoryIds,
      categoriesEnabled: state.categoriesEnabled,
      timerSeconds: state.timerSeconds,
      timerEnabled: state.timerEnabled,
      roundNumber: 0,
      roundsSinceVote: 0,
      impostorCount: 1,
      eliminatedImpostorCount: 0,
      totalRounds: 2,
      completedRounds: 0,
      awaitingRoundAdvance: false,
      eliminatedPlayerIds: [],
      voteResult: null,
    );
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.elapsedSeconds > 0) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds - 1);
      } else {
        // Time is up, move to next speaker
        nextSpeaker();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameSession>((ref) {
  return GameNotifier();
});

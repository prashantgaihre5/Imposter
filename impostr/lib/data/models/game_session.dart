import 'player.dart';
import 'word_category.dart';

enum GamePhase { home, setup, reveal, play, vote, result, score }

class GameSession {
  static const Object _unset = Object();

  final List<Player> players;
  final WordCategory? selectedCategory;
  final List<String> selectedCategoryIds;
  final bool categoriesEnabled;
  final String? secretWord;
  final String? impostorWordHint;
  final int activePlayerRevealIndex; // Tracks which player is currently revealing their card
  final GamePhase phase;
  final int timerSeconds; // Configured seconds (e.g. 30, 45, 60)
  final int elapsedSeconds; // Remaining seconds for active speaker or round timer
  final int speakingPlayerIndex; // Index in the speakerList
  final int roundNumber;
  final int totalRounds;
  final int completedRounds;
  final int roundsSinceVote;
  final int impostorCount;
  final int eliminatedImpostorCount;
  final bool awaitingRoundAdvance;
  final List<String> eliminatedPlayerIds;
  final String? voteResult;
  final String? eliminatedPlayerId; // Player ID of the person voted out this round
  final bool? impostorGuessedCorrectly; // Did the impostor successfully guess the civilian word?
  final List<String> speakerList; // List of player IDs in order of speaking
  final bool timerEnabled;

  const GameSession({
    this.players = const [],
    this.selectedCategory,
    this.selectedCategoryIds = const [],
    this.categoriesEnabled = true,
    this.secretWord,
    this.impostorWordHint,
    this.activePlayerRevealIndex = 0,
    this.phase = GamePhase.home,
    this.timerSeconds = 45,
    this.elapsedSeconds = 45,
    this.speakingPlayerIndex = 0,
    this.roundNumber = 0,
    this.totalRounds = 2,
    this.completedRounds = 0,
    this.roundsSinceVote = 0,
    this.impostorCount = 1,
    this.eliminatedImpostorCount = 0,
    this.awaitingRoundAdvance = false,
    this.eliminatedPlayerIds = const [],
    this.voteResult,
    this.eliminatedPlayerId,
    this.impostorGuessedCorrectly,
    this.speakerList = const [],
    this.timerEnabled = true,
  });

  GameSession copyWith({
    List<Player>? players,
    Object? selectedCategory = _unset,
    List<String>? selectedCategoryIds,
    bool? categoriesEnabled,
    Object? secretWord = _unset,
    Object? impostorWordHint = _unset,
    int? activePlayerRevealIndex,
    GamePhase? phase,
    int? timerSeconds,
    int? elapsedSeconds,
    int? speakingPlayerIndex,
    int? roundNumber,
    int? totalRounds,
    int? completedRounds,
    int? roundsSinceVote,
    int? impostorCount,
    int? eliminatedImpostorCount,
    bool? awaitingRoundAdvance,
    List<String>? eliminatedPlayerIds,
    Object? voteResult = _unset,
    Object? eliminatedPlayerId = _unset,
    Object? impostorGuessedCorrectly = _unset,
    List<String>? speakerList,
    bool? timerEnabled,
  }) {
    return GameSession(
      players: players ?? this.players,
      selectedCategory: identical(selectedCategory, _unset) ? this.selectedCategory : selectedCategory as WordCategory?,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      categoriesEnabled: categoriesEnabled ?? this.categoriesEnabled,
      secretWord: identical(secretWord, _unset) ? this.secretWord : secretWord as String?,
      impostorWordHint: identical(impostorWordHint, _unset) ? this.impostorWordHint : impostorWordHint as String?,
      activePlayerRevealIndex: activePlayerRevealIndex ?? this.activePlayerRevealIndex,
      phase: phase ?? this.phase,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      speakingPlayerIndex: speakingPlayerIndex ?? this.speakingPlayerIndex,
      roundNumber: roundNumber ?? this.roundNumber,
      totalRounds: totalRounds ?? this.totalRounds,
      completedRounds: completedRounds ?? this.completedRounds,
      roundsSinceVote: roundsSinceVote ?? this.roundsSinceVote,
      impostorCount: impostorCount ?? this.impostorCount,
      eliminatedImpostorCount: eliminatedImpostorCount ?? this.eliminatedImpostorCount,
      awaitingRoundAdvance: awaitingRoundAdvance ?? this.awaitingRoundAdvance,
      eliminatedPlayerIds: eliminatedPlayerIds ?? this.eliminatedPlayerIds,
      voteResult: identical(voteResult, _unset) ? this.voteResult : voteResult as String?,
        eliminatedPlayerId: identical(eliminatedPlayerId, _unset) ? this.eliminatedPlayerId : eliminatedPlayerId as String?,
        impostorGuessedCorrectly: identical(impostorGuessedCorrectly, _unset)
          ? this.impostorGuessedCorrectly
          : impostorGuessedCorrectly as bool?,
      speakerList: speakerList ?? this.speakerList,
      timerEnabled: timerEnabled ?? this.timerEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'players': players.map((p) => p.toJson()).toList(),
        'selectedCategory': selectedCategory?.toJson(),
        'selectedCategoryIds': selectedCategoryIds,
        'categoriesEnabled': categoriesEnabled,
        'secretWord': secretWord,
        'impostorWordHint': impostorWordHint,
        'activePlayerRevealIndex': activePlayerRevealIndex,
        'phase': phase.name,
        'timerSeconds': timerSeconds,
        'elapsedSeconds': elapsedSeconds,
        'speakingPlayerIndex': speakingPlayerIndex,
        'roundNumber': roundNumber,
        'totalRounds': totalRounds,
        'completedRounds': completedRounds,
        'roundsSinceVote': roundsSinceVote,
        'impostorCount': impostorCount,
        'eliminatedImpostorCount': eliminatedImpostorCount,
        'awaitingRoundAdvance': awaitingRoundAdvance,
        'eliminatedPlayerIds': eliminatedPlayerIds,
        'voteResult': voteResult,
        'eliminatedPlayerId': eliminatedPlayerId,
        'impostorGuessedCorrectly': impostorGuessedCorrectly,
        'speakerList': speakerList,
        'timerEnabled': timerEnabled,
      };
}

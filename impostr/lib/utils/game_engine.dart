import 'dart:math';
import '../data/models/player.dart';
import '../data/models/word_category.dart';
import 'random_engine.dart';

class GameEngine {
  static final Random _random = _secureRandom();
  static final RandomEngine _randomEngine = RandomEngine();

  static Random _secureRandom() {
    try {
      return Random.secure();
    } catch (_) {
      return Random();
    }
  }

  /// assignImpostors(players, count): shuffle list, return first [count] IDs
  static List<Player> assignImpostors(List<Player> players, int count) {
    assert(count >= 1 && count < players.length);

    if (players.isEmpty) return [];

    final shuffledPlayers = List<Player>.from(players)..shuffle(_random);
    final countToTake = min(count, shuffledPlayers.length);
    final impostorIds = shuffledPlayers.take(countToTake).map((p) => p.id).toSet();

    return players.map((player) {
      return player.copyWith(
        role: impostorIds.contains(player.id) ? PlayerRole.impostor : PlayerRole.civilian,
      );
    }).toList();
  }

  /// pickWord(category, usedWords): random unused word from category
  static WordEntry pickWord(WordCategory category, List<String> usedWords) {
    if (category.words.isEmpty) {
      throw Exception('Category ${category.name} has no words!');
    }
    try {
      return _randomEngine.getRandomWordFromCategory(category, excludedWords: usedWords);
    } catch (e) {
      // Fallback to previous simple selection
      final unusedWords = category.words.where((w) => !usedWords.contains(w.text)).toList();
      if (unusedWords.isEmpty) {
        return category.words[_random.nextInt(category.words.length)];
      }
      return unusedWords[_random.nextInt(unusedWords.length)];
    }
  }

  /// pickFirstSpeaker(players): Random().nextInt on player list
  /// Returns a player from the list
  static Player pickFirstSpeaker(List<Player> players) {
    if (players.isEmpty) {
      throw Exception('No players in game!');
    }
    final activePlayers = players.where((p) => !p.isEliminated).toList();
    if (activePlayers.isEmpty) {
      return players[_random.nextInt(players.length)];
    }
    return activePlayers[_random.nextInt(activePlayers.length)];
  }

  /// Returns: 'full_win' | 'partial_win' | 'wrong_vote'
  static String checkVoteResult(List<String> eliminatedIds, List<String> impostorIds) {
    if (eliminatedIds.isEmpty) {
      return 'wrong_vote';
    }

    final eliminatedSet = eliminatedIds.toSet();
    final impostorSet = impostorIds.toSet();
    final allSelectedAreImpostors = eliminatedSet.every(impostorSet.contains);
    if (!allSelectedAreImpostors) {
      return 'wrong_vote';
    }

    return eliminatedSet.length == impostorSet.length ? 'full_win' : 'partial_win';
  }

  /// checkImpostorGuess(guess, secretWord): case-insensitive trim match
  static bool checkImpostorGuess(String guess, String secretWord) {
    return guess.trim().toLowerCase() == secretWord.trim().toLowerCase();
  }

  /// calculateScores(result): applies the vote result and guess bonus.
  static List<Player> calculateScores({
    required List<Player> players,
    required List<String> impostorIds,
    required List<String> eliminatedIds,
    required String voteResult,
    required bool impostorGuessedCorrectly,
  }) {
    final eliminatedSet = eliminatedIds.toSet();

    return players.map((player) {
      int scoreAddition = 0;

      if (eliminatedSet.isEmpty) {
        if (player.role == PlayerRole.impostor && !player.isEliminated) {
          scoreAddition += 3;
        }
      } else if (voteResult == 'wrong_vote') {
        if (player.role == PlayerRole.impostor && !player.isEliminated) {
          scoreAddition += 2;
        }
      } else {
        if (player.role == PlayerRole.civilian) {
          scoreAddition += impostorGuessedCorrectly ? 1 : 2;
        } else if (player.role == PlayerRole.impostor && eliminatedSet.contains(player.id)) {
          scoreAddition += impostorGuessedCorrectly ? 1 : 0;
        }
      }

      return player.copyWith(score: player.score + scoreAddition);
    }).toList();
  }
}

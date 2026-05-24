import 'package:flutter_test/flutter_test.dart';
import 'package:shhh_who_is_it/data/models/player.dart';
import 'package:shhh_who_is_it/data/models/word_category.dart';
import 'package:shhh_who_is_it/utils/game_engine.dart';

void main() {
  group('GameEngine Tests', () {
    test('assignImpostors should assign the requested number of impostors', () {
      final List<Player> players = [
        const Player(id: '1', name: 'Alice'),
        const Player(id: '2', name: 'Bob'),
        const Player(id: '3', name: 'Charlie'),
        const Player(id: '4', name: 'Dave'),
      ];

      final assignedOne = GameEngine.assignImpostors(players, 1);
      expect(assignedOne.length, equals(players.length));
      expect(assignedOne.where((p) => p.role == PlayerRole.impostor).length, equals(1));
      expect(assignedOne.where((p) => p.role == PlayerRole.civilian).length, equals(3));

      final assignedTwo = GameEngine.assignImpostors(players, 2);
      expect(assignedTwo.where((p) => p.role == PlayerRole.impostor).length, equals(2));
      expect(assignedTwo.where((p) => p.role == PlayerRole.civilian).length, equals(2));
    });

    test('pickWord should return a random unused word from category', () {
      const category = WordCategory(
        id: 'test_cat',
        name: 'Test Category',
        description: 'Test Desc',
        icon: 'test_icon',
        words: [
          WordEntry(text: 'Pizza', hint: 'Italian', difficulty: 'Easy', ageGroup: 'All'),
          WordEntry(text: 'Sushi', hint: 'Japanese', difficulty: 'Easy', ageGroup: 'All'),
        ],
      );

      final word1 = GameEngine.pickWord(category, []);
      expect(['Pizza', 'Sushi'].contains(word1.text), isTrue);

      // If 'Pizza' has been used, it should pick 'Sushi'
      final word2 = GameEngine.pickWord(category, ['Pizza']);
      expect(word2.text, equals('Sushi'));

      // If all have been used, it should reset and pick any
      final word3 = GameEngine.pickWord(category, ['Pizza', 'Sushi']);
      expect(['Pizza', 'Sushi'].contains(word3.text), isTrue);
    });

    test('pickFirstSpeaker should return an active player', () {
      final List<Player> players = [
        const Player(id: '1', name: 'Alice', isEliminated: true),
        const Player(id: '2', name: 'Bob', isEliminated: false),
        const Player(id: '3', name: 'Charlie', isEliminated: false),
      ];

      final speaker = GameEngine.pickFirstSpeaker(players);
      expect(speaker.isEliminated, isFalse);
      expect(['2', '3'].contains(speaker.id), isTrue);
    });

    test('checkVoteResult should classify full, partial, and wrong votes', () {
      expect(GameEngine.checkVoteResult(['2', '3'], ['2', '3']), equals('full_win'));
      expect(GameEngine.checkVoteResult(['2'], ['2', '3']), equals('partial_win'));
      expect(GameEngine.checkVoteResult(['1'], ['2', '3']), equals('wrong_vote'));
      expect(GameEngine.checkVoteResult([], ['2', '3']), equals('wrong_vote'));
    });

    test('checkImpostorGuess should perform case-insensitive trim matches', () {
      expect(GameEngine.checkImpostorGuess('  piZZa ', 'Pizza'), isTrue);
      expect(GameEngine.checkImpostorGuess('Burger', 'Pizza'), isFalse);
    });

    test('calculateScores should award points for a full win and correct guess', () {
      final List<Player> players = [
        const Player(id: '1', name: 'Alice', role: PlayerRole.civilian, score: 0),
        const Player(id: '2', name: 'Bob', role: PlayerRole.impostor, score: 0),
        const Player(id: '3', name: 'Charlie', role: PlayerRole.civilian, score: 0),
      ];
      final result = GameEngine.calculateScores(
        players: players,
        impostorIds: ['2'],
        eliminatedIds: ['2'],
        voteResult: 'full_win',
        impostorGuessedCorrectly: true,
      );

      final aliceScore = result.firstWhere((p) => p.id == '1').score;
      final bobScore = result.firstWhere((p) => p.id == '2').score;
      final charlieScore = result.firstWhere((p) => p.id == '3').score;

      expect(aliceScore, equals(1));
      expect(charlieScore, equals(1));
      expect(bobScore, equals(1));
    });

    test('calculateScores should award partial win points to civilians and no points to survivors', () {
      final List<Player> players = [
        const Player(id: '1', name: 'Alice', role: PlayerRole.civilian, score: 0, isEliminated: false),
        const Player(id: '2', name: 'Bob', role: PlayerRole.impostor, score: 0, isEliminated: true),
        const Player(id: '3', name: 'Charlie', role: PlayerRole.impostor, score: 0, isEliminated: false),
        const Player(id: '4', name: 'Dana', role: PlayerRole.civilian, score: 0, isEliminated: false),
      ];

      final result = GameEngine.calculateScores(
        players: players,
        impostorIds: ['2', '3'],
        eliminatedIds: ['2'],
        voteResult: 'partial_win',
        impostorGuessedCorrectly: false,
      );

      expect(result.firstWhere((p) => p.id == '1').score, equals(2));
      expect(result.firstWhere((p) => p.id == '4').score, equals(2));
      expect(result.firstWhere((p) => p.id == '2').score, equals(0));
      expect(result.firstWhere((p) => p.id == '3').score, equals(0));
    });

    test('calculateScores should award surviving impostors when civilians vote wrong', () {
      final List<Player> players = [
        const Player(id: '1', name: 'Alice', role: PlayerRole.civilian, score: 0),
        const Player(id: '2', name: 'Bob', role: PlayerRole.impostor, score: 0),
        const Player(id: '3', name: 'Charlie', role: PlayerRole.impostor, score: 0),
      ];

      final result = GameEngine.calculateScores(
        players: players,
        impostorIds: ['2', '3'],
        eliminatedIds: ['1'],
        voteResult: 'wrong_vote',
        impostorGuessedCorrectly: false,
      );

      expect(result.firstWhere((p) => p.id == '1').score, equals(0));
      expect(result.firstWhere((p) => p.id == '2').score, equals(2));
      expect(result.firstWhere((p) => p.id == '3').score, equals(2));
    });

    test('calculateScores should award three points when impostors survive all rounds', () {
      final List<Player> players = [
        const Player(id: '1', name: 'Alice', role: PlayerRole.civilian, score: 0),
        const Player(id: '2', name: 'Bob', role: PlayerRole.impostor, score: 0),
      ];

      final result = GameEngine.calculateScores(
        players: players,
        impostorIds: ['2'],
        eliminatedIds: [],
        voteResult: 'wrong_vote',
        impostorGuessedCorrectly: false,
      );

      expect(result.firstWhere((p) => p.id == '1').score, equals(0));
      expect(result.firstWhere((p) => p.id == '2').score, equals(3));
    });
  });
}

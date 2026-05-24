import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shhh_who_is_it/data/models/game_session.dart';
import 'package:shhh_who_is_it/data/models/word_category.dart';
import 'package:shhh_who_is_it/providers/game_provider.dart';
import 'package:shhh_who_is_it/utils/random_engine.dart';

void main() {
  group('RandomEngine', () {
    test('excludeRecent removes recently used values', () {
      final engine = RandomEngine(random: Random(1));
      final result = engine.excludeRecent([1, 2, 3, 4], [2, 4]);
      expect(result, [1, 3]);
    });

    test('getRandomCategory avoids immediate repeats when alternatives exist', () {
      final engine = RandomEngine(random: Random(1), recentCategoryLimit: 3, recentWordLimit: 3);
      const categories = [
        WordCategory(id: 'a', name: 'A', description: 'A', icon: 'category'),
        WordCategory(id: 'b', name: 'B', description: 'B', icon: 'category'),
      ];

      final first = engine.getRandomCategory(categories);
      final second = engine.getRandomCategory(categories);

      expect(second.id, isNot(equals(first.id)));
    });

    test('getRandomWord avoids word loops when alternatives exist', () {
      final engine = RandomEngine(random: Random(1), recentCategoryLimit: 3, recentWordLimit: 8);
      const category = WordCategory(
        id: 'party',
        name: 'Party',
        description: 'Party',
        icon: 'category',
        words: [
          WordEntry(text: 'Rizz', hint: 'Direct', difficulty: 'Easy', ageGroup: 'All'),
          WordEntry(text: 'Aura', hint: 'Direct', difficulty: 'Easy', ageGroup: 'All'),
        ],
      );

      final first = engine.getRandomWordFromCategory(category);
      final second = engine.getRandomWordFromCategory(category);

      expect(second.text, isNot(equals(first.text)));
    });

    test('buildIndirectHint does not echo the word back', () {
      final engine = RandomEngine(random: Random(1));
      const item = WordItem(
        word: 'Pizza',
        difficulty: Difficulty.easy,
        hintStyle: 'social',
      );

      final hint = engine.buildIndirectHint(item).toLowerCase();
      expect(hint.contains('pizza'), isFalse);
    });
  });

  group('GameNotifier round cadence', () {
    test('pauses after each speaking round and unlocks vote after total rounds', () {
      final notifier = GameNotifier();
      notifier.toggleTimer(false);

      notifier.startRound();
      final firstWord = notifier.state.secretWord;
      final firstRoles = notifier.state.players.map((player) => player.role).toList();

      for (var i = 0; i < notifier.state.players.length; i++) {
        notifier.nextReveal();
      }
      expect(notifier.state.phase, GamePhase.play);

      for (var i = 0; i < notifier.state.players.length; i++) {
        notifier.nextSpeaker();
      }
      expect(notifier.state.phase, GamePhase.play);
      expect(notifier.state.awaitingRoundAdvance, isTrue);
      expect(notifier.state.completedRounds, 1);
      expect(notifier.state.secretWord, firstWord);
      expect(notifier.state.players.map((player) => player.role).toList(), firstRoles);

      notifier.startNextRound(roundsSinceVote: 0);
      expect(notifier.state.phase, GamePhase.play);
      expect(notifier.state.roundNumber, 2);
      expect(notifier.state.completedRounds, 1);
      expect(notifier.state.awaitingRoundAdvance, isFalse);

      for (var i = 0; i < notifier.state.players.length; i++) {
        notifier.nextSpeaker();
      }
      expect(notifier.state.phase, GamePhase.play);
      expect(notifier.state.awaitingRoundAdvance, isTrue);
      expect(notifier.state.completedRounds, 2);
      expect(notifier.state.completedRounds, equals(notifier.state.totalRounds));
    });

    test('category mode off still starts a round', () {
      final notifier = GameNotifier();
      notifier.toggleTimer(false);
      notifier.toggleCategoryMode(false);

      notifier.startRound();

      expect(notifier.state.phase, GamePhase.reveal);
      expect(notifier.state.secretWord, isNotEmpty);
      expect(notifier.state.impostorWordHint, isNotEmpty);
    });
  });
}

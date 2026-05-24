import 'dart:collection';
import 'dart:math';

import '../data/models/word_category.dart';

enum Difficulty { easy, medium, chaotic }

class WordItem {
  final String word;
  final Difficulty difficulty;
  final String? categoryId;
  final List<String> tags;
  final String hintStyle;
  final double popularityScore;

  const WordItem({
    required this.word,
    required this.difficulty,
    this.categoryId,
    this.tags = const [],
    this.hintStyle = 'social',
    this.popularityScore = 1.0,
  });
}

class RandomEngine {
  static const int _defaultRecentCategoryLimit = 3;
  static const int _defaultRecentWordLimit = 8;
  static const int _categoryStreakLimit = 1;
  static const int _wordStreakLimit = 1;

  final Random _random;
  final int recentCategoryLimit;
  final int recentWordLimit;

  final ListQueue<String> _recentCategoryIds = ListQueue<String>();
  final ListQueue<String> _recentWords = ListQueue<String>();

  String? _lastCategoryId;
  int _categoryStreak = 0;
  String? _lastWord;
  int _wordStreak = 0;

  RandomEngine({Random? random, this.recentCategoryLimit = _defaultRecentCategoryLimit, this.recentWordLimit = _defaultRecentWordLimit})
      : _random = random ?? _secureRandom();

  static Random _secureRandom() {
    try {
      return Random.secure();
    } catch (_) {
      return Random();
    }
  }

  List<T> excludeRecent<T>(Iterable<T> values, Iterable<Object?> recent) {
    final recentSet = recent.toSet();
    return values.where((value) => !recentSet.contains(value)).toList(growable: false);
  }

  WordCategory getRandomCategory(List<WordCategory> categories, {Iterable<String> excludedIds = const []}) {
    if (categories.isEmpty) {
      throw StateError('No categories available');
    }

    final excluded = excludedIds.toSet();
    final recentFiltered = excludeRecent(categories.where((category) => !excluded.contains(category.id)), _recentCategoryIds);
    final streakFiltered = recentFiltered.where((category) => !(category.id == _lastCategoryId && _categoryStreak >= _categoryStreakLimit)).toList(growable: false);
    final pool = streakFiltered.isNotEmpty ? streakFiltered : (recentFiltered.isNotEmpty ? recentFiltered : categories.where((category) => !excluded.contains(category.id)).toList(growable: false));

    final selected = pool[_random.nextInt(pool.length)];
    _rememberCategory(selected.id);
    return selected;
  }

  WordEntry getRandomWord(
    List<WordEntry> words, {
    Iterable<String> excludedWords = const [],
    String? categoryId,
    Difficulty? targetDifficulty,
  }) {
    if (words.isEmpty) {
      throw StateError('No words available');
    }

    final excluded = excludedWords.map((word) => word.toLowerCase()).toSet();
    final items = _toItems(words, categoryId: categoryId);

    final pool = _filteredWordPool(items, excluded, targetDifficulty: targetDifficulty);
    final chosen = _weightedPick(pool);
    _rememberWord(chosen.word);

    return WordEntry(
      text: chosen.word,
      hint: buildIndirectHint(chosen),
      difficulty: _difficultyLabel(chosen.difficulty),
      ageGroup: 'All',
    );
  }

  WordEntry getRandomWordFromCategory(
    WordCategory category, {
    Iterable<String> excludedWords = const [],
    Difficulty? targetDifficulty,
  }) {
    return getRandomWord(
      category.words,
      excludedWords: excludedWords,
      categoryId: category.id,
      targetDifficulty: targetDifficulty,
    );
  }

  WordEntry getRandomWordFromAllCategories(
    List<WordCategory> categories, {
    Iterable<String> excludedWords = const [],
    Difficulty? targetDifficulty,
  }) {
    final allWords = categories.expand((category) => category.words).toList(growable: false);
    return getRandomWord(
      allWords,
      excludedWords: excludedWords,
      targetDifficulty: targetDifficulty,
    );
  }

  String buildIndirectHint(WordItem item) {
    final socialHints = [
      'something everyone has seen in the wild',
      'the kind of thing people mention without thinking',
      'easy to spot once the vibe clicks',
      'a common answer in everyday conversation',
    ];
    final memeHints = [
      'more internet energy than textbook energy',
      'the sort of thing that shows up in group chats',
      'very describable by vibes, not definitions',
      'meme-adjacent and instantly recognisable',
    ];
    final chaoticHints = [
      'chaos-friendly and hard to over-explain',
      'feels obvious after someone says it first',
      'best described with energy, not precision',
      'the room usually gets it from the first clue',
    ];

    final pool = switch (item.hintStyle) {
      'meme' => memeHints,
      'chaotic' => chaoticHints,
      _ => socialHints,
    };

    final opener = pool[_random.nextInt(pool.length)];
    final closer = item.difficulty == Difficulty.chaotic
        ? ' Keep it loose and party-friendly.'
        : item.difficulty == Difficulty.medium
            ? ' Stay indirect and social.'
            : ' Make it instantly guessable.';
    return '$opener$closer';
  }

  List<WordItem> _toItems(List<WordEntry> words, {String? categoryId}) {
    return words.map((word) {
      final difficulty = _parseDifficulty(word.difficulty);
      final hintStyle = switch (difficulty) {
        Difficulty.easy => 'social',
        Difficulty.medium => 'meme',
        Difficulty.chaotic => 'chaotic',
      };
      return WordItem(
        word: word.text,
        difficulty: difficulty,
        categoryId: categoryId,
        tags: const [],
        hintStyle: hintStyle,
        popularityScore: _popularityScore(word.text, difficulty),
      );
    }).toList(growable: false);
  }

  List<WordItem> _filteredWordPool(
    List<WordItem> items,
    Set<String> excluded, {
    Difficulty? targetDifficulty,
  }) {
    Iterable<WordItem> pool = items.where((item) => !excluded.contains(item.word.toLowerCase()));

    if (targetDifficulty != null) {
      final targeted = pool.where((item) => item.difficulty == targetDifficulty).toList(growable: false);
      if (targeted.isNotEmpty) {
        pool = targeted;
      }
    } else {
      final easy = pool.where((item) => item.difficulty == Difficulty.easy).toList(growable: false);
      final medium = pool.where((item) => item.difficulty == Difficulty.medium).toList(growable: false);
      final chaotic = pool.where((item) => item.difficulty == Difficulty.chaotic).toList(growable: false);
      final roll = _random.nextDouble();
      if (roll < 0.70 && easy.isNotEmpty) {
        pool = easy;
      } else if (roll < 0.95 && medium.isNotEmpty) {
        pool = medium;
      } else if (chaotic.isNotEmpty) {
        pool = chaotic;
      }
    }

    final recentFiltered = excludeRecent(pool, _recentWords);
    if (recentFiltered.isNotEmpty) return recentFiltered;

    final relaxed = pool.toList(growable: false);
    if (relaxed.isNotEmpty) return relaxed;

    return items;
  }

  WordItem _weightedPick(List<WordItem> items) {
    if (items.length == 1) return items.first;

    final streakSafe = items.where((item) => !(item.word.toLowerCase() == _lastWord && _wordStreak >= _wordStreakLimit)).toList(growable: false);
    final pool = streakSafe.isNotEmpty ? streakSafe : items;

    final totalWeight = pool.fold<double>(0, (sum, item) => sum + item.popularityScore);
    if (totalWeight <= 0) {
      return pool[_random.nextInt(pool.length)];
    }

    var cursor = _random.nextDouble() * totalWeight;
    for (final item in pool) {
      cursor -= item.popularityScore;
      if (cursor <= 0) return item;
    }
    return pool.last;
  }

  void _rememberCategory(String id) {
    if (_lastCategoryId == id) {
      _categoryStreak += 1;
    } else {
      _lastCategoryId = id;
      _categoryStreak = 1;
    }

    _recentCategoryIds.addLast(id);
    while (_recentCategoryIds.length > recentCategoryLimit) {
      _recentCategoryIds.removeFirst();
    }
  }

  void _rememberWord(String word) {
    final normalized = word.toLowerCase();
    if (_lastWord == normalized) {
      _wordStreak += 1;
    } else {
      _lastWord = normalized;
      _wordStreak = 1;
    }

    _recentWords.addLast(normalized);
    while (_recentWords.length > recentWordLimit) {
      _recentWords.removeFirst();
    }
  }

  Difficulty _parseDifficulty(String difficulty) {
    final normalized = difficulty.toLowerCase();
    if (normalized.contains('hard') || normalized.contains('chaotic')) {
      return Difficulty.chaotic;
    }
    if (normalized.contains('medium')) {
      return Difficulty.medium;
    }
    return Difficulty.easy;
  }

  String _difficultyLabel(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.chaotic:
        return 'Chaotic';
    }
  }

  double _popularityScore(String word, Difficulty difficulty) {
    final base = switch (difficulty) {
      Difficulty.easy => 1.2,
      Difficulty.medium => 1.0,
      Difficulty.chaotic => 0.8,
    };
    final bonus = (word.length % 5) * 0.05;
    return base + bonus;
  }
}

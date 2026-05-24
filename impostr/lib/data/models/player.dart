enum PlayerRole { civilian, impostor }

class Player {
  static const Object _unset = Object();

  final String id;
  final String name;
  final int score;
  final PlayerRole role;
  final bool isEliminated;
  final String? word; // The word this player gets (null for impostors)
  final String? hint; // Vague category hint for impostors (or category name)
  final int speakingOrder;

  const Player({
    required this.id,
    required this.name,
    this.score = 0,
    this.role = PlayerRole.civilian,
    this.isEliminated = false,
    this.word,
    this.hint,
    this.speakingOrder = 0,
  });

  Player copyWith({
    String? id,
    String? name,
    int? score,
    PlayerRole? role,
    bool? isEliminated,
    Object? word = _unset,
    Object? hint = _unset,
    int? speakingOrder,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      role: role ?? this.role,
      isEliminated: isEliminated ?? this.isEliminated,
      word: identical(word, _unset) ? this.word : word as String?,
      hint: identical(hint, _unset) ? this.hint : hint as String?,
      speakingOrder: speakingOrder ?? this.speakingOrder,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'score': score,
        'role': role.name,
        'isEliminated': isEliminated,
        'word': word,
        'hint': hint,
        'speakingOrder': speakingOrder,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        name: json['name'] as String,
        score: json['score'] as int? ?? 0,
        role: PlayerRole.values.byName(json['role'] as String? ?? 'civilian'),
        isEliminated: json['isEliminated'] as bool? ?? false,
        word: json['word'] as String?,
        hint: json['hint'] as String?,
        speakingOrder: json['speakingOrder'] as int? ?? 0,
      );
}

class WordEntry {
  final String text;
  final String hint;
  final String difficulty;
  final String ageGroup;

  const WordEntry({
    required this.text,
    required this.hint,
    required this.difficulty,
    required this.ageGroup,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'hint': hint,
        'difficulty': difficulty,
        'ageGroup': ageGroup,
      };

  factory WordEntry.fromJson(Map<String, dynamic> json) => WordEntry(
        text: json['text'] as String,
        hint: json['hint'] as String,
        difficulty: json['difficulty'] as String,
        ageGroup: json['ageGroup'] as String,
      );
}

enum CategoryType { general, region, niche, boysOnly }

class WordCategory {
  final String id;
  final String name;
  final String icon;
  final int color;
  final List<WordEntry> wordList;
  final CategoryType categoryType;
  final bool premiumFlag;
  final String description;

  const WordCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.color = 0xFF7C3AED,
    List<WordEntry>? wordList,
    List<WordEntry>? words,
    CategoryType? categoryTypeParam,
    CategoryType? type,
    bool? premiumFlagParam,
    bool? premium,
    required this.description,
  })  : wordList = wordList ?? words ?? const [],
        categoryType = categoryTypeParam ?? type ?? CategoryType.general,
        premiumFlag = premiumFlagParam ?? premium ?? false;

  List<WordEntry> get words => wordList;
  CategoryType get type => categoryType;
  bool get premium => premiumFlag;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'color': color,
        'wordList': wordList.map((word) => word.toJson()).toList(),
        'categoryType': categoryType.toString(),
        'premiumFlag': premiumFlag,
        'description': description,
      };

  factory WordCategory.fromJson(Map<String, dynamic> json) => WordCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        color: json['color'] as int? ?? 0xFF7C3AED,
        wordList: ((json['wordList'] as List<dynamic>?) ?? (json['words'] as List<dynamic>?) ?? const [])
            .map((word) => WordEntry.fromJson(word as Map<String, dynamic>))
            .toList(),
        categoryTypeParam: CategoryType.values.firstWhere(
          (value) => value.toString() == (json['categoryType'] as String? ?? json['type'] as String?),
          orElse: () => CategoryType.general,
        ),
        premiumFlagParam: json['premiumFlag'] as bool? ?? json['premium'] as bool? ?? false,
        description: json['description'] as String,
      );
}

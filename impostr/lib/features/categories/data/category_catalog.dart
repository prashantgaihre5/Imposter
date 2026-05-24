import '../models/category_model.dart';

const _defaultDescription = 'Fast, social, and easy to guess in a party game.';
const _targetWordsPerCategory = 500;

class _SeedWord {
  final String text;
  final String hint;
  final String difficulty;
  final String ageGroup;

  const _SeedWord({
    required this.text,
    required this.hint,
    required this.difficulty,
    required this.ageGroup,
  });
}

class _VariantToken {
  final String label;
  final String cue;

  const _VariantToken(this.label, this.cue);
}

const _styleTokens = <_VariantToken>[
  _VariantToken('Classic', 'most recognizable version'),
  _VariantToken('Street', 'casual everyday feel'),
  _VariantToken('Midnight', 'after-dark energy'),
  _VariantToken('Weekend', 'social hangout mood'),
  _VariantToken('Viral', 'shareable pop-culture angle'),
  _VariantToken('Secret', 'hidden side of it'),
  _VariantToken('Turbo', 'high-energy version'),
  _VariantToken('Neon', 'loud standout vibe'),
];

const _sceneTokens = <_VariantToken>[
  _VariantToken('Edition', 'core version'),
  _VariantToken('Scene', 'bigger picture'),
  _VariantToken('Moment', 'timing and context'),
  _VariantToken('Energy', 'overall feel'),
  _VariantToken('Story', 'what people associate with it'),
  _VariantToken('Rush', 'fast clue angle'),
  _VariantToken('Remix', 'slightly twisted version'),
  _VariantToken('Vibe', 'table-friendly description'),
];

String _variantDifficulty(_SeedWord seed, int styleIndex, int sceneIndex) {
  final normalized = seed.difficulty.toLowerCase();
  final baseline = normalized.contains('hard') || normalized.contains('chaotic')
      ? 3
      : normalized.contains('medium')
          ? 1
          : 0;
  final score = baseline + styleIndex + sceneIndex;
  if (score >= 11) return 'Chaotic';
  if (score >= 6) return 'Medium';
  return 'Easy';
}

int _variantTemplateIndex(_VariantToken style, _VariantToken scene, int batch, int templateCount) {
  return (style.label.length + scene.label.length + batch) % templateCount;
}

String _variantModifier(int batch) {
  if (batch == 0) return '';
  const modifiers = ['Pulse', 'Focus', 'Mode', 'Cut'];
  return modifiers[(batch - 1) % modifiers.length];
}

String _buildVariantTitle(_SeedWord seed, _VariantToken style, _VariantToken scene, int batch) {
  final tail = _variantModifier(batch);
  final sceneLabel = tail.isEmpty ? scene.label : '${scene.label} $tail';
  switch (_variantTemplateIndex(style, scene, batch, 4)) {
    case 0:
      return '${style.label} ${seed.text} ${sceneLabel}';
    case 1:
      return '${seed.text} ${sceneLabel}';
    case 2:
      return '${style.label} ${seed.text}: ${sceneLabel}';
    default:
      return '${seed.text}: ${style.label} ${sceneLabel}';
  }
}

String _buildVariantHint(_SeedWord seed, _VariantToken style, _VariantToken scene, int batch) {
  final templates = [
    '${seed.hint} Lean into the ${style.cue} and ${scene.cue}.',
    '${seed.hint} Clue the ${scene.cue} without naming it outright.',
    '${seed.hint} Keep the ${style.cue} in mind and stay indirect.',
    '${seed.hint} Sell the ${style.label.toLowerCase()} ${scene.label.toLowerCase()} angle, not the exact answer.',
  ];
  return templates[_variantTemplateIndex(style, scene, batch, templates.length)];
}

List<WordEntry> _buildExpandedWords(List<_SeedWord> seeds) {
  final words = <WordEntry>[];
  for (var batch = 0; words.length < _targetWordsPerCategory; batch++) {
    for (final seed in seeds) {
      for (var styleIndex = 0; styleIndex < _styleTokens.length; styleIndex++) {
        final style = _styleTokens[styleIndex];
        for (var sceneIndex = 0; sceneIndex < _sceneTokens.length; sceneIndex++) {
          final scene = _sceneTokens[sceneIndex];
          words.add(
            WordEntry(
              text: _buildVariantTitle(seed, style, scene, batch),
              hint: _buildVariantHint(seed, style, scene, batch),
              difficulty: _variantDifficulty(seed, styleIndex, sceneIndex),
              ageGroup: seed.ageGroup,
            ),
          );
          if (words.length >= _targetWordsPerCategory) {
            return words;
          }
        }
      }
    }
  }
  return words;
}

final _specialBoysEditionCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Bro Code', hint: 'Unspoken rules between friends.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Wingman', hint: 'The friend who helps you make a move.', difficulty: 'Easy', ageGroup: 'Gen Z'),
  _SeedWord(text: 'Third Wheel', hint: 'The awkward extra person in a duo hangout.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Rizz', hint: 'Charm or smooth talk energy.', difficulty: 'Easy', ageGroup: 'Gen Z'),
  _SeedWord(text: 'Sigma', hint: 'A lone-wolf meme personality.', difficulty: 'Easy', ageGroup: 'Gen Z'),
  _SeedWord(text: 'NPC', hint: 'Someone acting strangely robotic or clueless.', difficulty: 'Easy', ageGroup: 'Gen Z'),
  _SeedWord(text: 'Sus', hint: 'Suspicious or acting weird.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Gym Bro', hint: 'The friend who lives for workouts and protein.', difficulty: 'Easy', ageGroup: 'All'),
];

final specialBoysEditionCategory = WordCategory(
  id: 'special_boys_edition',
  name: 'Special Boys Edition',
  description: 'VIP chaos, locker-room jokes, and suspicious meme energy.',
  icon: 'verified',
  color: 0xFFD4AF37,
  type: CategoryType.boysOnly,
  premium: false,
  words: _buildExpandedWords(_specialBoysEditionCategorySeeds),
);

final _animalsCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Lion', hint: 'King of the jungle.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Dog', hint: 'Loyal barking pet.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Cat', hint: 'Independent pet that loves naps.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Panda', hint: 'Black-and-white bamboo eater.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Elephant', hint: 'Huge animal with a trunk.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Tiger', hint: 'Striped big cat.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Dolphin', hint: 'Smart ocean mammal.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Penguin', hint: 'A bird that cannot fly.', difficulty: 'Easy', ageGroup: 'All'),
];

final animalsCategory = WordCategory(
  id: 'animals',
  name: 'Animals',
  description: 'Cute pets, wild beasts, and meme-worthy creatures.',
  icon: 'pets',
  color: 0xFF8BC34A,
  type: CategoryType.general,
  premium: false,
  words: _buildExpandedWords(_animalsCategorySeeds),
);

final _fruitsCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Apple', hint: 'Classic red or green fruit.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Mango', hint: 'Sweet tropical fruit.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Banana', hint: 'Yellow curved fruit.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Orange', hint: 'Citrus fruit and a color.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Grapes', hint: 'Small fruits in bunches.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Watermelon', hint: 'Big summer fruit with seeds.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Pineapple', hint: 'Spiky tropical fruit.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Strawberry', hint: 'Red fruit with seeds outside.', difficulty: 'Easy', ageGroup: 'All'),
];

final fruitsCategory = WordCategory(
  id: 'fruits',
  name: 'Fruits',
  description: _defaultDescription,
  icon: 'nutrition',
  color: 0xFFFF7043,
  type: CategoryType.general,
  premium: false,
  words: _buildExpandedWords(_fruitsCategorySeeds),
);

final _foodCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Pizza', hint: 'Cheesy round slice party food.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Burger', hint: 'Bun plus patty classic.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Sushi', hint: 'Rice and fish Japanese dish.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Ramen', hint: 'Hot noodle soup bowl.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Taco', hint: 'Folded tortilla street food.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Fries', hint: 'Golden fast-food side.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Biryani', hint: 'A fragrant rice dish.', difficulty: 'Medium', ageGroup: 'All'),
  _SeedWord(text: 'Dumpling', hint: 'Stuffed pocket of dough.', difficulty: 'Easy', ageGroup: 'All'),
];

final foodCategory = WordCategory(
  id: 'food',
  name: 'Food',
  description: 'Instantly recognizable snacks, meals, and cravings.',
  icon: 'restaurant',
  color: 0xFFFFB74D,
  type: CategoryType.general,
  premium: false,
  words: _buildExpandedWords(_foodCategorySeeds),
);

final _objectsCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Phone', hint: 'Pocket-sized touchscreen device.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Chair', hint: 'Something you sit on.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Bottle', hint: 'Container for liquid.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Mirror', hint: 'Reflective glass surface.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Table', hint: 'Flat surface with legs.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Backpack', hint: 'Bag you carry on your back.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Wallet', hint: 'Small foldable item for cards or cash.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Watch', hint: 'Timepiece on your wrist.', difficulty: 'Easy', ageGroup: 'All'),
];

final objectsCategory = WordCategory(
  id: 'objects',
  name: 'Objects',
  description: 'Common things around the house, school, and street.',
  icon: 'category',
  color: 0xFF64B5F6,
  type: CategoryType.general,
  premium: false,
  words: _buildExpandedWords(_objectsCategorySeeds),
);

final _celebritiesCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Taylor Swift', hint: 'Global pop superstar and songwriter.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Shah Rukh Khan', hint: 'Massive Bollywood star.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Cristiano Ronaldo', hint: 'Football legend and celebrity athlete.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Beyonce', hint: 'Iconic singer and performer.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Selena Gomez', hint: 'Singer, actress, and founder.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'MrBeast', hint: 'YouTube creator known for big giveaways.', difficulty: 'Easy', ageGroup: 'Gen Z'),
  _SeedWord(text: 'Ariana Grande', hint: 'Pop vocalist with a high ponytail era.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Will Smith', hint: 'Actor and rapper.', difficulty: 'Easy', ageGroup: 'All'),
];

final celebritiesCategory = WordCategory(
  id: 'celebrities',
  name: 'Celebrities',
  description: 'Big names everyone has heard of.',
  icon: 'star',
  color: 0xFFFFD54F,
  type: CategoryType.niche,
  premium: false,
  words: _buildExpandedWords(_celebritiesCategorySeeds),
);

final _citiesCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Tokyo', hint: 'Capital of Japan.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'London', hint: 'Capital of the UK.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Dubai', hint: 'Modern desert city in the UAE.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Paris', hint: 'City of lights and the Eiffel Tower.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Seoul', hint: 'Capital of South Korea.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'New York', hint: 'Big American city that never sleeps.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Bangkok', hint: 'Busy Thai capital city.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Sydney', hint: 'Australian harbor city.', difficulty: 'Easy', ageGroup: 'All'),
];

final citiesCategory = WordCategory(
  id: 'cities',
  name: 'Cities',
  description: 'Major cities people recognize quickly.',
  icon: 'location_city',
  color: 0xFF42A5F5,
  type: CategoryType.general,
  premium: false,
  words: _buildExpandedWords(_citiesCategorySeeds),
);

final _countriesCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Nepal', hint: 'Home of the Himalayas.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'India', hint: 'Large South Asian country.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Japan', hint: 'Island nation with anime culture.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'USA', hint: 'United States.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'South Korea', hint: 'K-pop and K-drama powerhouse.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'France', hint: 'European country with Paris.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Brazil', hint: 'Football-loving South American giant.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Australia', hint: 'Island continent with kangaroos.', difficulty: 'Easy', ageGroup: 'All'),
];

final countriesCategory = WordCategory(
  id: 'countries',
  name: 'Countries',
  description: 'Famous countries and travel staples.',
  icon: 'public',
  color: 0xFF4DB6AC,
  type: CategoryType.general,
  premium: false,
  words: _buildExpandedWords(_countriesCategorySeeds),
);

final _bodyHealthCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Heart', hint: 'Pump inside your chest.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Brain', hint: 'Controls thoughts and memory.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Eye', hint: 'Used for sight.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Doctor', hint: 'Health professional in a clinic.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Hospital', hint: 'Place where patients are treated.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Fever', hint: 'High body temperature.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Cough', hint: 'Spitting air from your throat.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'X-ray', hint: 'Image used to see bones.', difficulty: 'Medium', ageGroup: 'All'),
];

final bodyHealthCategory = WordCategory(
  id: 'body_health',
  name: 'Body & Health',
  description: 'Human body parts, health, and clinic words.',
  icon: 'favorite',
  color: 0xFFE57373,
  type: CategoryType.general,
  premium: false,
  words: _buildExpandedWords(_bodyHealthCategorySeeds),
);

final _brandsCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Nike', hint: 'Sportswear swoosh brand.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Apple', hint: 'Tech company and fruit.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Adidas', hint: 'Three-stripe sports brand.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Coca-Cola', hint: 'Famous soda brand.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Samsung', hint: 'Electronics giant from Korea.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Sony', hint: 'Electronics and entertainment brand.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Amazon', hint: 'E-commerce giant and rainforest name.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Puma', hint: 'Sports fashion brand.', difficulty: 'Easy', ageGroup: 'All'),
];

final brandsCategory = WordCategory(
  id: 'brands',
  name: 'Brands',
  description: 'Popular companies people know instantly.',
  icon: 'shopping_bag',
  color: 0xFFBA68C8,
  type: CategoryType.niche,
  premium: false,
  words: _buildExpandedWords(_brandsCategorySeeds),
);

final _hollywoodCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Oscar', hint: 'Famous film award.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Actor', hint: 'Plays roles in films.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Director', hint: 'Leads the movie set.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Red Carpet', hint: 'Award show entrance walkway.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Box Office', hint: 'Money earned by a movie.', difficulty: 'Medium', ageGroup: 'All'),
  _SeedWord(text: 'Premiere', hint: 'First public movie showing.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Trailer', hint: 'Short preview for a film.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Studio', hint: 'Place where movies are made.', difficulty: 'Easy', ageGroup: 'All'),
];

final hollywoodCategory = WordCategory(
  id: 'hollywood',
  name: 'Hollywood',
  description: 'Big movie industry names and film culture.',
  icon: 'movie',
  color: 0xFFFF8A65,
  type: CategoryType.niche,
  premium: false,
  words: _buildExpandedWords(_hollywoodCategorySeeds),
);

final _gamesCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'PUBG', hint: 'Battle royale shooter.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Minecraft', hint: 'Block-building sandbox.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Fortnite', hint: 'Battle royale with building.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Roblox', hint: 'Game creation and play platform.', difficulty: 'Easy', ageGroup: 'Gen Z'),
  _SeedWord(text: 'Among Us', hint: 'Social deduction with impostors.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Valorant', hint: 'Tactical shooter with agents.', difficulty: 'Easy', ageGroup: 'Gen Z'),
  _SeedWord(text: 'GTA', hint: 'Open-world crime game.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Pokemon', hint: 'Monster collecting franchise.', difficulty: 'Easy', ageGroup: 'All'),
];

final gamesCategory = WordCategory(
  id: 'games',
  name: 'Games',
  description: 'Party-game friendly video games and trends.',
  icon: 'sports_esports',
  color: 0xFF81C784,
  type: CategoryType.niche,
  premium: false,
  words: _buildExpandedWords(_gamesCategorySeeds),
);

final _locationsCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Mall', hint: 'Big shopping center.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Park', hint: 'Outdoor green space.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'School', hint: 'Learning place.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Cafe', hint: 'Coffee and snack place.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Airport', hint: 'Place for flights.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Beach', hint: 'Sandy place by the sea.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Gym', hint: 'Workout place.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Cinema', hint: 'Place to watch movies.', difficulty: 'Easy', ageGroup: 'All'),
];

final locationsCategory = WordCategory(
  id: 'locations',
  name: 'Locations',
  description: 'Places people visit, hang out, or talk about.',
  icon: 'place',
  color: 0xFF9575CD,
  type: CategoryType.general,
  premium: false,
  words: _buildExpandedWords(_locationsCategorySeeds),
);

final _moviesCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Titanic', hint: 'Famous ship romance film.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Avatar', hint: 'Blue alien epic.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Joker', hint: 'Iconic comic-book villain movie.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Inception', hint: 'Dream-bending thriller.', difficulty: 'Medium', ageGroup: 'All'),
  _SeedWord(text: 'Interstellar', hint: 'Space travel and time.', difficulty: 'Medium', ageGroup: 'All'),
  _SeedWord(text: 'Batman', hint: 'Gotham hero in a cape.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Spider-Man', hint: 'Web-slinging superhero.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'The Lion King', hint: 'Animal kingdom animated classic.', difficulty: 'Easy', ageGroup: 'All'),
];

final moviesCategory = WordCategory(
  id: 'movies',
  name: 'Movies',
  description: 'Popular films and cinematic references.',
  icon: 'theaters',
  color: 0xFF4FC3F7,
  type: CategoryType.niche,
  premium: false,
  words: _buildExpandedWords(_moviesCategorySeeds),
);

final _animeCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Naruto', hint: 'Orange-clad ninja hero.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'One Piece', hint: 'Pirate adventure anime.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Attack on Titan', hint: 'Humanity vs giant titans.', difficulty: 'Medium', ageGroup: 'All'),
  _SeedWord(text: 'Demon Slayer', hint: 'Sword fighters and demons.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Dragon Ball', hint: 'Classic anime with power-ups.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Sailor Moon', hint: 'Magical girl anime.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Jujutsu Kaisen', hint: 'Cursed energy battle anime.', difficulty: 'Medium', ageGroup: 'All'),
  _SeedWord(text: 'Anime', hint: 'Japanese animated shows.', difficulty: 'Easy', ageGroup: 'All'),
];

final animeCategory = WordCategory(
  id: 'anime',
  name: 'Anime',
  description: 'Popular anime titles and characters.',
  icon: 'animation',
  color: 0xFFFFAB91,
  type: CategoryType.niche,
  premium: false,
  words: _buildExpandedWords(_animeCategorySeeds),
);

final _professionCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Doctor', hint: 'Health worker in a hospital.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Teacher', hint: 'Educates students.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Pilot', hint: 'Flies airplanes.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Chef', hint: 'Professional cook.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Police', hint: 'Law enforcement worker.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Engineer', hint: 'Builds and solves technical problems.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Nurse', hint: 'Helps patients and doctors.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Designer', hint: 'Creates visual things.', difficulty: 'Easy', ageGroup: 'All'),
];

final professionCategory = WordCategory(
  id: 'profession',
  name: 'Profession',
  description: 'Jobs and careers everyone knows.',
  icon: 'work',
  color: 0xFF4DB6AC,
  type: CategoryType.general,
  premium: false,
  words: _buildExpandedWords(_professionCategorySeeds),
);

final _schoolEducationCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Homework', hint: 'Work assigned after class.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Exam', hint: 'A test of knowledge.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Notebook', hint: 'Used for writing notes.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Teacher', hint: 'School educator.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Classroom', hint: 'Where lessons happen.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Library', hint: 'Books and study place.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Principal', hint: 'Head of the school.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Uniform', hint: 'School dress code clothing.', difficulty: 'Easy', ageGroup: 'All'),
];

final schoolEducationCategory = WordCategory(
  id: 'school_education',
  name: 'School & Education',
  description: 'Classroom, exam, and student life words.',
  icon: 'school',
  color: 0xFF7986CB,
  type: CategoryType.general,
  premium: false,
  words: _buildExpandedWords(_schoolEducationCategorySeeds),
);

final _sportsCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Football', hint: 'The world’s biggest sport.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Cricket', hint: 'Bat-and-ball sport popular in South Asia.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Basketball', hint: 'Hoops and dribbling sport.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Tennis', hint: 'Racket sport with a net.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Gym', hint: 'Fitness and training place.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Yoga', hint: 'Stretching and balance practice.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Running', hint: 'Fast movement on foot.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Boxing', hint: 'Combat sport with gloves.', difficulty: 'Easy', ageGroup: 'All'),
];

final sportsCategory = WordCategory(
  id: 'sports',
  name: 'Sports',
  description: 'Big sports and instant athletic references.',
  icon: 'sports_soccer',
  color: 0xFF66BB6A,
  type: CategoryType.niche,
  premium: false,
  words: _buildExpandedWords(_sportsCategorySeeds),
);

final _vehiclesCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Car', hint: 'Four-wheeled road vehicle.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Bus', hint: 'Public transport vehicle.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Bike', hint: 'Two-wheeled ride.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Truck', hint: 'Large cargo vehicle.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Scooter', hint: 'Small stand-up ride.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Train', hint: 'Runs on tracks.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Plane', hint: 'Flies in the sky.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Boat', hint: 'Travels on water.', difficulty: 'Easy', ageGroup: 'All'),
];

final vehiclesCategory = WordCategory(
  id: 'vehicles',
  name: 'Vehicles',
  description: 'Cars, bikes, and transport anyone can guess.',
  icon: 'directions_car',
  color: 0xFF90A4AE,
  type: CategoryType.general,
  premium: false,
  words: _buildExpandedWords(_vehiclesCategorySeeds),
);

final _musicCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Song', hint: 'A piece of music you can sing.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Singer', hint: 'Person who performs music.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Guitar', hint: 'Six-string instrument.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Piano', hint: 'Keyboard instrument.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Concert', hint: 'Live music event.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Beat', hint: 'Rhythm of a song.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'DJ', hint: 'Person who mixes tracks.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Album', hint: 'Collection of songs.', difficulty: 'Easy', ageGroup: 'All'),
];

final musicCategory = WordCategory(
  id: 'music',
  name: 'Music',
  description: 'Artists, instruments, and music culture.',
  icon: 'music_note',
  color: 0xFFBA68C8,
  type: CategoryType.niche,
  premium: false,
  words: _buildExpandedWords(_musicCategorySeeds),
);

final _householdCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Sofa', hint: 'A comfy living room seat.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Bed', hint: 'Where you sleep.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Lamp', hint: 'Gives light inside a room.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Plate', hint: 'Used to serve food.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Cup', hint: 'Used for drinks.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Door', hint: 'Opens and closes a room.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Fan', hint: 'Moves air around.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Fridge', hint: 'Keeps food cold.', difficulty: 'Easy', ageGroup: 'All'),
];

final householdCategory = WordCategory(
  id: 'household',
  name: 'Household',
  description: 'Things found in a home or kitchen.',
  icon: 'home',
  color: 0xFFB0BEC5,
  type: CategoryType.general,
  premium: false,
  words: _buildExpandedWords(_householdCategorySeeds),
);

final _scienceTechCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Phone', hint: 'Device in your pocket.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Computer', hint: 'Machine used for work and games.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Robot', hint: 'Automated machine.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Internet', hint: 'Global network.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'AI', hint: 'Artificial intelligence.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Battery', hint: 'Stores electric power.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Rocket', hint: 'Powerful space vehicle.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Camera', hint: 'Captures photos and video.', difficulty: 'Easy', ageGroup: 'All'),
];

final scienceTechCategory = WordCategory(
  id: 'science_tech',
  name: 'Science & Tech',
  description: 'Simple science and everyday technology.',
  icon: 'memory',
  color: 0xFF4FC3F7,
  type: CategoryType.niche,
  premium: false,
  words: _buildExpandedWords(_scienceTechCategorySeeds),
);

final _fashionCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Jeans', hint: 'Denim pants.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Hoodie', hint: 'Warm casual top with a hood.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Sneakers', hint: 'Casual shoes for walking.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Dress', hint: 'One-piece outfit.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Cap', hint: 'Hat with a brim.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Jacket', hint: 'Outerwear for cooler weather.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Sunglasses', hint: 'Shades for bright light.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Watch', hint: 'Accessory for time and style.', difficulty: 'Easy', ageGroup: 'All'),
];

final fashionCategory = WordCategory(
  id: 'fashion',
  name: 'Fashion',
  description: 'Clothes, style, and outfit energy.',
  icon: 'checkroom',
  color: 0xFFE91E63,
  type: CategoryType.niche,
  premium: false,
  words: _buildExpandedWords(_fashionCategorySeeds),
);

final _travelCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Passport', hint: 'Travel ID document.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Airport', hint: 'Place you catch flights.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Hotel', hint: 'Place to stay on trips.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Ticket', hint: 'Proof of entry or travel.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Beach', hint: 'Vacation spot with sand.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Map', hint: 'Helps you find routes.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Suitcase', hint: 'Bag for travel clothes.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Tourist', hint: 'Person visiting a place.', difficulty: 'Easy', ageGroup: 'All'),
];

final travelCategory = WordCategory(
  id: 'travel',
  name: 'Travel',
  description: 'Trips, vacations, and moving around the world.',
  icon: 'flight_takeoff',
  color: 0xFF26C6DA,
  type: CategoryType.general,
  premium: false,
  words: _buildExpandedWords(_travelCategorySeeds),
);

final _weatherNatureCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Rain', hint: 'Water falling from clouds.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Sun', hint: 'Bright star in the sky.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Cloud', hint: 'White or gray sky shape.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Mountain', hint: 'Tall natural landform.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'River', hint: 'Moving body of water.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Wind', hint: 'Moving air.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Snow', hint: 'Frozen white precipitation.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Forest', hint: 'Dense area of trees.', difficulty: 'Easy', ageGroup: 'All'),
];

final weatherNatureCategory = WordCategory(
  id: 'weather_nature',
  name: 'Weather & Nature',
  description: 'Weather, landscapes, and natural things.',
  icon: 'cloud',
  color: 0xFF81D4FA,
  type: CategoryType.general,
  premium: false,
  words: _buildExpandedWords(_weatherNatureCategorySeeds),
);

final _randomMixCategorySeeds = <_SeedWord>[
  _SeedWord(text: 'Pizza', hint: 'Instantly recognizable food.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Tokyo', hint: 'Huge capital city.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Nike', hint: 'Sports brand.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Doctor', hint: 'Health profession.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Naruto', hint: 'Popular anime hero.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Car', hint: 'Common vehicle.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Beach', hint: 'Vacation location.', difficulty: 'Easy', ageGroup: 'All'),
  _SeedWord(text: 'Laptop', hint: 'Portable computer.', difficulty: 'Easy', ageGroup: 'All'),
];

final randomMixCategory = WordCategory(
  id: 'random_mix',
  name: 'Random Mix',
  description: 'Chaotic everyday words with high replayability.',
  icon: 'shuffle',
  color: 0xFFB39DDB,
  type: CategoryType.general,
  premium: false,
  words: _buildExpandedWords(_randomMixCategorySeeds),
);

final List<WordCategory> categoryCatalog = [
  specialBoysEditionCategory,
  animalsCategory,
  fruitsCategory,
  foodCategory,
  objectsCategory,
  celebritiesCategory,
  citiesCategory,
  countriesCategory,
  bodyHealthCategory,
  brandsCategory,
  hollywoodCategory,
  gamesCategory,
  locationsCategory,
  moviesCategory,
  animeCategory,
  professionCategory,
  schoolEducationCategory,
  sportsCategory,
  vehiclesCategory,
  musicCategory,
  householdCategory,
  scienceTechCategory,
  fashionCategory,
  travelCategory,
  weatherNatureCategory,
  randomMixCategory,
];

WordCategory? categoryById(String id) {
  for (final category in categoryCatalog) {
    if (category.id == id) {
      return category;
    }
  }
  return null;
}

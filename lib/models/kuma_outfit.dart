enum OutfitType {
  defaultBear,

  // Seasonal
  santaHat,
  halloweenPumpkin,
  halloweenVampire,
  hawaiianShirt,
  sunglassesBeach,
  valentinesHearts,
  easterBunny,
  newYearParty,
  winterScarf,

  // Achievement-based
  businessSuit,
  kimono,
  samuraiHelmet,
  chefHat,
  graduationCap,
  ninja,
  astronaut,
  pirate,
}

enum UnlockType {
  defaultUnlock,
  seasonal,
  level,
  wordsMastered,
  streak,
  categoryComplete,
}

class UnlockCondition {
  final UnlockType type;
  final String? season;
  final int? value;
  final String? category;

  const UnlockCondition({
    required this.type,
    this.season,
    this.value,
    this.category,
  });
}

class KumaOutfit {
  final OutfitType type;
  final String name;
  final String description;
  final String imagePath;
  final UnlockCondition unlockCondition;
  final bool isUnlocked;

  const KumaOutfit({
    required this.type,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.unlockCondition,
    this.isUnlocked = false,
  });

  KumaOutfit copyWith({bool? isUnlocked}) {
    return KumaOutfit(
      type: type,
      name: name,
      description: description,
      imagePath: imagePath,
      unlockCondition: unlockCondition,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class AppThemeData {
  final String id;
  final String name;
  final int primaryColor;
  final int backgroundColor;
  final int cardColor;
  final int textColor;
  final int accentColor;
  final UnlockCondition unlockCondition;
  final bool isUnlocked;

  const AppThemeData({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.accentColor,
    required this.unlockCondition,
    this.isUnlocked = false,
  });

  AppThemeData copyWith({bool? isUnlocked}) {
    return AppThemeData(
      id: id,
      name: name,
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      cardColor: cardColor,
      textColor: textColor,
      accentColor: accentColor,
      unlockCondition: unlockCondition,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class KumaOutfitData {
  static List<KumaOutfit> getAllOutfits() {
    return const [
      // Default
      KumaOutfit(
        type: OutfitType.defaultBear,
        name: 'Classic Kuma',
        description: 'The original bear!',
        imagePath: 'assets/images/kuma.png',
        unlockCondition: UnlockCondition(type: UnlockType.defaultUnlock),
      ),

      // CHRISTMAS (December)
      KumaOutfit(
        type: OutfitType.santaHat,
        name: 'Santa Kuma',
        description: 'Ho ho ho! Merry Christmas!',
        imagePath: 'assets/images/kuma_santa.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.seasonal,
          season: 'christmas',
        ),
      ),

      // HALLOWEEN (October)
      KumaOutfit(
        type: OutfitType.halloweenPumpkin,
        name: 'Pumpkin Kuma',
        description: 'Trick or treat!',
        imagePath: 'assets/images/kuma_halloween.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.seasonal,
          season: 'halloween',
        ),
      ),
      KumaOutfit(
        type: OutfitType.halloweenVampire,
        name: 'Vampire Kuma',
        description: 'I vant to learn Japanese!',
        imagePath: 'assets/images/kuma_vampire.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.seasonal,
          season: 'halloween',
        ),
      ),

      // SUMMER (June-August)
      KumaOutfit(
        type: OutfitType.hawaiianShirt,
        name: 'Hawaiian Kuma',
        description: 'Aloha! Beach vibes!',
        imagePath: 'assets/images/kuma_hawaiian.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.seasonal,
          season: 'summer',
        ),
      ),
      KumaOutfit(
        type: OutfitType.sunglassesBeach,
        name: 'Beach Kuma',
        description: 'Sunglasses and chill!',
        imagePath: 'assets/images/kuma_sunglasses.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.seasonal,
          season: 'summer',
        ),
      ),

      // VALENTINE'S DAY (Feb 1-14)
      KumaOutfit(
        type: OutfitType.valentinesHearts,
        name: 'Love Kuma',
        description: 'Spread the love!',
        imagePath: 'assets/images/kuma_valentines.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.seasonal,
          season: 'valentines',
        ),
      ),

      // EASTER (March-April)
      KumaOutfit(
        type: OutfitType.easterBunny,
        name: 'Bunny Kuma',
        description: 'Hop hop hop!',
        imagePath: 'assets/images/kuma_easter.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.seasonal,
          season: 'easter',
        ),
      ),

      // NEW YEAR (Dec 31 - Jan 7)
      KumaOutfit(
        type: OutfitType.newYearParty,
        name: 'Party Kuma',
        description: 'Happy New Year!',
        imagePath: 'assets/images/kuma_newyear.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.seasonal,
          season: 'new_year',
        ),
      ),

      // WINTER (Dec-Feb)
      KumaOutfit(
        type: OutfitType.winterScarf,
        name: 'Cozy Kuma',
        description: 'Warm and snuggly!',
        imagePath: 'assets/images/kuma_scarf.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.seasonal,
          season: 'winter',
        ),
      ),

      // ACHIEVEMENT-BASED

      // Business - 100 words
      KumaOutfit(
        type: OutfitType.businessSuit,
        name: 'Business Kuma',
        description: 'Professional bear!',
        imagePath: 'assets/images/kuma_business.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.wordsMastered,
          value: 100,
        ),
      ),

      // Kimono - 30 day streak
      KumaOutfit(
        type: OutfitType.kimono,
        name: 'Kimono Kuma',
        description: 'Traditional Japanese style!',
        imagePath: 'assets/images/kuma_kimono.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.streak,
          value: 30,
        ),
      ),

      // Samurai - 200 words
      KumaOutfit(
        type: OutfitType.samuraiHelmet,
        name: 'Samurai Kuma',
        description: 'The way of the warrior!',
        imagePath: 'assets/images/kuma_samurai.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.wordsMastered,
          value: 200,
        ),
      ),

      // Chef - Food category complete
      KumaOutfit(
        type: OutfitType.chefHat,
        name: 'Chef Kuma',
        description: 'Master of Japanese cuisine!',
        imagePath: 'assets/images/kuma_chef.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.categoryComplete,
          category: 'Food',
        ),
      ),

      // Graduate - Level 10
      KumaOutfit(
        type: OutfitType.graduationCap,
        name: 'Graduate Kuma',
        description: 'You did it!',
        imagePath: 'assets/images/kuma_graduation.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.level,
          value: 10,
        ),
      ),

      // Ninja - 50 day streak
      KumaOutfit(
        type: OutfitType.ninja,
        name: 'Ninja Kuma',
        description: 'Stealthy learner!',
        imagePath: 'assets/images/kuma_ninja.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.streak,
          value: 50,
        ),
      ),

      // Astronaut - 500 words
      KumaOutfit(
        type: OutfitType.astronaut,
        name: 'Space Kuma',
        description: 'To infinity and beyond!',
        imagePath: 'assets/images/kuma_astronaut.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.wordsMastered,
          value: 500,
        ),
      ),

      // Pirate - Level 15
      KumaOutfit(
        type: OutfitType.pirate,
        name: 'Pirate Kuma',
        description: 'Yarrr! Treasure hunter!',
        imagePath: 'assets/images/kuma_pirate.png',
        unlockCondition: UnlockCondition(
          type: UnlockType.level,
          value: 15,
        ),
      ),
    ];
  }

  static List<AppThemeData> getAllThemes() {
    return const [
      // Default
      AppThemeData(
        id: 'default',
        name: 'Classic Brown',
        primaryColor: 0xFF8b6f47,
        backgroundColor: 0xFFF5EBE0,
        cardColor: 0xFFFFFFFF,
        textColor: 0xFF4a4a4a,
        accentColor: 0xFF8b6f47,
        unlockCondition: UnlockCondition(type: UnlockType.defaultUnlock),
      ),

      // Halloween
      AppThemeData(
        id: 'halloween',
        name: 'Halloween Night',
        primaryColor: 0xFFff6b35,
        backgroundColor: 0xFF1a1a1a,
        cardColor: 0xFF2d2d2d,
        textColor: 0xFFffffff,
        accentColor: 0xFFffaa00,
        unlockCondition: UnlockCondition(
          type: UnlockType.seasonal,
          season: 'halloween',
        ),
      ),

      // Christmas
      AppThemeData(
        id: 'christmas',
        name: 'Christmas Magic',
        primaryColor: 0xFFc41e3a,
        backgroundColor: 0xFFfff9f0,
        cardColor: 0xFFffffff,
        textColor: 0xFF2c2416,
        accentColor: 0xFF0f7347,
        unlockCondition: UnlockCondition(
          type: UnlockType.seasonal,
          season: 'christmas',
        ),
      ),

      // Valentine's
      AppThemeData(
        id: 'valentines',
        name: 'Valentine Love',
        primaryColor: 0xFFff69b4,
        backgroundColor: 0xFFfff0f5,
        cardColor: 0xFFffb7c5,
        textColor: 0xFF2c2416,
        accentColor: 0xFFff1493,
        unlockCondition: UnlockCondition(
          type: UnlockType.seasonal,
          season: 'valentines',
        ),
      ),

      // Summer
      AppThemeData(
        id: 'summer',
        name: 'Summer Beach',
        primaryColor: 0xFF00bcd4,
        backgroundColor: 0xFFe0f7fa,
        cardColor: 0xFFb2ebf2,
        textColor: 0xFF2c2416,
        accentColor: 0xFFffeb3b,
        unlockCondition: UnlockCondition(
          type: UnlockType.seasonal,
          season: 'summer',
        ),
      ),

      // Autumn
      AppThemeData(
        id: 'autumn',
        name: 'Autumn Leaves',
        primaryColor: 0xFFd84315,
        backgroundColor: 0xFFfff3e0,
        cardColor: 0xFFffe0b2,
        textColor: 0xFF2c2416,
        accentColor: 0xFFff6f00,
        unlockCondition: UnlockCondition(
          type: UnlockType.wordsMastered,
          value: 150,
        ),
      ),

      // Sakura
      AppThemeData(
        id: 'sakura',
        name: 'Sakura Spring',
        primaryColor: 0xFFe91e8c,
        backgroundColor: 0xFFfce4ec,
        cardColor: 0xFFf8bbd0,
        textColor: 0xFF4a2040,
        accentColor: 0xFFff80ab,
        unlockCondition: UnlockCondition(
          type: UnlockType.streak,
          value: 14,
        ),
      ),

      // Midnight
      AppThemeData(
        id: 'midnight',
        name: 'Midnight Study',
        primaryColor: 0xFF5c6bc0,
        backgroundColor: 0xFF1a1a2e,
        cardColor: 0xFF16213e,
        textColor: 0xFFe0e0e0,
        accentColor: 0xFF7c4dff,
        unlockCondition: UnlockCondition(
          type: UnlockType.level,
          value: 5,
        ),
      ),
    ];
  }
}

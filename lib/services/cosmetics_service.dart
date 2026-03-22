import 'package:shared_preferences/shared_preferences.dart';
import '../models/kuma_outfit.dart';
import '../models/user_stats.dart';

class CosmeticsService {
  CosmeticsService._();
  static final CosmeticsService _instance = CosmeticsService._();
  factory CosmeticsService() => _instance;

  static const String _selectedOutfitKey = 'selected_outfit';
  static const String _selectedThemeKey = 'selected_theme';
  static const String _lastSeasonalCheckKey = 'last_seasonal_check';
  static const String _seenSeasonalKey = 'seen_seasonal_outfits';

  OutfitType _selectedOutfit = OutfitType.defaultBear;
  String _selectedThemeId = 'default';
  Set<String> _seenSeasonalIds = {};
  bool _loaded = false;

  OutfitType get selectedOutfit => _selectedOutfit;
  String get selectedThemeId => _selectedThemeId;

  // ── Load / save persistence ──────────────────────────────────

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();

    final outfitName = prefs.getString(_selectedOutfitKey);
    if (outfitName != null) {
      _selectedOutfit = OutfitType.values.firstWhere(
        (e) => e.name == outfitName,
        orElse: () => OutfitType.defaultBear,
      );
    }

    _selectedThemeId = prefs.getString(_selectedThemeKey) ?? 'default';

    final seenJson = prefs.getStringList(_seenSeasonalKey);
    if (seenJson != null) {
      _seenSeasonalIds = seenJson.toSet();
    }

    _loaded = true;
  }

  Future<void> selectOutfit(OutfitType outfit) async {
    _selectedOutfit = outfit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedOutfitKey, outfit.name);
  }

  Future<void> selectTheme(String themeId) async {
    _selectedThemeId = themeId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedThemeKey, themeId);
  }

  // ── Seasonal logic ─────────────────────────────────────────

  bool isSeasonActive(String season) {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;

    switch (season) {
      case 'christmas':
        return month == 12;
      case 'halloween':
        return month == 10;
      case 'summer':
        return month >= 6 && month <= 8;
      case 'valentines':
        return month == 2 && day <= 14;
      case 'easter':
        return month == 3 || month == 4;
      case 'new_year':
        return (month == 12 && day >= 31) || (month == 1 && day <= 7);
      case 'winter':
        return month == 12 || month == 1 || month == 2;
      default:
        return false;
    }
  }

  // ── Outfit availability ────────────────────────────────────

  List<KumaOutfit> getAvailableOutfits(UserStats stats, {int studiedLanguageCount = 1}) {
    final all = KumaOutfitData.getAllOutfits();

    return all.map((outfit) {
      bool unlocked = false;

      switch (outfit.unlockCondition.type) {
        case UnlockType.defaultUnlock:
          unlocked = true;
          break;
        case UnlockType.seasonal:
          unlocked = isSeasonActive(outfit.unlockCondition.season!);
          break;
        case UnlockType.level:
          unlocked = stats.level >= outfit.unlockCondition.value!;
          break;
        case UnlockType.wordsMastered:
          unlocked = stats.totalWordsLearned >= outfit.unlockCondition.value!;
          break;
        case UnlockType.streak:
          unlocked = stats.currentStreak >= outfit.unlockCondition.value!;
          break;
        case UnlockType.categoryComplete:
          // Category completion would need StudyProvider context
          // For now check by word count as approximation
          unlocked = false;
          break;
      }

      return outfit.copyWith(isUnlocked: unlocked);
    }).toList();
  }

  List<AppThemeData> getAvailableThemes(UserStats stats) {
    final all = KumaOutfitData.getAllThemes();

    return all.map((theme) {
      bool unlocked = false;

      switch (theme.unlockCondition.type) {
        case UnlockType.defaultUnlock:
          unlocked = true;
          break;
        case UnlockType.seasonal:
          unlocked = isSeasonActive(theme.unlockCondition.season!);
          break;
        case UnlockType.level:
          unlocked = stats.level >= theme.unlockCondition.value!;
          break;
        case UnlockType.wordsMastered:
          unlocked = stats.totalWordsLearned >= theme.unlockCondition.value!;
          break;
        case UnlockType.streak:
          unlocked = stats.currentStreak >= theme.unlockCondition.value!;
          break;
        case UnlockType.categoryComplete:
          unlocked = false;
          break;
      }

      return theme.copyWith(isUnlocked: unlocked);
    }).toList();
  }

  // ── Seasonal notifications ─────────────────────────────────

  /// Returns newly available seasonal outfits that the user hasn't seen yet.
  Future<List<KumaOutfit>> checkSeasonalUnlocks() async {
    await load();
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastCheck = prefs.getString(_lastSeasonalCheckKey);

    if (lastCheck == today) return [];

    final seasonalOutfits = KumaOutfitData.getAllOutfits().where((outfit) {
      if (outfit.unlockCondition.type != UnlockType.seasonal) return false;
      if (!isSeasonActive(outfit.unlockCondition.season!)) return false;
      if (_seenSeasonalIds.contains(outfit.type.name)) return false;
      return true;
    }).toList();

    if (seasonalOutfits.isNotEmpty) {
      for (final outfit in seasonalOutfits) {
        _seenSeasonalIds.add(outfit.type.name);
      }
      await prefs.setStringList(_seenSeasonalKey, _seenSeasonalIds.toList());
    }

    await prefs.setString(_lastSeasonalCheckKey, today);
    return seasonalOutfits;
  }

  // ── Get current outfit data ────────────────────────────────

  KumaOutfit getCurrentOutfit() {
    return KumaOutfitData.getAllOutfits().firstWhere(
      (o) => o.type == _selectedOutfit,
      orElse: () => KumaOutfitData.getAllOutfits().first,
    );
  }

  AppThemeData getCurrentTheme() {
    return KumaOutfitData.getAllThemes().firstWhere(
      (t) => t.id == _selectedThemeId,
      orElse: () => KumaOutfitData.getAllThemes().first,
    );
  }

  // ── Unlock progress text ───────────────────────────────────

  String getOutfitUnlockHint(KumaOutfit outfit) {
    final cond = outfit.unlockCondition;
    switch (cond.type) {
      case UnlockType.defaultUnlock:
        return 'Always available';
      case UnlockType.seasonal:
        return _seasonDisplayName(cond.season!);
      case UnlockType.level:
        return 'Reach level ${cond.value}';
      case UnlockType.wordsMastered:
        return 'Master ${cond.value} words';
      case UnlockType.streak:
        return '${cond.value} day streak';
      case UnlockType.categoryComplete:
        return 'Complete ${cond.category} category';
    }
  }

  String getThemeUnlockHint(AppThemeData theme) {
    final cond = theme.unlockCondition;
    switch (cond.type) {
      case UnlockType.defaultUnlock:
        return 'Always available';
      case UnlockType.seasonal:
        return _seasonDisplayName(cond.season!);
      case UnlockType.level:
        return 'Reach level ${cond.value}';
      case UnlockType.wordsMastered:
        return 'Master ${cond.value} words';
      case UnlockType.streak:
        return '${cond.value} day streak';
      case UnlockType.categoryComplete:
        return 'Complete ${cond.category} category';
    }
  }

  String _seasonDisplayName(String season) {
    switch (season) {
      case 'christmas':
        return 'Available in December';
      case 'halloween':
        return 'Available in October';
      case 'summer':
        return 'Available Jun - Aug';
      case 'valentines':
        return 'Available Feb 1-14';
      case 'easter':
        return 'Available Mar - Apr';
      case 'new_year':
        return 'Available Dec 31 - Jan 7';
      case 'winter':
        return 'Available Dec - Feb';
      default:
        return 'Seasonal';
    }
  }
}

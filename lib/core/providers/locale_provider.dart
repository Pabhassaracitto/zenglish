import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile_provider.dart';

class SupportedLanguage {
  final String code;
  final String? countryCode;
  final String nativeName;
  final String englishName;
  final String displayTag;
  final List<String> aliases;

  const SupportedLanguage({
    required this.code,
    this.countryCode,
    required this.nativeName,
    required this.englishName,
    required this.displayTag,
    required this.aliases,
  });

  Locale get locale => countryCode != null ? Locale(code, countryCode) : Locale(code);

  String get localeKey => countryCode != null ? '${code}_$countryCode' : code;

  /// Formatted name with 3 components: Native · English (TAG)
  /// e.g. "Tiếng Việt · Vietnamese (VI)" or "English (EN)"
  String get formattedName {
    if (nativeName.toLowerCase() == englishName.toLowerCase()) {
      return '$englishName ($displayTag)';
    }
    return '$nativeName · $englishName ($displayTag)';
  }

  bool matchesQuery(String query) {
    if (query.trim().isEmpty) return true;
    final q = query.trim().toLowerCase();
    if (code.toLowerCase() == q || displayTag.toLowerCase() == q) return true;
    if (nativeName.toLowerCase().contains(q)) return true;
    if (englishName.toLowerCase().contains(q)) return true;
    for (final alias in aliases) {
      if (alias.toLowerCase().contains(q)) return true;
    }
    return false;
  }
}

/// 26 Supported Languages with multi-alias search & 3-component formatting
final List<SupportedLanguage> appSupportedLanguages = [
  const SupportedLanguage(
    code: 'vi', countryCode: 'VN',
    nativeName: 'Tiếng Việt', englishName: 'Vietnamese', displayTag: 'VI',
    aliases: ['vi', 'vn', 'vietnamese', 'tieng viet', 'viet nam'],
  ),
  const SupportedLanguage(
    code: 'en', countryCode: 'US',
    nativeName: 'English', englishName: 'English', displayTag: 'EN',
    aliases: ['en', 'us', 'english', 'tieng anh'],
  ),
  const SupportedLanguage(
    code: 'zh',
    nativeName: '简体中文', englishName: 'Simplified Chinese', displayTag: 'ZH',
    aliases: ['zh', 'cn', 'chinese', 'simplified chinese', 'tieng trung', 'trung quoc'],
  ),
  const SupportedLanguage(
    code: 'zh', countryCode: 'TW',
    nativeName: '繁體中文', englishName: 'Traditional Chinese', displayTag: 'ZH-TW',
    aliases: ['zh-tw', 'tw', 'traditional chinese', 'taiwan', 'tieng trung dai loan'],
  ),
  const SupportedLanguage(
    code: 'si',
    nativeName: 'සිංහල', englishName: 'Sinhala', displayTag: 'SI',
    aliases: ['si', 'sinhala', 'sri lanka', 'tieng sinhala'],
  ),
  const SupportedLanguage(
    code: 'hi',
    nativeName: 'हिन्दी', englishName: 'Hindi', displayTag: 'HI',
    aliases: ['hi', 'hindi', 'india', 'tieng an do'],
  ),
  const SupportedLanguage(
    code: 'my',
    nativeName: 'မြန်မာ', englishName: 'Myanmar / Burmese', displayTag: 'MY',
    aliases: ['my', 'myanmar', 'burmese', 'mien dien', 'burma'],
  ),
  const SupportedLanguage(
    code: 'ar',
    nativeName: 'العربية', englishName: 'Arabic', displayTag: 'AR',
    aliases: ['ar', 'arabic', 'tieng a rap'],
  ),
  const SupportedLanguage(
    code: 'bn',
    nativeName: 'বাংলা', englishName: 'Bengali', displayTag: 'BN',
    aliases: ['bn', 'bengali', 'bangladesh'],
  ),
  const SupportedLanguage(
    code: 'bo',
    nativeName: 'བོད་ཡིག', englishName: 'Tibetan', displayTag: 'BO',
    aliases: ['bo', 'tibetan', 'tibet', 'tay tang'],
  ),
  const SupportedLanguage(
    code: 'de',
    nativeName: 'Deutsch', englishName: 'German', displayTag: 'DE',
    aliases: ['de', 'german', 'deutsch', 'tieng duc'],
  ),
  const SupportedLanguage(
    code: 'es',
    nativeName: 'Español', englishName: 'Spanish', displayTag: 'ES',
    aliases: ['es', 'spanish', 'espanol', 'tieng tay ban nha'],
  ),
  const SupportedLanguage(
    code: 'fr',
    nativeName: 'Français', englishName: 'French', displayTag: 'FR',
    aliases: ['fr', 'french', 'francais', 'tieng phap'],
  ),
  const SupportedLanguage(
    code: 'id',
    nativeName: 'Bahasa Indonesia', englishName: 'Indonesian', displayTag: 'ID',
    aliases: ['id', 'indonesian', 'bahasa', 'tieng indonesia'],
  ),
  const SupportedLanguage(
    code: 'it',
    nativeName: 'Italiano', englishName: 'Italian', displayTag: 'IT',
    aliases: ['it', 'italian', 'italiano', 'tieng y'],
  ),
  const SupportedLanguage(
    code: 'ja',
    nativeName: '日本語', englishName: 'Japanese', displayTag: 'JA',
    aliases: ['ja', 'japanese', 'nihongo', 'tieng nhat'],
  ),
  const SupportedLanguage(
    code: 'km',
    nativeName: 'ភាសាខ្មែរ', englishName: 'Khmer', displayTag: 'KM',
    aliases: ['km', 'khmer', 'cambodia', 'tieng khmer', 'campuchia'],
  ),
  const SupportedLanguage(
    code: 'ko',
    nativeName: '한국어', englishName: 'Korean', displayTag: 'KO',
    aliases: ['ko', 'korean', 'tieng han'],
  ),
  const SupportedLanguage(
    code: 'lo',
    nativeName: 'ລາວ', englishName: 'Lao', displayTag: 'LO',
    aliases: ['lo', 'lao', 'laos', 'tieng lao'],
  ),
  const SupportedLanguage(
    code: 'mn',
    nativeName: 'Монгол', englishName: 'Mongolian', displayTag: 'MN',
    aliases: ['mn', 'mongolian', 'mongolia', 'mong co'],
  ),
  const SupportedLanguage(
    code: 'mr',
    nativeName: 'मराठी', englishName: 'Marathi', displayTag: 'MR',
    aliases: ['mr', 'marathi', 'india'],
  ),
  const SupportedLanguage(
    code: 'pt',
    nativeName: 'Português', englishName: 'Portuguese', displayTag: 'PT',
    aliases: ['pt', 'portuguese', 'portugues', 'tieng bo dao nha'],
  ),
  const SupportedLanguage(
    code: 'ru',
    nativeName: 'Русский', englishName: 'Russian', displayTag: 'RU',
    aliases: ['ru', 'russian', 'tieng nga'],
  ),
  const SupportedLanguage(
    code: 'ta',
    nativeName: 'தமிழ்', englishName: 'Tamil', displayTag: 'TA',
    aliases: ['ta', 'tamil', 'india'],
  ),
  const SupportedLanguage(
    code: 'te',
    nativeName: 'తెలుగు', englishName: 'Telugu', displayTag: 'TE',
    aliases: ['te', 'telugu', 'india'],
  ),
  const SupportedLanguage(
    code: 'th',
    nativeName: 'ไทย', englishName: 'Thai', displayTag: 'TH',
    aliases: ['th', 'thai', 'tieng thai'],
  ),
];

class LocaleNotifierState {
  final Locale? currentLocale;
  final Locale? previousLocale;

  const LocaleNotifierState({
    required this.currentLocale,
    this.previousLocale,
  });

  LocaleNotifierState copyWith({
    Locale? currentLocale,
    Locale? previousLocale,
    bool clearPrevious = false,
  }) {
    return LocaleNotifierState(
      currentLocale: currentLocale ?? this.currentLocale,
      previousLocale: clearPrevious ? null : (previousLocale ?? this.previousLocale),
    );
  }
}

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier(this._prefs) : super(_loadInitialLocale(_prefs));

  final SharedPreferences _prefs;
  static const _storageKey = 'user_selected_locale';

  Locale? _previousLocale;

  Locale? get previousLocale => _previousLocale;

  /// Multi-tier Fallback Strategy:
  /// Saved Locale → System Locale (if supported) → English ('en') / Default ('vi')
  static Locale? _loadInitialLocale(SharedPreferences prefs) {
    try {
      final savedKey = prefs.getString(_storageKey);
      if (savedKey != null && savedKey.isNotEmpty) {
        final parsed = _parseLocaleKey(savedKey);
        if (_isLocaleSupported(parsed)) {
          return parsed;
        }
      }

      // System Locale check
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (_isLocaleSupported(systemLocale)) {
        return null; // Null represents system default
      }

      // Fallback
      return null;
    } catch (_) {
      return null; // Safe fallback
    }
  }

  static Locale _parseLocaleKey(String key) {
    final parts = key.split('_');
    if (parts.length > 1) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  static bool _isLocaleSupported(Locale locale) {
    return appSupportedLanguages.any((lang) =>
        lang.code == locale.languageCode &&
        (lang.countryCode == null || lang.countryCode == locale.countryCode));
  }

  /// Sets locale only after confirmation (Point 7) and saves to SharedPreferences
  Future<void> setLocaleConfirmed(Locale? newLocale) async {
    _previousLocale = state;
    state = newLocale;

    if (newLocale == null) {
      await _prefs.remove(_storageKey);
    } else {
      final key = newLocale.countryCode != null && newLocale.countryCode!.isNotEmpty
          ? '${newLocale.languageCode}_${newLocale.countryCode}'
          : newLocale.languageCode;
      await _prefs.setString(_storageKey, key);
    }
  }

  /// Undo last locale switch (Point 4)
  Future<void> undoLocaleChange() async {
    if (_previousLocale != null) {
      final target = _previousLocale;
      _previousLocale = state;
      state = target;
      if (target == null) {
        await _prefs.remove(_storageKey);
      } else {
        final key = target.countryCode != null && target.countryCode!.isNotEmpty
            ? '${target.languageCode}_${target.countryCode}'
            : target.languageCode;
        await _prefs.setString(_storageKey, key);
      }
    }
  }

  /// Emergency Restore (Point 5): Resets to System Default
  Future<void> resetToSystem() async {
    await setLocaleConfirmed(null);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

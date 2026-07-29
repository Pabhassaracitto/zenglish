import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile_provider.dart';

class SupportedLanguage {
  final String code;
  final String? countryCode;
  final String nativeName;
  final String englishName;
  final String flagEmoji;

  const SupportedLanguage({
    required this.code,
    this.countryCode,
    required this.nativeName,
    required this.englishName,
    required this.flagEmoji,
  });

  Locale get locale => countryCode != null ? Locale(code, countryCode) : Locale(code);

  String get localeKey => countryCode != null ? '${code}_$countryCode' : code;
}

final List<SupportedLanguage> appSupportedLanguages = [
  const SupportedLanguage(code: 'vi', countryCode: 'VN', nativeName: 'Tiếng Việt', englishName: 'Vietnamese', flagEmoji: '🇻🇳'),
  const SupportedLanguage(code: 'en', countryCode: 'US', nativeName: 'English', englishName: 'English', flagEmoji: '🇺🇸'),
  const SupportedLanguage(code: 'zh', nativeName: '中文 (简体)', englishName: 'Chinese (Simplified)', flagEmoji: '🇨🇳'),
  const SupportedLanguage(code: 'zh', countryCode: 'TW', nativeName: '中文 (繁體)', englishName: 'Chinese (Traditional)', flagEmoji: '🇹🇼'),
  const SupportedLanguage(code: 'si', nativeName: 'සිංහල', englishName: 'Sinhala', flagEmoji: '🇱🇰'),
  const SupportedLanguage(code: 'hi', nativeName: 'हिन्दी', englishName: 'Hindi', flagEmoji: '🇮🇳'),
  const SupportedLanguage(code: 'my', nativeName: 'မြန်မာဘာသာ', englishName: 'Burmese / Myanmar', flagEmoji: '🇲🇲'),
  const SupportedLanguage(code: 'ar', nativeName: 'العربية', englishName: 'Arabic', flagEmoji: '🇸🇦'),
  const SupportedLanguage(code: 'bn', nativeName: 'বাংলা', englishName: 'Bengali', flagEmoji: '🇧🇩'),
  const SupportedLanguage(code: 'bo', nativeName: 'བོད་ཡིག', englishName: 'Tibetan', flagEmoji: '☸️'),
  const SupportedLanguage(code: 'de', nativeName: 'Deutsch', englishName: 'German', flagEmoji: '🇩🇪'),
  const SupportedLanguage(code: 'es', nativeName: 'Español', englishName: 'Spanish', flagEmoji: '🇪🇸'),
  const SupportedLanguage(code: 'fr', nativeName: 'Français', englishName: 'French', flagEmoji: '🇫🇷'),
  const SupportedLanguage(code: 'id', nativeName: 'Bahasa Indonesia', englishName: 'Indonesian', flagEmoji: '🇮🇩'),
  const SupportedLanguage(code: 'it', nativeName: 'Italiano', englishName: 'Italian', flagEmoji: '🇮🇹'),
  const SupportedLanguage(code: 'ja', nativeName: '日本語', englishName: 'Japanese', flagEmoji: '🇯🇵'),
  const SupportedLanguage(code: 'km', nativeName: 'ភាសាខ្មែរ', englishName: 'Khmer', flagEmoji: '🇰🇭'),
  const SupportedLanguage(code: 'ko', nativeName: '한국어', englishName: 'Korean', flagEmoji: '🇰🇷'),
  const SupportedLanguage(code: 'lo', nativeName: 'ລາວ', englishName: 'Lao', flagEmoji: '🇱🇦'),
  const SupportedLanguage(code: 'mn', nativeName: 'Монгол', englishName: 'Mongolian', flagEmoji: '🇲🇳'),
  const SupportedLanguage(code: 'mr', nativeName: 'मराठी', englishName: 'Marathi', flagEmoji: '🇮🇳'),
  const SupportedLanguage(code: 'pt', nativeName: 'Português', englishName: 'Portuguese', flagEmoji: '🇵🇹'),
  const SupportedLanguage(code: 'ru', nativeName: 'Русский', englishName: 'Russian', flagEmoji: '🇷🇺'),
  const SupportedLanguage(code: 'ta', nativeName: 'தமிழ்', englishName: 'Tamil', flagEmoji: '🇮🇳'),
  const SupportedLanguage(code: 'te', nativeName: 'తెలుగు', englishName: 'Telugu', flagEmoji: '🇮🇳'),
  const SupportedLanguage(code: 'th', nativeName: 'ไทย', englishName: 'Thai', flagEmoji: '🇹🇭'),
];

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier(this._prefs) : super(_loadInitialLocale(_prefs));

  final SharedPreferences _prefs;
  static const _storageKey = 'user_selected_locale';

  static Locale? _loadInitialLocale(SharedPreferences prefs) {
    final savedKey = prefs.getString(_storageKey);
    if (savedKey == null || savedKey.isEmpty) {
      return null; // System default
    }
    final parts = savedKey.split('_');
    if (parts.length > 1) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await _prefs.remove(_storageKey);
    } else {
      final key = locale.countryCode != null && locale.countryCode!.isNotEmpty
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode;
      await _prefs.setString(_storageKey, key);
    }
  }

  Future<void> resetToSystem() async {
    await setLocale(null);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

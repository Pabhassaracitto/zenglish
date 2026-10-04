import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import 'progress_store.dart';

/// Facade đọc/ghi session người dùng.
///
/// **ZEN-008:** lớp này không còn giữ kho dữ liệu riêng. Mọi thông tin hồ sơ và
/// tiến độ đều đi qua [ProgressStore] (key canonical `userprofile`) — cùng nơi
/// `UserProfileNotifier` ghi. Các key rời cũ (`completed_lesson_ids`, …) chỉ
/// còn được đọc **một lần** trong `ProgressStore.migrateIfNeeded()` để người đã
/// cài beta không mất tiến độ.
class UserSessionService {
  UserSessionService._();

  static final UserSessionService instance = UserSessionService._();

  /// Tuỳ chọn hiển thị, không phải tiến độ học → giữ key riêng.
  static const _keySilentMode = 'silent_mode';
  static const _keyShowIpa = 'show_ipa';

  SharedPreferences? _prefs;
  ProgressStore? _store;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _store = ProgressStore(_prefs!);
    await _store!.migrateIfNeeded();
  }

  SharedPreferences get _p {
    assert(_prefs != null, 'Call UserSessionService.init() first');
    return _prefs!;
  }

  ProgressStore get store {
    assert(_store != null, 'Call UserSessionService.init() first');
    return _store!;
  }

  // ─── Profile ─────────────────────────────────

  bool get hasUserProfile => store.hasProfile;

  UserProfile? loadUserProfile() => store.read();

  Future<void> saveUserProfile(UserProfile profile) => store.write(profile);

  // ─── Progress ────────────────────────────────

  Future<void> markLessonCompleted(String lessonId) =>
      store.markLessonCompleted(lessonId);

  Future<void> markLessonInProgress(String lessonId) =>
      store.markLessonInProgress(lessonId);

  // ─── Silent mode / IPA ───────────────────────

  bool get silentMode => _p.getBool(_keySilentMode) ?? false;

  Future<void> setSilentMode(bool value) => _p.setBool(_keySilentMode, value);

  bool get showIpa => loadUserProfile()?.showIpa ?? _p.getBool(_keyShowIpa) ?? true;

  Future<void> setShowIpa(bool value) async {
    await _p.setBool(_keyShowIpa, value);
    final profile = loadUserProfile();
    if (profile != null) {
      await store.write(profile.copyWith(showIpa: value));
    }
  }

  // ─── Clear (logout / reset) ──────────────────

  Future<void> clearSession() async {
    await store.clear();
    await _p.remove(_keySilentMode);
    await _p.remove(_keyShowIpa);
  }
}

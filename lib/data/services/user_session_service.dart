import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../../core/enums/cefr_level.dart';
import '../../core/enums/meditation_stage.dart';

/// Quản lý session người dùng
/// MVP: dùng SharedPreferences
/// Production: swap sang Firestore
class UserSessionService {
  static const _keyHasProfile   = 'has_user_profile';
  static const _keyUserId       = 'user_id';
  static const _keyDisplayName  = 'display_name';
  static const _keyLangLevel    = 'language_level';
  static const _keyMedStage     = 'meditation_stage';
  static const _keyPaliLevel    = 'pali_knowledge_level';
  static const _keyCompleted    = 'completed_lesson_ids';
  static const _keyInProgress   = 'in_progress_lesson_ids';
  static const _keyIsMonk       = 'is_monk';
  static const _keySilentMode   = 'silent_mode';

  // ─── Singleton ──────────────────────────────

  UserSessionService._();
  static final UserSessionService instance = UserSessionService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    assert(_prefs != null, 'Call UserSessionService.init() first');
    return _prefs!;
  }

  // ─── Profile check ──────────────────────────

  bool get hasUserProfile => _p.getBool(_keyHasProfile) ?? false;

  // ─── Save ────────────────────────────────────

  Future<void> saveUserProfile(UserProfile profile) async {
    await Future.wait([
      _p.setBool(_keyHasProfile, true),
      _p.setString(_keyUserId, profile.userId),
      _p.setString(_keyDisplayName, profile.displayName),
      _p.setString(_keyLangLevel, profile.languageLevel.displayName),
      _p.setString(_keyMedStage, profile.meditationStage.name),
      _p.setInt(_keyPaliLevel, profile.paliKnowledgeLevel),
      _p.setStringList(_keyCompleted, profile.completedLessonIds),
      _p.setStringList(_keyInProgress, profile.inProgressLessonIds),
      _p.setBool(_keyIsMonk, profile.isMonk),
    ]);
  }

  // ─── Load ────────────────────────────────────

  UserProfile? loadUserProfile() {
    if (!hasUserProfile) return null;

    return UserProfile(
      userId: _p.getString(_keyUserId) ?? 'local_user',
      displayName: _p.getString(_keyDisplayName) ?? 'Meditator',
      languageLevel: CEFRLevel.fromString(
        _p.getString(_keyLangLevel) ?? 'A1',
      ),
      meditationStage: MeditationStage.fromString(
        _p.getString(_keyMedStage) ?? 'preRetreat',
      ),
      paliKnowledgeLevel: _p.getInt(_keyPaliLevel) ?? 0,
      completedLessonIds:
          _p.getStringList(_keyCompleted) ?? [],
      inProgressLessonIds:
          _p.getStringList(_keyInProgress) ?? [],
      isMonk: _p.getBool(_keyIsMonk) ?? false,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
  }

  // ─── Progress update ─────────────────────────

  Future<void> markLessonCompleted(String lessonId) async {
    final completed = List<String>.from(
      _p.getStringList(_keyCompleted) ?? [],
    );
    final inProgress = List<String>.from(
      _p.getStringList(_keyInProgress) ?? [],
    );
    if (!completed.contains(lessonId)) completed.add(lessonId);
    inProgress.remove(lessonId);
    await _p.setStringList(_keyCompleted, completed);
    await _p.setStringList(_keyInProgress, inProgress);
  }

  Future<void> markLessonInProgress(String lessonId) async {
    final inProgress = List<String>.from(
      _p.getStringList(_keyInProgress) ?? [],
    );
    if (!inProgress.contains(lessonId)) inProgress.add(lessonId);
    await _p.setStringList(_keyInProgress, inProgress);
  }

  // ─── Silent mode ─────────────────────────────

  bool get silentMode => _p.getBool(_keySilentMode) ?? false;

  Future<void> setSilentMode(bool value) =>
      _p.setBool(_keySilentMode, value);

  // ─── Clear (logout / reset) ──────────────────

  Future<void> clearSession() async {
    await _p.clear();
  }
}

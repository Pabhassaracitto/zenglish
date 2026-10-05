// lib/data/services/progress_store.dart
//
// ZEN-008 — MỘT nguồn sự thật duy nhất cho hồ sơ + tiến độ học.
//
// Trước đây dữ liệu nằm ở hai nơi trong SharedPreferences:
//   1. key `userprofile`            — JSON đầy đủ, ghi bởi UserProfileNotifier
//   2. các key rời (`has_user_profile`, `completed_lesson_ids`, …)
//      — ghi/đọc bởi UserSessionService (Home, catalog đọc qua đây)
// Hai nơi này không đồng bộ: học xong một bài ghi vào (1) nhưng Home đọc (2).
//
// Từ nay **key canonical là `userprofile`**. `UserSessionService` và
// `UserProfileNotifier` đều là facade mỏng trên lớp này. `migrateIfNeeded()`
// đọc dữ liệu legacy của người đã cài beta và nhập vào key canonical, nên
// không ai mất tiến độ.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/enums/cefr_level.dart';
import '../../core/enums/meditation_stage.dart';
import '../models/user_profile.dart';

class ProgressStore {
  const ProgressStore(this._prefs);

  final SharedPreferences _prefs;

  /// Nguồn sự thật duy nhất.
  static const canonicalKey = 'userprofile';

  /// Giữ lại chuỗi JSON hỏng để debug thay vì xoá im lặng.
  static const corruptBackupKey = 'userprofile_corrupt_backup';

  /// Cờ đánh dấu đã nhập dữ liệu legacy (chạy đúng một lần cho mỗi máy).
  static const migrationFlagKey = 'progress_migrated_v1';

  // ─── Legacy keys (UserSessionService trước ZEN-008) ───────────────────────
  static const legacyHasProfile = 'has_user_profile';
  static const legacyUserId = 'user_id';
  static const legacyDisplayName = 'display_name';
  static const legacyLangLevel = 'language_level';
  static const legacyMedStage = 'meditation_stage';
  static const legacyPaliLevel = 'pali_knowledge_level';
  static const legacyCompleted = 'completed_lesson_ids';
  static const legacyInProgress = 'in_progress_lesson_ids';
  static const legacyIsMonk = 'is_monk';
  static const legacyShowIpa = 'show_ipa';

  static const _legacyKeys = <String>[
    legacyHasProfile,
    legacyUserId,
    legacyDisplayName,
    legacyLangLevel,
    legacyMedStage,
    legacyPaliLevel,
    legacyCompleted,
    legacyInProgress,
    legacyIsMonk,
  ];

  // ─── Đọc / ghi ────────────────────────────────────────────────────────────

  /// Đọc hồ sơ canonical. JSON hỏng → `null` (app quay về onboarding) thay vì
  /// ném lỗi làm trắng màn hình.
  UserProfile? read() {
    final raw = _prefs.getString(canonicalKey);
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  bool get hasProfile => read() != null;

  Future<void> write(UserProfile profile) async {
    await _prefs.setString(canonicalKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> markLessonCompleted(String lessonId) async {
    final current = read();
    if (current == null) return null;
    final completed = <String>{...current.completedLessonIds, lessonId};
    final inProgress = [...current.inProgressLessonIds]..remove(lessonId);
    final updated = current.copyWith(
      completedLessonIds: completed.toList(),
      inProgressLessonIds: inProgress,
      lastStudiedAt: DateTime.now(),
    );
    await write(updated);
    return updated;
  }

  Future<UserProfile?> markLessonInProgress(String lessonId) async {
    final current = read();
    if (current == null) return null;
    if (current.completedLessonIds.contains(lessonId)) return current;
    if (current.inProgressLessonIds.contains(lessonId)) return current;
    final updated = current.copyWith(
      inProgressLessonIds: [...current.inProgressLessonIds, lessonId],
      lastStudiedAt: DateTime.now(),
    );
    await write(updated);
    return updated;
  }

  /// Xoá hồ sơ + mọi dấu vết legacy (reset app). Không dùng `prefs.clear()` để
  /// không xoá luôn cài đặt ngôn ngữ/giao diện của người dùng.
  Future<void> clear() async {
    await _prefs.remove(canonicalKey);
    await _prefs.remove(corruptBackupKey);
    await _prefs.remove(migrationFlagKey);
    for (final key in _legacyKeys) {
      await _prefs.remove(key);
    }
  }

  // ─── Migration ────────────────────────────────────────────────────────────

  /// Nhập dữ liệu từ các key legacy vào key canonical.
  ///
  /// - Canonical hỏng/thiếu, legacy có → dựng lại hồ sơ từ legacy.
  /// - Cả hai cùng có → hợp nhất (union) danh sách bài đã học, không mất tiến độ
  ///   ở bất kỳ phía nào.
  /// - Chạy đúng một lần nhờ [migrationFlagKey]; an toàn khi gọi lại nhiều lần.
  ///
  /// Trả về `true` nếu có ghi dữ liệu mới.
  Future<bool> migrateIfNeeded() async {
    if (_prefs.getBool(migrationFlagKey) ?? false) return false;

    final rawCanonical = _prefs.getString(canonicalKey);
    final canonical = read();
    final hasCorruptCanonical = rawCanonical != null && canonical == null;
    if (hasCorruptCanonical) {
      await _prefs.setString(corruptBackupKey, rawCanonical);
    }

    final legacy = _readLegacy();
    var wrote = false;

    if (legacy != null && canonical == null) {
      await write(legacy);
      wrote = true;
    } else if (legacy != null && canonical != null) {
      final completed = <String>{
        ...canonical.completedLessonIds,
        ...legacy.completedLessonIds,
      };
      final inProgress = <String>{
        ...canonical.inProgressLessonIds,
        ...legacy.inProgressLessonIds,
      }..removeAll(completed);
      final merged = canonical.copyWith(
        completedLessonIds: completed.toList(),
        inProgressLessonIds: inProgress.toList(),
      );
      await write(merged);
      wrote = true;
    } else if (hasCorruptCanonical) {
      // Không có legacy để cứu: bỏ JSON hỏng (đã backup) để app không kẹt.
      await _prefs.remove(canonicalKey);
      wrote = true;
    }

    if (legacy != null) {
      for (final key in _legacyKeys) {
        await _prefs.remove(key);
      }
    }

    await _prefs.setBool(migrationFlagKey, true);
    return wrote;
  }

  UserProfile? _readLegacy() {
    if (!(_prefs.getBool(legacyHasProfile) ?? false)) return null;
    try {
      return UserProfile(
        userId: _prefs.getString(legacyUserId) ?? 'local_user',
        displayName: _prefs.getString(legacyDisplayName) ?? 'Meditator',
        languageLevel:
            CEFRLevel.fromString(_prefs.getString(legacyLangLevel) ?? 'A1'),
        meditationStage: MeditationStage.fromString(
          _prefs.getString(legacyMedStage) ?? 'preRetreat',
        ),
        paliKnowledgeLevel: _prefs.getInt(legacyPaliLevel) ?? 0,
        completedLessonIds: _prefs.getStringList(legacyCompleted) ?? const [],
        inProgressLessonIds: _prefs.getStringList(legacyInProgress) ?? const [],
        isMonk: _prefs.getBool(legacyIsMonk) ?? false,
        showIpa: _prefs.getBool(legacyShowIpa) ?? true,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }
}

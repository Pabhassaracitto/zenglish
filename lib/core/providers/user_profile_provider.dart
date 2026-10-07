// ============================================================
// PROVIDER: UserProfile state - dùng cho router redirect logic
// ============================================================
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_profile.dart';

// ── SharedPreferences Provider ──
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // Được override trong main.dart sau khi init
  throw UnimplementedError('SharedPreferences chưa được khởi tạo');
});

// ── UserProfile Notifier ──
class UserProfileNotifier extends AsyncNotifier<UserProfile?> {
  static const _storageKey = 'userprofile';

  @override
  Future<UserProfile?> build() async {
    return loadFromStorage();
  }

  Future<UserProfile?> loadFromStorage() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null) return null;
      return UserProfile.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (e) {
      // Nếu parse lỗi → coi như chưa có profile
      return null;
    }
  }

  /// Lưu profile sau khi hoàn thành Placement Test
  Future<void> saveProfile(UserProfile profile) async {
    state = const AsyncLoading();
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(
        _storageKey,
        jsonEncode(profile.toJson()),
      );
      state = AsyncData(profile);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Cập nhật một phần profile
  Future<void> updateProfile(UserProfile Function(UserProfile) updater) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await saveProfile(updater(current));
  }

  /// Toggle IPA visibility globally
  Future<void> toggleIpaVisibility() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(showIpa: !current.showIpa);
    await saveProfile(updated);
  }

  /// ✅ NEW: Mark a lesson as completed — persists to SharedPreferences
  Future<void> markLessonCompleted(String lessonId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    // Guard: skip if already marked to avoid redundant writes
    if (current.completedLessonIds.contains(lessonId)) return;

    final updatedIds = [...current.completedLessonIds, lessonId];
    final updated = current.copyWith(completedLessonIds: updatedIds);
    await saveProfile(updated);
  }

  /// ✅ NEW: Check if a lesson is completed
  bool isLessonCompleted(String lessonId) {
    final current = state.valueOrNull;
    if (current == null) return false;
    return current.completedLessonIds.contains(lessonId);
  }

  /// Xóa profile (reset app)
  Future<void> clearProfile() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_storageKey);
    state = const AsyncData(null);
  }
}

// ── Public Provider ──
final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile?>(
  UserProfileNotifier.new,
);

// ── Convenience: Chỉ lấy bool hasProfile (dùng trong router) ──
final hasUserProfileProvider = Provider<bool>((ref) {
  final profileState = ref.watch(userProfileProvider);
  return profileState.valueOrNull != null;
});

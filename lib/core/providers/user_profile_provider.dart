// ============================================================
// PROVIDER: UserProfile state - dùng cho router redirect logic
// ============================================================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_profile.dart';
import '../../data/services/progress_store.dart';

// ── SharedPreferences Provider ──
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // Được override trong main.dart sau khi init
  throw UnimplementedError('SharedPreferences chưa được khởi tạo');
});

// ── UserProfile Notifier ──
class UserProfileNotifier extends AsyncNotifier<UserProfile?> {
  /// ZEN-008: tiến độ chỉ có **một** nguồn — [ProgressStore] (key
  /// `userprofile`). `UserSessionService` là facade trên cùng kho này.
  ProgressStore get _store => ProgressStore(ref.read(sharedPreferencesProvider));

  @override
  Future<UserProfile?> build() async {
    return loadFromStorage();
  }

  Future<UserProfile?> loadFromStorage() async {
    try {
      final store = _store;
      // Nhập dữ liệu beta cũ (các key rời) nếu có; chạy đúng một lần.
      await store.migrateIfNeeded();
      return store.read();
    } catch (e) {
      // Nếu parse lỗi → coi như chưa có profile, không làm trắng màn hình
      return null;
    }
  }

  /// Lưu profile sau khi hoàn thành Placement Test
  Future<void> saveProfile(UserProfile profile) async {
    state = const AsyncLoading();
    try {
      await _store.write(profile);
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

  /// Đánh dấu hoàn thành — ghi vào kho canonical, không trùng ID.
  Future<void> markLessonCompleted(String lessonId) async {
    final current = state.valueOrNull ?? _store.read();
    if (current == null) return;
    if (current.completedLessonIds.contains(lessonId)) return;

    final updated = await _store.markLessonCompleted(lessonId);
    if (updated != null) state = AsyncData(updated);
  }

  /// Đánh dấu đang học (mở bài) để Home gợi ý tiếp đúng bài đang dở.
  Future<void> markLessonInProgress(String lessonId) async {
    final current = state.valueOrNull ?? _store.read();
    if (current == null) return;

    final updated = await _store.markLessonInProgress(lessonId);
    if (updated != null) state = AsyncData(updated);
  }

  /// ✅ NEW: Check if a lesson is completed
  bool isLessonCompleted(String lessonId) {
    final current = state.valueOrNull;
    if (current == null) return false;
    return current.completedLessonIds.contains(lessonId);
  }

  /// Xóa profile (reset app)
  Future<void> clearProfile() async {
    await _store.clear();
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

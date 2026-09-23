import 'package:shared_preferences/shared_preferences.dart';

/// Cờ thiết bị (device-scoped flags) — silent mode, ...
///
/// KHÔNG phải nguồn tiến độ học tập.
///
/// Hồ sơ + tiến độ (bài đã hoàn thành / đang học / show IPA) chỉ được lưu ở
/// một nơi duy nhất: `userProfileProvider` với key JSON `userprofile`.
///
/// Trước đây service này còn lưu song song một bản hồ sơ thứ hai
/// (`has_user_profile`, `completed_lesson_ids`, `in_progress_lesson_ids`, ...).
/// Bản đó chỉ được ghi bởi `saveUserProfile()` — mà không luồng nào trong app
/// gọi — còn `homeProvider` thì lại đọc từ nó. Kết quả là Home luôn nhận
/// `profile == null`: không lời chào, không gợi ý bài kế tiếp, dù placement
/// đã lưu profile thành công. Các API trùng lặp đã bị xoá để luồng học chỉ
/// còn một nguồn sự thật (Kanban ZEN-008).
class UserSessionService {
  static const _keySilentMode = 'silent_mode';

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

  // ─── Silent mode ────────────────────────────

  bool get silentMode => _p.getBool(_keySilentMode) ?? false;

  Future<void> setSilentMode(bool value) => _p.setBool(_keySilentMode, value);

  // ─── Full reset (logout / reset app) ────────

  /// Xoá toàn bộ SharedPreferences của app, gồm cả profile và các cờ thiết bị.
  ///
  /// Vì `userProfileProvider` đang giữ profile trong bộ nhớ, caller buộc phải
  /// `ref.invalidate(userProfileProvider)` (hoặc `clearProfile()`) ngay sau đó;
  /// nếu không, router vẫn thấy profile cũ và không đưa người dùng về
  /// placement cho tới khi app khởi động lại. Xem `home_header.dart`.
  Future<void> clearSession() async {
    await _p.clear();
  }
}

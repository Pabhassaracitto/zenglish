# ZenGlish — bàn giao cho phiên/agent tiếp theo

Cập nhật: **13/09/2026**. Đọc cùng [Kanban](KANBAN.md), [plan](IMPLEMENTATION_PLAN.md) và [content audit](CONTENT_AUDIT.md).

## 1. Mục tiêu người dùng đã duyệt

Offline-first, Android beta trước, Việt–Anh ưu tiên. Người dùng đã yêu cầu tạo tag/release để tải APK và test. Yêu cầu mới: giữ Kanban/plan/handoff trong repository, đồng bộ main trước PR, tiếp tục được ngay cả khi nhánh cũ bị xóa.

Không cần hỏi lại hướng offline hay có cần beta không. Chỉ hỏi khi cần quyết định mới (quyền GitHub, giọng thu âm, signing/store hoặc duyệt chuyên môn).

## 2. Trạng thái thực tế tại lần bàn giao này

- `git fetch origin main` thành công; `git merge --no-edit origin/main` trả về `Already up to date.`. Base main quan sát được: `fb8125d`.
- Không thấy PR mở khi kiểm tra GitHub. Release hiển thị là `v1.0` cũ (29/06/2026), không phải beta mới.
- Quyết định mới nhất của người dùng: **push code/tests/docs trước, không push thay đổi workflow; chủ repository tự cập nhật workflow**. Không tiếp tục coi quyền workflow là blocker của việc push phần ứng dụng.
- Bộ thay đổi `.github/workflows/` chỉ giữ ở workspace và được bàn giao riêng, không nằm trong commit ứng dụng này. Bản trên GitHub vẫn là workflow cũ cho tới khi chủ repository cập nhật. Xem WORKFLOW_MANUAL.md.
- `pubspec.yaml` đã đặt `1.0.1-beta.1+2`; đây mới là version dự kiến. **Chưa xác nhận có tag `v1.0.1-beta.1`, APK beta, hoặc beta release.**
- Tài liệu này mô tả bộ thay đổi để merge, không khẳng định main đã chứa nó. Sau khi merge, agent tiếp theo cập nhật mục trạng thái này bằng commit/run/PR URL thực.

## 3. Những gì đã làm trong mã

- Đã soạn riêng (chưa push) CI quality gate + pin Flutter 3.44.0, legacy manual và loại beta tag khỏi premium. Không coi cấu hình dự kiến này là CI đang chạy trên GitHub.
- Localization facade tách khỏi output generated; ARB là nguồn bản dịch.
- Mặc định phân tích phản hồi offline; service trực tiếp OpenAI bị chặn bởi Env; không nhúng key.
- Font tiêu đề bundled, nội dung dùng font hệ thống thay tải từ mạng.
- Catalog 8 bài: nhập A1 CH01–04 từ TASK drafts, giữ prerequisites, sửa routing ID CH01.
- Hỗ trợ bài đọc email CH04, giữ review metadata và cờ `needs_audio`, báo thiếu audio và xử lý kết quả lỗi playback.
- Bổ sung validator Python, negative tests và Dart tests cho assets, hồ sơ, localization, first launch và feedback.

## 4. Bằng chứng kiểm tra và giới hạn

Đã chạy lại: content validator đạt 8 bài; **7/7 Python tests đạt**; `git diff --check` đạt (xem lệnh trong AGENTS.md).

Chưa chạy thành công: `flutter pub get`, `gen-l10n`, analyzer, Flutter tests, build APK hoặc test thiết bị. Lần tải SDK trước lỗi SSL; chưa có CI run chứng minh các thay đổi đạt. `pubspec.lock` chưa được resolve lại sau đổi pubspec. `analyze_output.txt` là log cũ, không dùng làm kết quả hiện tại.

Bốn bài mới là draft chờ duyệt. Tất cả tám bài thiếu audio Input. Không gọi beta này là hoàn thiện, production-ready hay đã duyệt giáo trình.

## 5. Điểm tiếp tục ưu tiên

1. **ZEN-001:** chủ repository cập nhật ba workflow theo WORKFLOW_MANUAL.md. Agent chỉ push code/tests/docs theo yêu cầu; không đưa các workflow pending vào commit sau ngoài ý muốn.
2. **ZEN-002/003:** có SDK hoặc CI thì resolve, sinh bản dịch, analyzer/tests/build. Lưu lockfile từ kết quả resolve thực. Nếu fail, sửa và chạy lại; không skip tests để lấy APK.
3. **ZEN-004/013:** đồng bộ main, mở PR kèm toàn bộ code/tài liệu/tests; xác minh sau merge. Đường dẫn tài liệu phải tương đối, không trỏ nhánh tạm.
4. **ZEN-005:** build thành công → beta release chứa APK và checksum. Xem DELIVERY.md vì workflow hiện **không tự tạo beta release**.
5. **ZEN-008/011:** xác minh chu trình học, tiến độ và gợi ý bài tiếp theo; người dùng sẽ tải APK test.

## 6. Vùng mã cần chú ý khi debug

| Khu vực | File / rủi ro cần xác minh |
|---|---|
| Hồ sơ/tiến độ | `lib/core/providers/user_profile_provider.dart` lưu `userprofile`; `lib/data/services/user_session_service.dart` lưu các key riêng; `home_provider.dart` đọc session. Test riêng một provider không chứng minh đồng bộ cả luồng |
| Gợi ý bài | `home_provider.dart` có logic đơn giản trả null nếu bài gợi ý đã hoàn thành. Catalog đủ prerequisites không đồng nghĩa UI/fast-track đã đúng |
| Localization | `lib/l10n/app_localizations.dart` facade; `generated/` chưa sinh trong checkout sạch cho tới khi chạy Flutter. Locale ngoài Việt–Anh chưa nghiệm thu |
| Input/audio | `lesson_screen.dart` và `stages/input_stage.dart` là hai đường giao diện cần đối chiếu; `audio_provider.dart` và `AudioPlaybackService` cần kiểm thử runtime |
| Phản hồi | Engine cục bộ thiên về trình pháp; chưa chứng minh phù hợp với bài giới thiệu/đăng ký. Không đánh giá chứng đắc |
| Phát hành | APK quality là debug ARM64, không có signing ổn định qua các runner; gói này không dùng Play Store |

## 7. Điều kiện bàn giao bền vững

Agent mới phải clone/fetch main, đọc `AGENTS.md`, chạy validator và tìm được thẻ tiếp theo mà không cần checkout nhánh cũ hoặc đọc chat. Chỉ xóa nhánh sau khi code + tài liệu được merge. APK cần tồn tại trong Release assets vì artifact CI hết hạn sau 14 ngày. Không xóa tag beta đã xuất bản khi dọn nhánh.

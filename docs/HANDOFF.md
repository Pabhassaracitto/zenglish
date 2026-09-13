# ZenGlish — bàn giao cho phiên/agent tiếp theo

Cập nhật: **13/09/2026**. Đọc cùng [Kanban](KANBAN.md), [plan](IMPLEMENTATION_PLAN.md) và [content audit](CONTENT_AUDIT.md).

## 1. Mục tiêu người dùng đã duyệt

Offline-first, Android beta trước, Việt–Anh ưu tiên. Người dùng đã yêu cầu tạo tag/release để tải APK và test. Yêu cầu mới: giữ Kanban/plan/handoff trong repository, đồng bộ main trước PR, tiếp tục được ngay cả khi nhánh cũ bị xóa.

Không cần hỏi lại hướng offline hay có cần beta không. Chỉ hỏi khi cần quyết định mới (quyền GitHub, giọng thu âm, signing/store hoặc duyệt chuyên môn).

## 2. Trạng thái đã đối chiếu — chuẩn bị PR

### PR đã mở

[PR #2 — Prepare offline Android beta and durable agent handoff](https://github.com/Pabhassaracitto/zenglish/pull/2) đã mở vào main, trạng thái **Draft**. Chưa merge; chờ Flutter checks/build. Tiếp tục ZEN-002/003/016, sau đó review và xác minh ZEN-004/013 trên main.

### Cập nhật mới nhất khi người dùng yêu cầu create PR

Đã nhập main `ce01f0a` vào nhánh ứng dụng. Hai conflict được giải quyết: giữ font offline trong `app_theme.dart` (không thêm self-import) và giữ localization facade generated thay lớp dịch viết tay. Ba tham chiếu màu đã giữ đúng `AppColors` như bản sửa trên main. Validator 8 bài và 7/7 Python tests đạt sau merge; Flutter SDK chưa sẵn sàng nên chưa chạy analyzer/tests/build. Không có thay đổi workflow trong PR; bộ workflow thủ công vẫn giữ riêng ở workspace. Đang mở PR dạng draft để review, không tự merge khi kiểm tra Flutter chưa đạt.

Các ghi chú “chưa nhập main” bên dưới là lịch sử trước bước này, không phải việc còn cần làm cho cùng SHA. Luôn fetch và đối chiếu lại nếu main tiếp tục thay đổi.

### Lịch sử đối chiếu trước khi đồng bộ

Mốc kiểm tra **13/09/2026** (không phải khẳng định main luôn ở các SHA này):

- Đã fetch remote. Main quan sát được là `ce01f0a` (`add premium build`), có `3a7cc22` sửa tham chiếu màu sang `AppColors`.
- Nhánh ứng dụng đã push tới `dee0455` trước lần cập nhật tài liệu này. GitHub compare báo hai nhánh phân kỳ: ứng dụng có 4 commit riêng, main có 2 commit riêng. Nội dung main chưa có bốn bài A1 mới và bộ tài liệu bàn giao.
- **Không dùng kết quả “Already up to date / main fb8125d” ở phiên trước làm tình trạng hiện tại.** Chưa nhập main `ce01f0a` vào nhánh ứng dụng trong lượt cập nhật tài liệu này. Phải đồng bộ và giữ sửa lỗi theme trước PR (ZEN-015).
- Không thấy PR cho nhánh ứng dụng khi kiểm tra. Người dùng sẽ yêu cầu **create PR** sau khi cập nhật tài liệu; chưa được coi là đã mở/merge PR.
- `v1.0` là release cũ quan sát được. `pubspec.yaml` đặt `1.0.1-beta.1+2`, nhưng chưa có bằng chứng APK/tag/beta release mới.
- Chủ repository nhận cập nhật workflow thủ công. Code/tests/docs đã push riêng; thay đổi `.github/workflows/` mới chưa được push. Đặc tả ở WORKFLOW_MANUAL.md, không phụ thuộc ZIP hay workspace của agent trước.

### Nếu bạn đang đọc tài liệu này trên main sau merge

Không checkout nhánh cũ và không dừng lại chỉ vì ghi chú lịch sử trên nói “chưa merge”. Kiểm tra nội dung main hiện tại, điền SHA/PR/run thực vào bảng dưới rồi chuyển sang ZEN-001/002/003 và ZEN-008. Nếu còn thiếu nội dung hoặc lỗi compile, giữ thẻ ở Verify/Blocked, không tự đánh dấu Done.

| Bằng chứng cần cập nhật sau merge | Trạng thái tại lần bàn giao này |
|---|---|
| PR URL + merge commit trên main | Chưa có; chờ yêu cầu create PR |
| Main có AGENTS, Kanban, handoff, plan và 8 bài | Chưa có ở main được kiểm tra; bộ này đang ở nhánh ứng dụng |
| Ba tham chiếu màu dùng `AppColors` sau hợp nhất | Đã thấy đúng trên main `3a7cc22`; phải bảo toàn trong kết quả merge |
| Commit workflow do chủ repository cập nhật | Chưa xác nhận |
| CI / Flutter tests / APK đúng SHA main | Chưa xác nhận |
| Beta release URL + APK checksum | Chưa có |

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

## 5. Điểm tiếp tục theo thứ tự

### Trước PR (khi người dùng yêu cầu create PR)

1. **ZEN-015:** fetch main mới nhất, bảo toàn pending workflow ngoài commit, merge main vào nhánh phiên. Giữ `AppColors.earthDark`/`AppColors.saffronLight` trong `home_header.dart` và `language_selector_sheet.dart`. Không dùng chọn toàn bộ ours/theirs làm mất sửa lỗi hay nội dung beta.
2. **ZEN-016:** người dùng báo `_lastVoiceText` undefined nhưng tên này chưa được tìm thấy trong mã đã kiểm tra. Xin đường dẫn/dòng hoặc tái hiện bằng analyzer trên kết quả hợp nhất; không khai báo biến rỗng chỉ để im lỗi. Ba lỗi màu đã có bản sửa trên main, cần xác minh lại sau merge.
3. **ZEN-004/013:** chạy kiểm tra có thể chạy, ghi lệnh chưa chạy; tạo PR khi được yêu cầu, không đưa workflow thủ công vào commit. PR mô tả rõ chưa đạt build nếu còn chặn. Không merge chỉ vì Python tests đạt.

### Sau khi code và tài liệu đã có trên main

1. **ZEN-001/003:** chủ repository cập nhật workflow theo WORKFLOW_MANUAL.md; agent kiểm tra trigger, pin SDK và run thực. Nếu chưa có CI, vẫn có thể làm ZEN-002 local khi có SDK.
2. **ZEN-002/016:** resolve dependencies/lockfile, gen-l10n, analyzer, Flutter tests và APK. Ưu tiên lỗi compile; không skip test để lấy artifact.
3. **ZEN-008/007:** test placement → home → bài đọc CH04 → hoàn thành → restart → đề xuất bài tiếp theo; chú ý hai nguồn lưu profile.
4. **ZEN-005:** khi build/checks đạt, tạo pre-release kèm APK/checksum đúng SHA và giới hạn thử nghiệm. Người dùng đã yêu cầu tải test; không cần hỏi lại hướng phát hành beta. Chưa tự phát hành stable/store.
5. **ZEN-011/009/010:** thu lỗi thiết bị từ người dùng; tiếp tục duyệt nội dung và audio. Bản tải thử không đồng nghĩa hoàn tất giáo trình.

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

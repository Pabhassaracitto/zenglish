# ZenGlish — hướng dẫn cho agent

## Bắt đầu phiên làm việc

1. Đọc `README.md`, `docs/HANDOFF.md`, `docs/KANBAN.md`, rồi `docs/IMPLEMENTATION_PLAN.md` và `docs/CONTENT_AUDIT.md` nếu sửa nội dung.
2. Chạy `git status --short`, kiểm tra nhánh hiện tại và `git log -5 --oneline`. Không giả định commit/nhánh từ phiên cũ vẫn tồn tại.
3. Fetch `origin main` và nhập thay đổi từ `origin/main` vào nhánh làm việc được môi trường cho phép. Bảo toàn thay đổi chưa commit; không checkout main hay tạo nhánh mới nếu môi trường cố định nhánh.
4. Đối chiếu trạng thái thực tế với tài liệu: workflow đã viết không có nghĩa CI đã chạy; version trong pubspec không có nghĩa release đã xuất bản.

## Nguồn sự thật và phạm vi

- Repository (sau khi PR merge: `main`) là nơi lưu kế hoạch và bàn giao, không phải chat, nhánh tạm hay bộ nhớ riêng của agent.
- `docs/KANBAN.md`: trạng thái công việc và tiêu chí hoàn thành. `docs/IMPLEMENTATION_PLAN.md`: phạm vi, thứ tự các giai đoạn. `docs/HANDOFF.md`: điểm tiếp tục và rủi ro kỹ thuật. Không tạo bảng trạng thái cạnh tranh trong thư mục riêng của agent.
- Hướng đã duyệt: offline-first, Android beta, ưu tiên Việt–Anh; remote AI/cloud không chặn MVP.
- Không nhúng service API key, không bật AI từ xa, không bỏ prerequisite hoặc tuyên bố nội dung đã được chuyên gia duyệt khi chưa có bằng chứng.
- Không yêu cầu credentials trong chat. Nếu GitHub thiếu quyền cập nhật workflows, báo người dùng sửa kết nối/quyền; không tìm cách lách quyền.

## Workflow trong repository

Chủ dự án đã yêu cầu nộp bản cập nhật workflow (18/09, chốt phương án 04/10/2026); `.github/workflows/` vì vậy được phép sửa **khi được yêu cầu rõ ràng**, kèm PR riêng như `docs/WORKFLOW_MANUAL.md` mô tả. Quyền `workflows` của GitHub App vẫn thiếu nên hiện agent chỉ tạo được patch/ZIP bàn giao: nếu push fail vì lý do này, giữ nguyên commit local, báo chủ repository áp patch hoặc cấp quyền — không lách qua API khác và không bỏ quality gate. Pin SDK đặt ở `env.FLUTTER_VERSION_DEFAULT` trong `quality.yml`; workflow đóng gói nhận qua output của quality gate, không hardcode `flutter-version:`/`java-version:` (có job guard chặn việc này). Không stage thay đổi workflow ngoài ý muốn và không coi YAML đã push là CI đã chạy: chỉ lấy kết quả run thật trên Actions. Việc tách phạm vi không có nghĩa được bỏ kiểm tra trước release.

## Quy ước kỹ thuật

- Flutter được chốt trong README và các workflow; xác minh SDK thực tế trước khi thay đổi pin. Commit `pubspec.lock` sau khi resolve thành công, không chỉnh lockfile bằng phỏng đoán.
- Bản dịch: sửa ARB trong `lib/l10n/`; giữ facade `app_localizations.dart`; output `generated/` không commit.
- Thêm bài: cập nhật assets và registry; giữ nguồn gốc, gắn `needs_review` cho bản nháp. Chạy content validator và test trước khi đề nghị nghiệm thu.
- Không commit build artifacts, SDK, APK, cache Python hoặc credentials. APK đã kiểm tra phải được đính kèm GitHub Release để không mất khi artifact CI hết hạn.

## Kiểm tra tối thiểu

```sh
python3 scripts/validate_content.py
python3 -m unittest discover -s scripts -p 'test_*.py' -v
git diff --check
flutter pub get
flutter gen-l10n
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test --coverage
flutter build apk --debug --target-platform android-arm64
```

Nếu SDK/mạng/quyền ngăn thực hiện: ghi rõ lệnh nào chưa chạy, không đánh dấu Done. Python validator không thay thế Dart analyzer, Flutter tests hoặc thử thiết bị.

## Kết thúc phiên / trước PR

- Cập nhật các thẻ Kanban liên quan và HANDOFF: thay đổi, bằng chứng kiểm tra, blocker, bước tiếp theo. Không ghi toàn bộ transcript hay đường dẫn sandbox làm điều kiện tiếp tục.
- Đồng bộ main lại trước khi mở/cập nhật PR; giải quyết conflict và chạy lại kiểm tra trên kết quả hợp nhất.
- Dùng PR template, mô tả rủi ro/chưa nghiệm thu. Không tuyên bố merge/release thành công chỉ vì đã commit local.
- Sau merge, kiểm tra CI trên main và release assets trước khi xóa nhánh. Không đóng PR chưa merge rồi xóa nhánh chứa công việc duy nhất.
- Chi tiết quy trình: `docs/DELIVERY.md`.

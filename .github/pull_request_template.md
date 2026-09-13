## Mục tiêu và Kanban

- Thẻ ZEN-…:
- Thay đổi chính:
- Ngoài phạm vi / rủi ro:

## Đồng bộ main

- [ ] Đã fetch origin main và nhập vào nhánh hiện tại trước khi đề nghị review.
- Main SHA đã đối chiếu:
- Conflict (nếu có) và cách giải quyết:

## Bằng chứng kiểm tra

Ghi kết quả thực, không đánh dấu các lệnh chỉ mới được thêm vào workflow.

- [ ] Content validator + Python tests
- [ ] `git diff --check`
- [ ] `flutter pub get` + lockfile được rà soát
- [ ] `flutter gen-l10n` + analyzer
- [ ] Flutter tests
- [ ] Android APK build
- [ ] Kiểm thử thiết bị (hoặc ghi rõ chờ người dùng beta)
- Run URL / SHA / lệnh đã chạy:
- Chưa chạy hoặc bị chặn, lý do:

## Bàn giao và phát hành

- [ ] AGENTS/README, Kanban, plan, handoff đã cập nhật nếu liên quan.
- [ ] Không cần chat, đường dẫn sandbox, artifact tạm hay nhánh cũ để tiếp tục.
- [ ] Không có APK/SDK/cache/credentials trong diff.
- [ ] Bản nháp nội dung vẫn có nhãn chờ duyệt; giới hạn audio/AI được mô tả đúng.
- Release/tag/assets (nếu thực sự đã tạo; nếu chưa ghi chưa tạo):
- Bước tiếp theo sau merge:

**Không đóng PR chưa merge rồi xóa nhánh nếu công việc chưa có trên main.**

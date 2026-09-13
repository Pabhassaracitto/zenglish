# ZenGlish — Kanban

Cập nhật: **13/09/2026**. Bảng công việc chính nằm trong repository; cập nhật cùng PR thay đổi mã nguồn.

**Quy ước:** Ready = có thể bắt đầu; Blocked = phụ thuộc bên ngoài; Verify = đã có mã nhưng chưa đạt kiểm tra cần thiết; Done = đạt tiêu chí của riêng thẻ, không đồng nghĩa sản phẩm đã phát hành.

| ID | Trạng thái | Ưu tiên / vai trò tiếp nhận | Công việc và điều kiện hoàn thành | Bằng chứng / phụ thuộc |
|---|---|---|---|---|
| ZEN-001 | Ready | P0 · chủ repository | Cập nhật ba workflow thủ công theo WORKFLOW_MANUAL.md | Người dùng nhận phần workflow; không còn chặn push riêng code/tests/docs |
| ZEN-002 | Blocked | P0 · agent Flutter | Resolve trên Flutter 3.44.0, cập nhật lockfile; gen-l10n, analyzer, Flutter tests và APK đạt | SDK download trước lỗi SSL; CI mới chưa được xác nhận. Có thể chạy local khi SDK sẵn sàng, hoặc CI sau ZEN-001 |
| ZEN-003 | Verify | P0 · agent CI | Quality gate chạy trên PR/main, không đóng gói khi gate thất bại | Ba workflow mới chỉ có ở workspace, không push; chờ chủ repository cập nhật và run thành công |
| ZEN-004 | Ready | P0 · agent + chủ repository | Merge PR sau review/checks; xác nhận tài liệu, tests và nội dung đều có trên main | Xem DELIVERY.md; phụ thuộc ZEN-001/002/003 để hoàn tất |
| ZEN-005 | Blocked | P0 · agent release | Xuất bản `v1.0.1-beta.1` dạng pre-release có APK + SHA-256 + hướng dẫn cài | Người dùng đã yêu cầu bản tải thử. Chưa có tag/release/APK beta; cần build đạt. Không dùng pipeline stable cho beta |
| ZEN-006 | Done | P1 · agent nội dung | Đủ 8 bài trong registry, prerequisite không thiếu/vòng lặp, ID routing có trong assets | `validate_content.py` đạt; 7/7 Python tests đạt. Chỉ xác minh tĩnh, chưa nghiệm thu mở khóa trên UI |
| ZEN-007 | Verify | P1 · agent Flutter | Bài đọc email CH04, cờ review/audio và thông báo thiếu audio hiển thị đúng | Model/UI/tests đã bổ sung; chưa chạy Flutter tests/thiết bị |
| ZEN-008 | Ready | P1 · agent Flutter | Một nguồn tiến độ nhất quán: placement → home → hoàn thành → restart → gợi ý bài kế tiếp | Rà soát cả `user_profile_provider.dart` và `user_session_service.dart`; Home có đường đọc session riêng |
| ZEN-009 | Ready | P1 · người duyệt nội dung | Duyệt 4 bản nháp A1, tiếng Anh/Pāli, tập quán thiền viện, phản hồi cho bài không phải trình pháp | Danh sách chi tiết trong CONTENT_AUDIT.md; không tự gỡ `needs_review` |
| ZEN-010 | Ready | P1 · người duyệt + audio | Duyệt script/giọng/quyền sử dụng, đóng gói audio và nghe thử; hoặc nghiệm thu luồng đọc không chặn học | Cả 8 bài chưa có bản thu Input; chưa có deadline sản xuất được duyệt |
| ZEN-011 | Ready | P1 · agent + người dùng | Nghiệm thu APK: máy bay, Việt–Anh, lưu tiến độ, CH04, màn hình nhỏ, cỡ chữ lớn; triage lỗi | Phụ thuộc APK của ZEN-005; người dùng dự định tải về thử |
| ZEN-012 | Ready | P2 · agent Flutter | Ẩn/thay AI placeholder; kiểm định locale ngoài Việt–Anh và hỗ trợ accessibility | Không mở rộng phạm vi ngôn ngữ trước khi luồng chính ổn định |
| ZEN-013 | Verify | P1 · agent kế tiếp | Bàn giao không phụ thuộc nhánh: AGENTS, Kanban, plan, handoff và quy trình merge/release đều có trên main | Đợt bàn giao tách workflow khỏi code/tests/docs. Chỉ hoàn tất sau khi merge và kiểm tra main |
| ZEN-014 | Backlog | P2 · chủ dự án + backend | Backend AI có xác thực/hạn mức/consent; cloud sync, store signing và vận hành | Ngoài beta offline; chưa triển khai |

## Cách tiếp nhận một thẻ

1. Chọn một thẻ ưu tiên cao nhất không bị chặn; ghi ID trong PR.
2. Ghi bằng chứng (lệnh + kết quả, commit/run/release URL thực nếu có).
3. Chỉ chuyển Done khi đạt điều kiện hoàn thành của thẻ. Nếu mới viết mã, chuyển Verify.
4. Cập nhật HANDOFF khi điểm tiếp tục/blocker thay đổi; giữ ID ổn định để agent khác theo dõi được qua lịch sử Git.

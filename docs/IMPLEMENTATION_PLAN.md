# Kế hoạch triển khai ZenGlish

Cập nhật: **13/09/2026**. Hướng được duyệt: offline trước, AI sau.

Trạng thái từng việc ở [Kanban](KANBAN.md); điểm tiếp tục ở [Handoff](HANDOFF.md); quy trình đồng bộ main/PR/release ở [Delivery](DELIVERY.md). Plan này giữ thứ tự giai đoạn, không thay thế bằng chứng CI.

### Quyết định tách workflow

Người dùng yêu cầu ưu tiên push code/tests/docs; ba workflow do chủ repository tự cập nhật. Các checkbox về CI bên dưới chỉ xác nhận bản cấu hình đã được soạn ở workspace, **không được đưa vào commit ứng dụng**. Xem WORKFLOW_MANUAL.md. Không bật build/tag tự động khi workflow mới chưa được cập nhật và kiểm tra.

### Cập nhật khi mở PR

G0 đã hoàn tất với main `ce01f0a`: hợp nhất theme/localization và giữ sửa AppColors, Python checks đạt. Người dùng đã yêu cầu create PR; PR được chuẩn bị dạng draft vì Flutter checks/build chưa được chạy. Workflow không nằm trong PR. Các gate G2–G4 và xác minh trên main sau merge vẫn chưa hoàn tất.

### Cửa kiểm tra trước PR và sau merge

1. **G0 — Đồng bộ (ZEN-015):** fetch main mới, hợp nhất code ứng dụng với sửa theme trên main. Lần đối chiếu 13/09/2026 thấy main `ce01f0a` và hai nhánh phân kỳ; kết quả “Already up to date” cũ không còn áp dụng. Không khôi phục AppTheme.earthDark/saffronLight đã được sửa sang AppColors.
2. **G1 — PR/bàn giao (ZEN-004/013):** cập nhật bộ tài liệu này trước. Người dùng sẽ yêu cầu create PR ở lượt tiếp theo; chưa mở/merge PR trong lượt cập nhật tài liệu. Sau merge, agent xác minh tài liệu và 8 bài trên main, ghi SHA/PR thực, rồi chọn thẻ kế tiếp theo Kanban.
3. **G2 — Kỹ thuật (ZEN-001/002/003/016):** chủ repository cập nhật workflow; agent resolve lockfile, chạy analyzer/tests/build. Báo lỗi `_lastVoiceText` cần tái hiện bằng file/dòng hoặc analyzer; không đoán cách sửa. Python checks không thay Flutter checks.
4. **G3 — Beta (ZEN-007/008/005):** xác minh luồng học và lưu tiến độ, tạo APK đúng SHA + checksum + pre-release khi checks đạt. Người dùng đã yêu cầu bản tải thử, không cần xin lại quyết định offline-first. Không tạo release rỗng.
5. **G4 — Nghiệm thu (ZEN-011/009/010):** nhận phản hồi thiết bị, duyệt nội dung và audio. Chỉ nâng thành stable/store sau các điều kiện riêng bên dưới.

Sau merge, không yêu cầu agent mới đọc chat hay tìm nhánh cũ. AGENTS → HANDOFF → KANBAN là đường tiếp nhận; cập nhật bằng chứng mới thay cho mốc lịch sử trước PR.

## Phạm vi beta

- Android là nền tảng nghiệm thu đầu tiên; Việt–Anh là cặp ngôn ngữ ưu tiên.
- Tám bài JSON beta; bốn bài A1 mới nhập từ TASK còn chờ duyệt chuyên môn.
- Lưu tiến độ trên thiết bị; phản hồi luyện tập cục bộ, không tuyên bố AI online hay đánh giá chứng đắc.
- Chưa làm cloud sync, thanh toán, desktop hoặc phát hành công khai trong sprint ổn định.

## Sprint 1 — Ổn định (đang thực hiện)

Đã sửa/thiết lập trong mã nguồn, **chưa xác nhận Flutter chạy đạt**:
- [x] Chốt Flutter 3.44.0 cho hướng dẫn và các workflow.
- [x] Tách facade bản địa hóa khỏi file generated; dùng ARB làm nguồn duy nhất.
- [x] Khai báo trực tiếp http/intl; bỏ dart:io khỏi service HTTP để giảm rào cản Web.
- [x] Thay widget counter mẫu bằng kiểm tra Việt–Anh và first-launch onboarding.
- [x] Sửa schema fixture repository; thêm kiểm tra assets thực và lưu tiến độ qua restart.
- [x] Cho phép inject service trong test AI, đăng ký fallback model cho Mocktail.
- [x] Vô hiệu hóa API key trong client; mặc định phân tích offline và gắn nhãn rõ.
- [x] Bỏ tải font từ mạng ở giao diện; dùng Merriweather bundled và font hệ thống.
- [x] CI pull request/push: analyzer, tests, APK Android debug; quality gate trước đóng gói.
- [x] Loại trigger tag trùng ở workflow legacy.
- [ ] Resolve dependencies và cập nhật lockfile bằng Flutter thực tế.
- [ ] Analyzer không còn error; test suite chạy đạt.
- [ ] Build APK debug thành công và cài/chạy trên ít nhất một thiết bị Android.
- [ ] Kiểm tra Vietnamese/English first launch, đổi ngôn ngữ và mở lại ứng dụng.

### Giới hạn xác minh trong môi trường hiện tại

Clone được Flutter SDK 3.44.0 nhưng tải Dart SDK thất bại (`SSL_ERROR_SYSCALL`)
ở cả kho storage chính và mirror. Vì vậy chưa chạy được pub get, gen-l10n,
analyze, test hoặc build. Không dùng file `analyze_output.txt` cũ làm kết quả mới.
CI đã được viết nhưng chưa được kích hoạt/xác nhận trong lần triển khai này.
Không coi các ô đã sửa mã nguồn là tính năng đã được nghiệm thu.

Kiểm tra tĩnh đã thực hiện: `git diff --check` đạt; YAML của 3 workflow, pubspec và l10n parse thành công; 26 ARB là JSON hợp lệ,
đồng nhất key và đủ các key giao diện đang tham chiếu. Sau bổ sung nội dung, validator kiểm tra 8 bài, prerequisite/routing và tham chiếu audio; 7/7 Python tests đạt; không thiếu import nội bộ (trừ output generated
được sinh khi chạy Flutter). Các kiểm tra này không thay thế Dart analyzer/tests.

## Sprint 2 — Hoàn thiện chu trình học (dự kiến 2–3 tuần)

Chủ trì đề xuất: lập trình viên Flutter + người duyệt nội dung.

- [ ] Kiểm tra đầu vào → bài phù hợp → bốn giai đoạn học → hoàn thành → mở lại còn tiến độ.
- [x] Bổ sung A1 chương 1–4 từ TASK; kiểm tra prerequisite không thiếu/vòng lặp và sửa ID routing chương 1.
      Xem `CONTENT_AUDIT.md`; chính sách mở khóa/fast-track vẫn cần nghiệm thu trên app.
- [ ] Duyệt tiếng Anh, Pāli, ngữ cảnh Theravāda, nhãn phản hồi và hướng dẫn an toàn.
- [ ] Đóng gói âm thanh hoặc đảm bảo thông báo thiếu audio rõ ràng, không chặn học.
- [ ] Kiểm tra ở chế độ máy bay, màn hình nhỏ, cỡ chữ lớn và khi dữ liệu lưu bị hỏng.
- [ ] Làm rõ màn hình AI placeholder: ẩn khỏi luồng beta hoặc thay bằng luyện tập offline.
- [ ] Kiểm định Việt–Anh; rà soát fallback của locale ngoài phạm vi ưu tiên.

Điều kiện ra beta: không crash/blocker trong chu trình trên; tiến độ đúng sau restart;
không có yêu cầu khóa API; nội dung đã được người phụ trách duyệt.

## Giai đoạn 3 — AI/cloud (tách riêng, chỉ khi cần)

- Backend proxy có xác thực, rate limit, budget cap và log không chứa transcript nhạy cảm.
- Chính sách consent, lưu/xóa dữ liệu; phân biệt feedback cục bộ và feedback AI.
- Firebase initialization, auth, rules và kiểm thử quyền truy cập trước khi bật đồng bộ.
- Không để giai đoạn này chặn beta offline.

## Giai đoạn 4 — Beta có kiểm soát (dự kiến 2 tuần)

- Mời nhóm nhỏ học viên/người hướng dẫn; cài trên thiết bị thật.
- Ghi nhận lỗi với bước tái hiện, thiết bị/OS, mức độ; tránh đính kèm dữ liệu riêng tư.
- Theo dõi tỷ lệ hoàn thành bài, lỗi chặn học và phản hồi về nội dung.
- Chốt ngưỡng nghiệm thu với chủ dự án trước khi tuyển nhóm thử nghiệm.

## Giai đoạn 5 — Phát hành (1–2 tuần, chưa tính xét duyệt)

- [ ] Android signing riêng cho release; không dùng debug keystore cho store.
- [ ] Chính sách riêng tư, thông tin ứng dụng, license nội dung/font, kênh hỗ trợ.
- [ ] Bản build tái lập, version/lockfile thống nhất, quy trình rollback.
- [ ] iOS chỉ sau khi có signing/provisioning và kế hoạch TestFlight.
- [ ] Người phụ trách vận hành, triage lỗi và lịch cập nhật nội dung.

Bản ổn định/store vẫn cần đầy đủ điều kiện phát hành. Pre-release tải thử theo yêu cầu người dùng được xử lý riêng tại DELIVERY.md; không tạo tag/release rỗng khi chưa có APK.

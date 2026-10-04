# ZenGlish — Kanban

Cập nhật: **04/10/2026** (lượt ZEN-008/011). Bảng công việc chính nằm trong repository; cập nhật cùng PR thay đổi mã nguồn.

**Điểm bắt đầu (04/10/2026, sau khi PR #5 merge, main `e81fe37`):** ZEN-017/018 đã lên main; quality gate xanh trên **đúng** commit `e81fe37` (run [`37226659612`](https://github.com/Pabhassaracitto/zenglish/actions/runs/37226659612)). **ZEN-005 bị chặn bởi hai việc chỉ chủ dự án làm được**: (a) `flutter pub get` để resolve `pubspec.lock`, (b) tải artifact APK và tạo pre-release — sandbox agent không tải được artifact Actions (TLS tới `*.blob.core.windows.net` bị chặn, đã thử lại trong lượt này). Lượt này làm ZEN-008 (một nguồn tiến độ) + ZEN-011 (checklist nghiệm thu, `docs/BETA_ACCEPTANCE.md`).

**Quy ước:** Ready = có thể bắt đầu; Blocked = phụ thuộc bên ngoài; Verify = đã có mã nhưng chưa đạt kiểm tra cần thiết; Done = đạt tiêu chí của riêng thẻ, không đồng nghĩa sản phẩm đã phát hành.

| ID | Trạng thái | Ưu tiên / vai trò tiếp nhận | Công việc và điều kiện hoàn thành | Bằng chứng / phụ thuộc |
|---|---|---|---|---|
| ZEN-001 | Done | P0 · chủ repository | Cập nhật ba workflow, review và merge qua PR | **PR #4 đã MERGED 04/10/2026 17:41 UTC**; main hiện ở `8680240`. Gate xanh trên PR (run `37219148852`, 6m48s). Còn lại: xác nhận `Quality checks` xanh trên chính commit merge ở main |
| ZEN-002 | Blocked (cần SDK thật) | P0 · agent Flutter | Resolve trên Flutter 3.44.0, cập nhật lockfile; gen-l10n, analyzer, Flutter tests và APK đạt | CI trên PR #4 chạy Flutter 3.44.0: `pub get` **không** sửa `pubspec.lock` (không có annotation `pubspec.lock lệch`), gen-l10n + analyze + tests + `build apk --debug` đều xanh (run `37219148852`). Chưa có test thiết bị. **04/10: thêm `flutter_tts` nên CI cảnh báo `pubspec.lock` lệch** — cần máy có Flutter 3.44.0 chạy `flutter pub get` và commit lockfile trước ZEN-005. Sandbox không cài được SDK (`storage.googleapis.com` chặn TLS) nên agent **không đoán nội dung lockfile**; đã chuyển yêu cầu cho chủ dự án (HANDOFF mục 0-ter) |
| ZEN-003 | Verify | P0 · agent CI | Quality gate chạy trên PR/main, không đóng gói khi gate thất bại | Gate đạt trên PR #4 (content 8s · Flutter 2m08s · APK debug 4m21s · artifact 55.67 MB). `full_build`/`premium_build` đã nối `uses: ./.github/workflows/quality.yml`; chưa chạy đường đóng gói thật (không tag) |
| ZEN-004 | Ready | P0 · agent + chủ repository | Merge PR sau review/checks; xác nhận tài liệu, tests và nội dung đều có trên main | Người dùng đã yêu cầu create PR; ZEN-015 hoàn tất. Mở draft PR để review, chờ Flutter checks trước merge |
| ZEN-005 | Blocked | P0 · chủ dự án + agent release | Xuất bản `v1.0.1-beta.1` dạng pre-release có APK + SHA-256 + hướng dẫn cài | Gate xanh đúng commit sẽ tag: main `e81fe37`, run `37226659612` (analyze + tests + APK debug + validator, artifact `android-offline-beta-debug-37226659612`, 55.73 MB, hết hạn 18/10). **Blocker: agent không tải được artifact** (`gh api .../artifacts/11311829432/zip` → TLS fail tới `productionresultssa11.blob.core.windows.net`), nên không thể gắn APK vào Release; không tạo release rỗng. Lệnh cho chủ dự án ở HANDOFF mục 0-ter. `*-beta.*` không chạy `premium_build.yml` — đúng thiết kế |
| ZEN-006 | Done | P1 · agent nội dung | Đủ 8 bài trong registry, prerequisite không thiếu/vòng lặp, ID routing có trong assets | `validate_content.py` đạt; 7/7 Python tests đạt. Chỉ xác minh tĩnh, chưa nghiệm thu mở khóa trên UI |
| ZEN-007 | Verify | P1 · agent Flutter | Bài đọc email CH04, cờ review/audio và thông báo thiếu audio hiển thị đúng | Model/UI/tests đã bổ sung; chưa chạy Flutter tests/thiết bị |
| ZEN-008 | Verify | P1 · agent Flutter | Một nguồn tiến độ nhất quán: placement → home → hoàn thành → restart → gợi ý bài kế tiếp | Đã thêm `lib/data/services/progress_store.dart` (key canonical `userprofile`) + migration `progress_migrated_v1` đọc key rời cũ; `UserSessionService` và `UserProfileNotifier` thành facade; `home_provider` duyệt `buildCatalog()` qua `resolveNextEntry()` nên Home không còn trống khi bài gợi ý đã hoàn thành; mở bài đánh dấu in-progress. 4 test mới trong `test/data/services/progress_store_test.dart` + 3 test `resolveNextEntry`. Gate xanh trên PR [#6](https://github.com/Pabhassaracitto/zenglish/pull/6), run [`37227371313`](https://github.com/Pabhassaracitto/zenglish/actions/runs/37227371313) (analyze + tests + APK debug); **chưa** thử trên thiết bị (mục 3 của `docs/BETA_ACCEPTANCE.md`) |
| ZEN-009 | Ready | P1 · người duyệt nội dung | Duyệt 4 bản nháp A1, tiếng Anh/Pāli, tập quán thiền viện, phản hồi cho bài không phải trình pháp | Danh sách chi tiết trong CONTENT_AUDIT.md; không tự gỡ `needs_review`. **04/10: chủ dự án báo app chỉ thấy 4 bài — nguyên nhân là UI, không phải thiếu nội dung (ZEN-017), assets vẫn đủ 8 bài** |
| ZEN-010 | Verify | P1 · agent Flutter + người duyệt | Chưa có bản thu thì đọc bằng TTS; có file thu thì **tự ưu tiên bản thu**, không cần sửa code | Quyết định 04/10 của chủ dự án. Đã có `SpeechSynthesizer`/`SpeechService` + `resolveInputAudio` + nhãn "giọng tổng hợp" trên UI; nghe thử trên thiết bị và duyệt giọng/quyền vẫn chưa làm |
| ZEN-011 | Verify | P1 · agent + người dùng | Nghiệm thu APK: 8 bài, TTS, lưu tiến độ, máy bay, màn hình nhỏ/cỡ chữ lớn, Việt–Anh; triage lỗi | Checklist 6 mục đánh số: [`docs/BETA_ACCEPTANCE.md`](BETA_ACCEPTANCE.md). Chưa chạy được vì còn chờ APK của ZEN-005. Khi có phản hồi: mở thẻ riêng kèm bước tái hiện, không tự đóng |
| ZEN-012 | Ready | P2 · agent Flutter | Ẩn/thay AI placeholder; kiểm định locale ngoài Việt–Anh và hỗ trợ accessibility | Không mở rộng phạm vi ngôn ngữ trước khi luồng chính ổn định |
| ZEN-013 | Verify | P1 · agent kế tiếp | Bàn giao không phụ thuộc nhánh: AGENTS, Kanban, plan, handoff và quy trình merge/release đều có trên main | Đợt bàn giao tách workflow khỏi code/tests/docs. Chỉ hoàn tất sau khi merge và kiểm tra main |
| ZEN-015 | Done | P0 · agent trước PR | Đồng bộ main mới và giữ cả sửa theme trên main lẫn code/nội dung beta | Đã merge main `ce01f0a`, giải quyết conflict theme/localization, giữ ba tham chiếu AppColors. Validator và 7 Python tests đạt; Flutter checks vẫn ở ZEN-002. Fetch lại nếu main đổi |
| ZEN-016 | Done (không tái hiện) | P0 · agent Flutter | Tái hiện và xử lý báo lỗi `_lastVoiceText` undefined; xác minh lỗi theme không quay lại | `grep -rn "_lastVoiceText" lib` không có kết quả; `flutter analyze` xanh trên PR #4 (run `37219148852`). Mở lại nếu có file/dòng hoặc log mới |
| ZEN-017 | Verify | P0 · agent Flutter | Thư viện bài học: mọi bài trong registry đều có đường vào từ UI, có trạng thái/nhãn | **Nguyên nhân "chỉ thấy 4 bài"**: Home chỉ có 4 thẻ quick-start hardcode trong `ai_interview_quick_start.dart`, không màn hình nào gọi `loadAllLessons()`. Đã thêm `/lessons` + `lessonCatalogProvider` + thẻ vào Home + 4 test; gate xanh run `37223191246`. Chưa xem trên thiết bị |
| ZEN-018 | Verify | P1 · agent Flutter | TTS fallback đa ngôn ngữ, thay engine không đụng call-site (dọn đường cho Sherpa) | `SpeechSynthesizer` interface + `FlutterTtsSynthesizer` + `SpeechService.overrideWith()`. Gate xanh run `37223191246`; APK debug 53 MB (trước đó 55.67 MB — chưa tăng). Engine offline đóng gói (Sherpa-onnx) là thẻ riêng, chưa làm. Chưa nghe thử trên thiết bị |
| ZEN-014 | Backlog | P2 · chủ dự án + backend | Backend AI có xác thực/hạn mức/consent; cloud sync, store signing và vận hành | Ngoài beta offline; chưa triển khai |

## Cách tiếp nhận một thẻ

1. Chọn một thẻ ưu tiên cao nhất không bị chặn; ghi ID trong PR.
2. Ghi bằng chứng (lệnh + kết quả, commit/run/release URL thực nếu có).
3. Chỉ chuyển Done khi đạt điều kiện hoàn thành của thẻ. Nếu mới viết mã, chuyển Verify.
4. Cập nhật HANDOFF khi điểm tiếp tục/blocker thay đổi; giữ ID ổn định để agent khác theo dõi được qua lịch sử Git.

## Checklist tiếp nhận từ main — ZEN-013

- [ ] Có AGENTS.md và tất cả tài liệu được README dẫn tới; mở được các liên kết tương đối.
- [ ] Có đủ 8 bài trong registry; validator và 7 Python tests đạt trên checkout main.
- [ ] Đã xác minh merge commit/PR thật, bảo toàn sửa màu AppColors từ main.
- [ ] HANDOFF ghi đúng trạng thái workflow thủ công, Flutter checks, lockfile và APK; không đánh đồng “đã viết” với “đã chạy”.
- [ ] Có thể chọn thẻ tiếp theo không cần chat, ZIP hoặc checkout nhánh cũ.

Chỉ chuyển ZEN-013 Done sau khi kiểm tra trên main thực tế. Việc commit hoặc push tài liệu lên nhánh PR chưa đủ.

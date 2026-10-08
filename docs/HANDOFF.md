# ZenGlish — bàn giao cho phiên/agent tiếp theo

Cập nhật: **07/10/2026** (mục 0-ter). Đọc cùng [Kanban](KANBAN.md), [plan](IMPLEMENTATION_PLAN.md) và [content audit](CONTENT_AUDIT.md).

## 0-ter. ZEN-019 — audio Hugging Face: ưu tiên local, stream + tải về máy — 07/10/2026

**Bối cảnh:** chủ dự án đã dựng file giọng AI cho 8 bài (hướng "file dựng sẵn bằng TTS chất lượng cao" — phân tích trong `docs/CONTENT_AUDIT.md`) và host tại dataset [Beyou8778/zenglish-audio](https://huggingface.co/datasets/Beyou8778/zenglish-audio/tree/main), quy ước đặt tên `<LESSON_ID>_input_<NN>.mp3` (ví dụ `A1_CH01_L01_input_01.mp3`).

**Đã làm (PR nhánh này — gate CI là căn cứ, chưa thử thiết bị):**

- `lib/data/constants/audio_catalog.dart`: danh mục tập trung 8 file + base URL Hugging Face, quy ước tên, dung lượng ước tính (~1,5 MB/file — chỉ để hiển thị).
- `lib/data/services/input_audio_resolver.dart`: chuỗi ưu tiên mới — (1) `audio_url` tường minh trong lesson JSON (bản thu con người, validator bắt buộc bundle, **không** nhãn AI) → (2) file bundle trong `assets/audio/` → (3) file đã tải về `<documents>/zenglish_audio/` (index `audio_index.json`) → (4) stream URL Hugging Face + mời tải về → (5) bài ngoài danh mục giữ fallback TTS thiết bị. Audio thuộc danh mục luôn gắn nhãn "giọng tổng hợp" (là giọng AI).
- `lib/data/services/audio_download_service.dart`: tải streaming qua `http` (HEAD lấy dung lượng thật, ghi `.part` rồi đổi tên nên không có file dở dang), kết quả bằng enum không ném lỗi, huỷ giữa chừng, xoá theo bài/tất cả; `AudioPromptStore` nhớ lựa "Tải sau" theo bài để không hỏi lại.
- `AudioPlaybackService`: thêm phát file tuyệt đối (`setFilePath`) và playlist nhiều đoạn (`ConcatenatingAudioSource`); `lesson_screen` lắng nghe `playerStateStream` nên nút phản ánh trạng thái thật. Giữ UX nút **Nghe/Dừng** của PR #7 (Dừng = stop hẳn).
- UX bài học: mở bài lần đầu chưa có local → lời mời + dung lượng ước tính + [Tải audio] [Tải sau] [Quản lý]; đang tải → thanh tiến trình + % + huỷ; lỗi mạng → thông báo rõ + Thử lại; tải xong → lần sau phát ngay từ local, không hỏi lại. Không tải vẫn nghe được (stream).
- Màn hình `/audio-manager` (`AudioManagerScreen`): tải theo **chương** hoặc **toàn bộ**, ước tính dung lượng trước khi tải, tiến trình tổng, xoá từng bài / xoá tất cả (hỏi xác nhận). Không tự động tải gì. Lối vào: mục **"Quản lý audio" trong màn hình Cài đặt** (`/settings` của PR #7, hiện số file + dung lượng đã lưu) và icon tai nghe trên AppBar `/lessons`.
- Thêm quyền `INTERNET` trong `android/app/src/main/AndroidManifest.xml` (trước đó **thiếu** — bản release không stream/tải được).
- Validator: `scripts/validate_content.py` kiểm tra danh mục audio (quy ước tên, trùng, thiếu bài, dung lượng ≤ 0) + 4 Python test mới; local 11/11 đạt.
- Dart tests: viết lại `input_audio_resolver_test.dart` theo chuỗi ưu tiên mới, mới `audio_catalog_test.dart`, `audio_download_service_test.dart` (encode/parse index thuần), cập nhật test nhãn AI của catalog.

**⚠️ Phát hiện quan trọng khi đồng bộ main (07/10):** PR #7 (`69b4663`) khi merge đã **vô tình hoàn tác một phần PR #6 (ZEN-008)** trên main: `resolveNextEntry()` + 3 test của nó biến mất khỏi `catalog_provider.dart`/`catalog_provider_test.dart`, `user_session_service.dart`/`user_profile_provider.dart`/`home_provider.dart`/`lesson_provider.dart` quay về bản trước ZEN-008, và các cập nhật docs 05/10 (ZEN-005 đóng, ZEN-009 duyệt, lockfile) cũng mất. **PR này KHÔNG khôi phục phần đó** (giữ phạm vi audio); thẻ **ZEN-020** mở để khôi phục riêng — bằng chứng: `git diff 5306bbb 69b4663` cho thấy các file trên bị lùi phiên bản.

**Giới hạn / rủi ro của lượt này:**

1. Sandbox không có Flutter SDK và không với tới pub.dev/Hugging Face: `flutter pub get/gen-l10n/analyze/test/build apk` **chưa chạy local** — gate trên PR là căn cứ.
2. Khai báo dependency trực tiếp `path_provider: ^2.1.5` (lock đã có 2.1.5 dạng transitive qua Firebase): `flutter pub get` trên CI chuyển thành `direct main` → cảnh báo `pubspec.lock lệch` (không chặn merge; xử lý cùng ZEN-002 trên máy có SDK).
3. **Chưa đối chiếu được danh sách file thật trên dataset** (mạng sandbox chặn Hugging Face): danh mục khai báo 1 file/bài theo quy ước `_input_01`. Nếu dataset thiếu file nào, app báo "chưa có trên máy chủ" và không crash; nếu có thêm đoạn (`_input_02`…) chỉ cần bổ sung entry vào `AudioCatalog.files` — luồng phát đã hỗ trợ playlist nhiều đoạn. Việc cần làm: mở dataset, khớp tên file, cập nhật danh mục + ước tính dung lượng.
4. Dung lượng ước tính 1,5 MB/file là con số hiển thị; khi tải thật dùng Content-Length từ HEAD.

**Điểm tiếp tục:** (1) lấy kết quả gate của PR và sửa nếu analyze/test lỗi; (2) làm ZEN-020 (khôi phục phần PR #6 bị PR #7 hoàn tác) — lấy lại từ lịch sử `5306bbb`; (3) khớp danh mục audio với dataset thật (mục 3 ở trên); (4) nghiệm thu trên thiết bị: tải 1 bài → máy bay → nghe offline; nghe stream không tải; huỷ tải; xoá và tải lại; màn Quản lý audio trong Cài đặt; (5) nếu muốn bundle audio vào APK: đặt file vào `assets/audio/` **đúng tên trong danh mục** — app tự ưu tiên bundle và ẩn nút tải, không cần sửa code.

## 0-bis. Thư viện bài học + TTS fallback — 04/10/2026, sau khi PR #4 merge

**Bối cảnh:** PR #4 đã MERGED (04/10 17:41 UTC); `main` ở `8680240`; Flutter pin **3.44.0** đã được chứng minh đạt. Nhánh phiên này được đồng bộ bằng `git reset --hard origin/main` (nhánh chưa có commit riêng; `c3c5b25` đã nằm trong lịch sử squash của main nên `git rebase origin/main` báo conflict giả — không dùng rebase trong tình huống này).

**Chủ dự án báo:** trong app chỉ thấy 4 mục (Ānāpāna, Giới, 5 Phần, Sức khoẻ).

**Chẩn đoán (xác minh bằng mã nguồn, không phải phỏng đoán):**

- `assets/data/lessons/` vẫn đủ 8 bài; `validate_content.py` đạt → **không mất nội dung**.
- 4 mục đó là `_QuickCardGrid` **hardcode** trong `lib/presentation/screens/home/components/ai_interview_quick_start.dart`.
- Trước bản sửa này **không màn hình nào liệt kê bài học**: Home chỉ render một bài đề xuất (`home_provider._resolveNextLessonId`), và hàm đó trả `null` nếu bài gợi ý đã hoàn thành.
- Hệ quả: A1 CH01–04 nằm trong assets nhưng không có đường vào từ UI.

**Đã làm trong lượt này:**

1. **ZEN-017 — thư viện bài học.** `lib/presentation/providers/catalog_provider.dart` (hàm thuần `buildCatalog` + `lessonCatalogProvider`), `lib/presentation/screens/catalog/lesson_catalog_screen.dart`, route `/lessons` trong `app_router.dart`, thẻ `LessonLibraryCard` trên Home. Danh sách đọc thẳng từ `ILessonRepository` nên thêm bài vào registry là bài tự xuất hiện. Nhãn: hoàn thành/đang học, `needs_review`, "giọng tổng hợp", bài tiên quyết còn thiếu. **Không chặn** mở bài vì chính sách mở khoá chưa được nghiệm thu.
2. **ZEN-010/018 — TTS fallback.** `lib/data/services/speech_service.dart` (interface `SpeechSynthesizer`, impl `FlutterTtsSynthesizer`, điểm đổi engine `SpeechService.overrideWith`), `lib/data/services/input_audio_resolver.dart` (quy tắc ưu tiên, tách khỏi UI để test được), `AudioPlaybackService.playInput()`, nhãn minh bạch "giọng tổng hợp" ở Input stage. Thêm dependency `flutter_tts: ^4.2.0`.
3. **ZEN-016 — đóng do không tái hiện.** `grep -rn "_lastVoiceText" lib` không có kết quả; analyzer xanh trên PR #4.
4. Tests mới: `test/data/services/input_audio_resolver_test.dart` (3 test), `test/presentation/providers/catalog_provider_test.dart` (4 test).

**Bằng chứng CI (nhánh `arena/01a107e0-zenglish`):** run [`37223191246`](https://github.com/Pabhassaracitto/zenglish/actions/runs/37223191246) — `Resolve SDK pins` ✅, `Content validator + Python tests` ✅, `Flutter analyze + tests` ✅, `Android debug APK (ARM64)` ✅ (artifact `android-offline-beta-debug-37223191246`, 53 MB), tổng ~3m47s trên Flutter 3.44.0. Run trước đó (`37222806982`) **đỏ ở bước analyze**: `AppTheme` chỉ re-export một phần màu và **không có `success`/`warning`** — phải dùng `AppColors.success` / `AppColors.warning`. Bài học cho agent sau: đối chiếu hằng số với `lib/core/theme/app_theme.dart` trước khi push, vì sandbox không chạy được analyzer.

**Cảnh báo còn mở:** CI báo `flutter pub get` phải sửa `pubspec.lock` (do thêm `flutter_tts`). Cảnh báo này không chặn merge, nhưng **cần một máy có Flutter 3.44.0 chạy `flutter pub get` rồi commit `pubspec.lock`** trước khi phát hành ZEN-005. Sandbox không lấy được lockfile từ CI: tải log và artifact của Actions đều bị chặn TLS (`results-receiver.actions.githubusercontent.com`, `*.blob.core.windows.net`). Khi cần đọc nguyên nhân lỗi, dùng job summary (đã thêm bước in log analyze) hoặc `gh api .../check-runs/<job_id>/annotations`.

**Giới hạn kiểm chứng của lượt này:** sandbox vẫn **không có Flutter/Dart/Java** (`storage.googleapis.com` lỗi `SSL_ERROR_SYSCALL`, giống mục 4). Đã chạy local: `python3 scripts/validate_content.py` → `PASS: 8 lessons`; 7/7 Python tests OK; `git diff --check` sạch. **`flutter pub get` / `gen-l10n` / `analyze` / `test` / `build apk` chỉ được chứng minh qua Actions trên PR của nhánh này** — đọc run thật trước khi coi là đạt. Có dependency mới nên `pubspec.lock` sẽ đổi: lấy lockfile từ CI hoặc máy có SDK rồi commit, **không sửa tay**.

**Điểm tiếp tục:** chờ gate xanh → merge → ZEN-005 (pre-release APK + SHA-256) → ZEN-011 (nghiệm thu thiết bị: thấy đủ 8 bài trong `/lessons`, nghe thử TTS, chế độ máy bay) → ZEN-008 (hai nguồn tiến độ `user_profile_provider` vs `user_session_service`).

## 0. Bản cập nhật workflow cho quality gate trên PR — 18/09, chốt phương án 04/10/2026

Chủ dự án yêu cầu nộp workflow để test Flutter ngay khi mở pull request, nên `.github/workflows/` không còn tách riêng ngoài repo. **Trạng thái 04/10/2026: ĐÃ PUSH và mở [PR #4](https://github.com/Pabhassaracitto/zenglish/pull/4) (draft, base main). Quality gate mới chạy XANH trên PR** — run `37219148852` (event `pull_request`, SHA `c7e6935`): `Resolve SDK pins` 8s, `Content validator + Python tests` 8s, `Flutter analyze + tests` 2m08s, `Android debug APK (ARM64)` 4m21s, `Run summary` 3s; tổng **6m48s**, conclusion `success`. Artifacts: `android-offline-beta-debug-37219148852` = 55.67 MB (hết hạn 18/10), `flutter-coverage` = 12.8 KB. **Flutter 3.44.0 được chứng minh đạt** trên repo này (analyze + toàn bộ Flutter tests + build APK debug). Lúc 18/09 push còn bị chặn vì GitHub App thiếu quyền `workflows`; quyền đã được cấp nên patch/ZIP bàn giao không còn cần thiết (xem `docs/DELIVERY.md` mục E nếu gặp lại). Nếu quyền `workflows` bị thu hồi lại, tạo patch bất cứ lúc nào bằng lệnh ở `docs/DELIVERY.md` mục E — nội dung nằm trọn trong commit của repo, không phụ thuộc file tạm của phiên. Đã sửa ba file + tài liệu liên quan:

- `.github/workflows/quality.yml` (viết lại): triggers `pull_request → main`, `push → main|arena/**`, `workflow_dispatch` (có input `flutter_version`), `workflow_call` (có outputs `flutter_version`/`java_version`). Jobs: `sdk-pin` (pin + guard chống hardcode SDK ở workflow khác) ∥ `content` (validator + unittest) → `flutter` (pub get có cache → gen-l10n → analyze → test --coverage → summary + artifact coverage) → `android-debug-apk` (Java 17, `flutter build apk --debug --target-platform android-arm64`, artifact `android-offline-beta-debug-<run_id>` 14 ngày, SHA-256 trong summary) → `run-summary`. `concurrency` hủy run PR cũ, `timeout-minutes` từng job, `permissions: contents: read`.
- `.github/workflows/full_build.yml`: vẫn chỉ `workflow_dispatch`; mọi build lấy SDK từ `needs.quality.outputs.*`, thêm `timeout-minutes` + `concurrency`.
- `.github/workflows/premium_build.yml`: thêm job `quality` (`uses` reusable) trước `prepare`; build bỏ `always()` nên chỉ chạy khi gate + prepare xanh; `create-release` yêu cầu không build nào fail/cancel; filter tag `v*` + `!v*-beta.*`; `cancel-in-progress: false`.
- Pin mặc định đổi sang **3.44.0** theo lựa chọn của chủ dự án (một dòng `env.FLUTTER_VERSION_DEFAULT` trong `quality.yml`; hai workflow đóng gói nhận qua output của gate, không tự khai báo). **Đã chứng minh đạt**: PR #4 xanh toàn bộ trên 3.44.0, và CI **không** gắn cảnh báo `pubspec.lock lệch` nghĩa là `flutter pub get` không phải sửa lockfile. Kịch bản dự phòng vẫn còn nguyên: nếu job `flutter` đỏ vì lint mới hoặc `pubspec.lock`, chạy dispatch với `flutter_version=3.41.4` để xác nhận nguyên nhân là bump SDK, rồi lùi một dòng pin và xử lockfile ở ZEN-002 — không tắt analyze/test để lấy xanh.
- Job `android-debug-apk` giữ trên **mọi PR/push** sau khi chủ dự án xác nhận chi phí: repo public nên phút runner + storage artifact không tính tiền, `main` không bật branch protection (chỉ có trần 6h/job và concurrency theo tài khoản). Đo thật trên PR #4: job `Android debug APK (ARM64)` 4m21s, artifact debug 55.67 MB (bản release arm64 gần nhất 22.5 MB); có cache `~/.gradle` để rút thời gian các run sau.

Bằng chứng đã chạy trong sandbox: `git diff --check` sạch; `python3 scripts/validate_content.py` → `PASS: 8 lessons`; `python3 -m unittest discover -s scripts -p 'test_*.py'` → `Ran 7 tests ... OK`; ba file YAML parse bằng PyYAML; script của job `sdk-pin` (guard + resolve outputs/summary) mô phỏng đạt cả hai nhánh override. **Không có Flutter/Dart/Java trong sandbox** (`storage.googleapis.com` và `results-receiver.actions.githubusercontent.com`/Azure blob log đều chặn TLS như mục 4) nên mọi lệnh Flutter chưa chạy local — bằng chứng thật lấy từ run Actions ở đầu mục này.

Hai cạm bẫy môi trường đã gặp,agent sau cần biết:

1. **Commit restore có thể mất cha.** Khi workspace được restore giữa phiên, thay đổi hiện ra như một commit gốc (orphan, `parents=[]`) trên `c3c5b25`; GitHub từ chối tạo PR với "no history in common with main". Kiểm tra `git log --format='%h parents=[%p]' -2` trước khi mở PR; nếu mồ côi thì `git reset --soft origin/main && git commit -F <msg>` (tree giữ nguyên — đã đối chiếu `git rev-parse HEAD^{tree}`) rồi `git push --force-with-lease`.
2. **Không có YAML parser sẵn.** `pip install pyyaml` phải cài lại mỗi phiên (chỉ `/home/user/zenglish` được giữ); hệ quả: kiểm tra YAML tĩnh nên làm bằng lệnh trong `docs/DELIVERY.md` mục E.

Việc tiếp theo: (0) **gỡ blocker quyền `workflows`** — chủ repository cấp quyền cho GitHub App hoặc tự áp patch rồi mở PR; (1) xem run `Quality checks` của PR workflow — nếu `flutter` fail do lint/test thì sửa code, **không nới gate**; (2) nếu APK fail vì runner thiếu Android SDK/NDK, ghi log và báo, không bỏ job APK; (3) merge ZEN-001/003 khi run xanh, điền run URL + SHA vào bảng mục 2; (4) ZEN-002 vẫn chờ resolve `pubspec.lock` trên SDK thật (CI sẽ báo warning nếu lockfile lệch).

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
| Commit workflow do chủ repository cập nhật | Đã commit trên nhánh phiên; **push fail vì thiếu quyền `workflows`**, patch/ZIP ở workspace; chưa PR, chưa run |
| CI / Flutter tests / APK đúng SHA main | Quality checks cũ (pin 3.41.4) xanh trên main `c3c5b25`; APK debug artifact và gate mới **chưa** có run |
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

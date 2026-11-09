# ZenGlish

Ứng dụng Flutter học tiếng Anh trong bối cảnh Theravāda — trí tuệ và thiền tập
("English for Wisdom & Meditation"): từ vựng và mẫu câu dùng ở thiền viện,
tình huống trình pháp (meditation interview), bài học xếp lớp theo CEFR A1→B1.
Chạy offline-first trên Android/iOS/Desktop/Web; hồ sơ và tiến độ lưu trên thiết bị.

## Trạng thái hiện tại (đối chiếu 09/11/2026, main `a779563`)

- **Toàn bộ 12 PR đã merge vào main.** Quality gate (`quality.yml`, gộp từ PR #4
  ngày 04/10/2026) đang chạy thật trên main: `Quality checks` run
  [39818959870](https://github.com/Pabhassaracitto/zenglish/actions/runs/39818959870)
  và `Deploy Web to GitHub Pages` run
  [39818959924](https://github.com/Pabhassaracitto/zenglish/actions/runs/39818959924)
  đều **xanh** trên chính commit main mới nhất.
- **Release mới nhất: [v1.1.2](https://github.com/Pabhassaracitto/zenglish/releases/tag/v1.1.2)**
  (xuất bản 24/10/2026 từ run
  [40059744342](https://github.com/Pabhassaracitto/zenglish/actions/runs/40059744342),
  tag đúng main `a779563`), kèm đủ artifacts: `zenglish-Android-ARM64-1.1.2.apk`,
  `app-release.aab`, `zenglish-iOS-1.1.2.ipa` (build `--no-codesign`, phải tự ký
  để sideload), `zenglish-Windows-1.1.2.zip`, `zenglish-Linux-1.1.2.zip`.
  Lịch sử release: v1.0 (06/2026) → v1.1.0 (04/10) → v1.1.1 (21/10) → v1.1.2 (24/10).
- **Bản web (PWA) đang chạy trên GitHub Pages:**
  <https://pabhassaracitto.github.io/zenglish/> — `web.yml` tự build và deploy mỗi
  lần push vào main (nhánh `arena/**` và PR chỉ build kiểm chứng, không deploy).
- `pubspec.yaml` đang ở `1.1.1+3`; version release được truyền lúc build
  (`--build-name`), nên tag `v1.1.2` không đòi sửa pubspec.
- APK release hiện ký bằng **debug keystore** (chưa có signing config release trong
  `android/app/build.gradle.kts`): cài trực tiếp được, không phải gói Play Store.
- Chưa phát hành lên Play Store/App Store; chưa có đồng bộ tài khoản hay cloud sync.

## Dùng thử ngay

- **Web:** mở <https://pabhassaracitto.github.io/zenglish/> (cài được như PWA).
- **Android (ARM64):** tải `zenglish-Android-ARM64-<version>.apk` từ
  [Releases](https://github.com/Pabhassaracitto/zenglish/releases), cho phép cài từ
  nguồn không xác định. Gỡ app sẽ **mất tiến độ local** (chưa có backup).
- Mỗi PR/push còn có APK **debug** trong artifact `android-offline-beta-debug-<run_id>`
  (giữ 14 ngày) + SHA-256 trong job summary của `Quality checks` để cài thử trước merge.
- Checklist nghiệm thu thiết bị: [docs/BETA_ACCEPTANCE.md](docs/BETA_ACCEPTANCE.md).

## Tiếp nhận dự án / AI handoff

Bắt đầu từ [AGENTS.md](AGENTS.md). Tài liệu nằm trong repository, không phụ thuộc
nhánh tạm hay lịch sử chat:

- [Kanban](docs/KANBAN.md): công việc, trạng thái và tiêu chí hoàn thành (ZEN-xxx).
- [Handoff](docs/HANDOFF.md): tình trạng kiểm chứng, blocker và điểm tiếp tục
  (mục mới nhất: `0-quinquies` — ZEN-021, audio theo từng hội thoại).
- [Plan](docs/IMPLEMENTATION_PLAN.md): phạm vi và thứ tự triển khai.
- [Content audit](docs/CONTENT_AUDIT.md): nguồn bài học, nội dung đã duyệt, chính sách âm thanh.
- [Delivery](docs/DELIVERY.md) / [Workflow manual](docs/WORKFLOW_MANUAL.md): quy trình
  đồng bộ main, PR, build và phát hành.

Ghi chú lịch sử trong các docs ("PR #4 chưa merge", "chưa có release"…) là trạng thái
tại thời điểm viết; trạng thái thật đã đi xa hơn — đối chiếu Kanban, trang PR/runs
trên GitHub trước khi kết luận. Việc còn mở (theo Kanban, cập nhật 22/10/2026):
**ZEN-011** nghiệm thu APK trên thiết bị, **ZEN-020** khôi phục phần nguồn tiến độ
ZEN-008 bị PR #7 hoàn tác nhầm, **ZEN-019** đối chiếu dung lượng/tên file thật trên
dataset Hugging Face, **ZEN-012** kiểm định locale ngoài Việt–Anh.

## Hướng triển khai hiện tại

**Offline-first; ưu tiên kiểm định Việt–Anh.**
Tám bài beta được tải từ `assets/data/lessons/`; cả 8 bài không còn nhãn "chờ duyệt"
(`needs_review=false`) — nội dung bài đọc 4 bài A1 CH01–04 đã được chủ dự án duyệt
chính thức (ZEN-009: quyết định 05/10/2026, xác nhận lại 20/10/2026). Phạm vi duyệt
là nội dung bài đọc, **không** gồm quyền giọng đọc/bản thu (ZEN-010).
Phản hồi luyện tập sử dụng bộ phân tích cục bộ, không phải đánh giá chứng đắc.
AI từ xa bị vô hiệu hóa cứng trong `lib/core/env/env.dart` (`isConfigured=false`),
kể cả khi truyền `OPENAI_API_KEY` qua build define.
Hồ sơ và tiến độ lưu trên thiết bị (SharedPreferences); chưa có tài khoản, chưa có
đồng bộ đám mây.

## Nội dung beta — 8 bài

| Mã bài | Tên bài | Cấp |
|---|---|---|
| `A1_CH01_L01` | Cơ Duyên Đến Với Đạo Phật | A1 |
| `A1_CH02_L01` | Đến Thiền Viện Lần Đầu | A1 |
| `A1_CH03_L01` | Sinh Hoạt Hằng Ngày Tại Thiền Viện | A1 |
| `A1_CH04_L01` | Đăng Ký Khóa Thiền (bài đọc email, không hội thoại) | A1 |
| `A1_CH05_L01` | Sức Khỏe & Nhu Cầu Cá Nhân Tại Thiền Viện | A1 |
| `A2_CH06_L01` | Ānāpāna — Trình Pháp Về Thiền Hơi Thở | A2 |
| `A2_CH07_L01` | Năm Giới & Tám Giới — Trình Pháp Về Việc Giữ Giới | A2 |
| `B1_CH12_L01` | Trình Pháp 5 Phần (Cốt Lõi) | B1 |

Nguồn nhập từ các draft trong `lib/tasks/` (TASK_002–TASK_009); prerequisites không
thiếu/không vòng lặp, được ép bằng `scripts/validate_content.py` + tests.
Màn hình **Thư viện bài học** (`/lessons`) liệt kê toàn bộ bài trong registry; Home
chỉ hiển thị bài đề xuất và 4 thẻ trình pháp nhanh. Badge tiên quyết hiện
"Nên học trước: \<tên bài\>" của bài thiếu đầu tiên (ZEN-021), không in mã bài.

## Âm thanh bài học

- **11 file giọng tổng hợp dựng sẵn** trong `AudioCatalog`
  (`lib/data/constants/audio_catalog.dart`) — mỗi hội thoại/bài đọc một file, host
  tại dataset Hugging Face
  [`Beyou8778/zenglish-audio`](https://huggingface.co/datasets/Beyou8778/zenglish-audio/tree/main).
  Quy ước tên: `<LESSON_ID>_input_<NN>.mp3` theo thứ tự hội thoại; bài đọc đơn dùng
  hậu tố `_reading` (ví dụ `A1_CH04_L01_input_reading.mp3`). Validator ép
  *số file mỗi bài == số đoạn Input*.
- **Phát đúng hội thoại đang xem** (ZEN-021): đứng ở hội thoại 2/2 bấm Nghe sẽ phát
  file `_input_02`; chuyển hội thoại thì dừng player thật; nhãn player hiện
  "Audio — Hội thoại x/n" / "Audio — Bài đọc".
- Chuỗi ưu tiên do `resolveInputAudio()` quyết định: bản thu thật trong `audio_url`
  (không gắn nhãn AI) → file bundle trong `assets/audio/` → file đã tải về máy
  (`<documents>/zenglish_audio/`, index `audio_index.json`) → stream Hugging Face kèm
  mời tải về. Audio AI luôn gắn nhãn **"giọng tổng hợp"**.
- Màn **Quản lý audio** (`/audio-manager`, vào từ Cài đặt hoặc icon trên `/lessons`):
  tải từng bài/theo chương/toàn bộ, ước tính dung lượng, huỷ/xoá file, báo lỗi mạng
  kèm thử lại.
- Bài ngoài danh mục dùng **TTS của thiết bị** (`flutter_tts`) làm fallback; engine
  nằm sau interface `SpeechSynthesizer` nên thay được (ví dụ Sherpa-onnx offline)
  mà không sửa UI.

## Thiết lập

- Flutter **3.44.0** (stable) là pin mặc định của CI, khai báo **một chỗ duy nhất**:
  `env.FLUTTER_VERSION_DEFAULT` trong `.github/workflows/quality.yml`; các workflow
  đóng gói nhận lại qua output của quality gate (có job `sdk-pin` chặn hardcode lệch).
  `web.yml` khai báo cùng giá trị `3.44.0` trong `env.FLUTTER_VERSION` và phải giữ
  khớp. `pubspec.lock` (Dart `>=3.11.0`) và `pubspec.yaml` (Flutter `>=3.41.0`) tương
  thích Dart 3.12.2 đi kèm 3.44.0; gate đã xanh trên 3.44.0 (PR #4 run `37219148852`,
  và các run trên main sau này).
- Android SDK và Java 17 để build Android.
- Không cần khóa API hoặc cấu hình Firebase cho beta offline (Firebase/Firestore chỉ
  là mã dự phòng, không dùng trong luồng hiện tại).

```sh
python3 scripts/validate_content.py
python3 -m unittest discover -s scripts -p 'test_*.py'   # 13 tests
flutter --version                                        # 3.44.0
flutter pub get
flutter gen-l10n
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test --coverage
flutter run
flutter build apk --debug --target-platform android-arm64
flutter build web --release --base-href /zenglish/       # như bản Pages
```

Analyzer hiện chặn **errors**; warnings và lint infos là nợ kỹ thuật cần giảm dần.
APK debug chỉ dùng thử nội bộ; bản phát hành cho người dùng lấy từ GitHub Releases.
Sau lần resolve dependencies thành công, rà soát và commit thay đổi `pubspec.lock`.

## Cấu trúc mã

```
lib/
├── core/          # constants (dhamma keywords), enums (CEFR, meditation stage…),
│                  # env (khóa AI bị vô hiệu), providers (locale, profile),
│                  # router (GoRouter), theme (Merriweather + AppColors)
├── presentation/  # screens: splash → placement → home → lesson (4 stage:
│                  # Input/Guided/Pattern/Output) → catalog (/lessons) →
│                  # settings → audio-manager; providers Riverpod
├── data/          # models, repositories (JSON local; Firebase dự phòng),
│                  # services: audio download/playback/resolver, progress store,
│                  # speech (TTS), user session; constants: AudioCatalog,
│                  # LessonAssetRegistry
├── ai/            # engine phân tích phản hồi cục bộ (opening/difficulty/
│                  # location/object analyzers) + service OpenAI chưa dùng trong beta
├── logic/         # placement logic, content router
├── l10n/          # 26 file .arb (nguồn bản dịch — CHỈ sửa ở đây),
│                  # facade app_localizations.dart (extension context.l10n),
│                  # generated/ do `flutter gen-l10n` sinh, không commit/sửa tay
└── tasks/         # JSON draft nguồn nội dung (TASK_001–010), không đóng gói vào app
assets/data/lessons/   # 8 bài JSON beta (được đóng gói)
assets/audio/          # audio bundle nếu có (hiện trống — audio lấy từ HF/tải về)
assets/fonts/          # Merriweather Regular + Bold (đóng gói, không tải mạng)
scripts/               # validate_content.py + test_*.py (13 unit tests)
test/                  # Dart tests: models, repository, resolver audio, catalog,
                       # progress store, providers, AI engine, widget
```

Các route chính: `/` (splash) → `/placement` → `/home` → `/lessons` (thư viện) →
`/lesson/:lessonId` → `/settings` → `/audio-manager` → `/ai-interview`.

Font tiêu đề Merriweather đóng gói sẵn; nội dung dùng font hệ thống, không tải
Google Fonts lúc chạy (`google_fonts` còn trong pubspec nhưng không được dùng trong
`lib/`).

## Bản địa hóa

26 locale trong `lib/l10n/` (template `app_vi.arb`): ar, bn, bo, de, en, es, fr,
hi, id, it, ja, km, ko, lo, mn, mr, my, pt, ru, si, ta, te, th, vi, zh, zh-TW.
**Việt–Anh là cặp đã kiểm định**; các locale còn lại chưa nghiệm thu bản dịch và
tương thích widget/font (ZEN-012) — không mở rộng phạm vi ngôn ngữ trước khi luồng
chính ổn định.

## CI/CD

Bốn workflow trong `.github/workflows/`, tất cả đã merge và chạy thật:

1. **`quality.yml` — Quality checks** (quality gate, `contents: read`): chạy trên
   **pull request** vào main, push `main`/`arena/**`, `workflow_dispatch` (có input
   override `flutter_version`) và `workflow_call` cho hai workflow đóng gói.
   Các job: `sdk-pin` (resolve + guard chống hardcode pin) →
   `Content validator + Python tests` → `Flutter analyze + tests`
   (pub get cache theo lockfile → gen-l10n → analyze chặn errors → test --coverage,
   artifact `flutter-coverage`) → `Android debug APK (ARM64)` trên **mọi PR/push**
   (cache Gradle, artifact `android-offline-beta-debug-<run_id>` 14 ngày + SHA-256
   trong summary). Run mới của cùng PR thay run cũ (`cancel-in-progress`), mỗi job
   có `timeout-minutes`. Repo public nên phút runner và storage không tính tiền.
2. **`web.yml` — Deploy Web to GitHub Pages**: build Flutter web release
   (`--base-href /zenglish/`, kèm `404.html` SPA fallback và `.nojekyll`), upload
   Pages artifact; **chỉ deploy từ main** (environment `github-pages` có protection
   rule), PR/nhánh `arena/**` chỉ build kiểm chứng.
3. **`premium_build.yml` — Flutter Full Build (Android, iOS, Windows, Linux, Web)**:
   đường phát hành theo tag `v*` (loại `v*-beta.*`) hoặc `workflow_dispatch` với
   input version. Gọi quality gate trước `prepare`; build APK/AAB (ARM64), IPA
   không ký, Windows zip, Linux zip, Web; job `create-release` chỉ chạy khi gate +
   prepare xanh, version là stable và không build nào fail — tạo GitHub Release kèm
   toàn bộ artifacts (v1.1.0/v1.1.1/v1.1.2 ra đời bằng đường này).
4. **`full_build.yml` — Legacy manual platform builds**: chỉ `workflow_dispatch`,
   chọn từng nền tảng, phụ thuộc cùng quality gate; giữ làm đường dự phòng.

Chi tiết đặc tả và lịch sử nộp workflow: [docs/WORKFLOW_MANUAL.md](docs/WORKFLOW_MANUAL.md).
Quy trình đồng bộ main → PR → release: [docs/DELIVERY.md](docs/DELIVERY.md).

## Giới hạn bảo mật và dữ liệu

- Không truyền khóa dịch vụ vào ứng dụng hoặc commit credentials.
- AI online chỉ triển khai sau khi có backend xác thực, hạn mức và chính sách dữ
  liệu (ZEN-014, backlog).
- SharedPreferences không phải kho dữ liệu nhạy cảm mã hóa; không nhập thông tin
  riêng tư vào beta.
- Gỡ ứng dụng/xóa dữ liệu có thể làm mất tiến độ; chưa có backup hoặc cloud sync.
- Audio dựng sẵn là **giọng tổng hợp (AI)**, được ghi nhãn rõ trong UI; không trình
  bày như bản thu của một vị thầy. ToS phân phối lại audio cần rà soát (ZEN-010).

## Tài liệu dự án

| Tài liệu | Nội dung |
|---|---|
| [AGENTS.md](AGENTS.md) | Quy ước làm việc cho agent: nguồn sự thật, kiểm tra tối thiểu, quy trình PR |
| [docs/KANBAN.md](docs/KANBAN.md) | Bảng công việc ZEN-xxx, trạng thái và bằng chứng |
| [docs/HANDOFF.md](docs/HANDOFF.md) | Bàn giao phiên: đã làm gì, blocker, điểm tiếp tục |
| [docs/IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md) | Phạm vi, các gate G0–G4, thứ tự sprint |
| [docs/CONTENT_AUDIT.md](docs/CONTENT_AUDIT.md) | Rà soát nội dung, chính sách âm thanh, quyết định ZEN-009/010 |
| [docs/DELIVERY.md](docs/DELIVERY.md) | Đồng bộ main, PR, tạo APK beta, hướng dẫn người dùng thử |
| [docs/WORKFLOW_MANUAL.md](docs/WORKFLOW_MANUAL.md) | Đặc tả CI đã nộp và cách áp khi thiếu quyền `workflows` |
| [docs/BETA_ACCEPTANCE.md](docs/BETA_ACCEPTANCE.md) | Checklist nghiệm thu beta trên thiết bị |

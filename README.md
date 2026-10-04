# ZenGlish

Ứng dụng Flutter học tiếng Anh trong bối cảnh Theravāda, trí tuệ và thiền tập.

## Tiếp nhận dự án / AI handoff

Bắt đầu từ [AGENTS.md](AGENTS.md). Tài liệu nằm trong repository, không phụ thuộc nhánh tạm hoặc lịch sử chat:

- [Kanban](docs/KANBAN.md): công việc, trạng thái và tiêu chí hoàn thành.
- [Handoff](docs/HANDOFF.md): tình trạng kiểm chứng, blocker và điểm tiếp tục.
- [Plan](docs/IMPLEMENTATION_PLAN.md): phạm vi và thứ tự triển khai.
- [Content audit](docs/CONTENT_AUDIT.md): nguồn bài học, nội dung cần duyệt và backlog audio.
- [PR / release / dọn nhánh](docs/DELIVERY.md): đồng bộ main, build và phát hành APK có thể tải lâu dài.

Agent đọc trên main: xác minh checklist ZEN-013 trong Kanban, sau đó bắt đầu các thẻ kỹ thuật ZEN-001/002/003/016; không checkout nhánh cũ. Trước PR, còn bước ZEN-015 hợp nhất main mới và giữ bản sửa theme.

Các tài liệu và code phải được merge vào main trước khi xóa nhánh chứa thay đổi. Phiên bản `1.0.1-beta.1+2` trong pubspec là bản dự kiến, chưa phải bằng chứng đã có APK/release.

## Hướng triển khai hiện tại

**Offline-first, beta nội bộ Android; ưu tiên kiểm định Việt–Anh.**
Tám bài beta (bốn bài A1 mới nhập còn chờ duyệt) được tải từ `assets/data/lessons/`, hồ sơ và tiến độ lưu trên thiết bị.
Phản hồi luyện tập sử dụng bộ phân tích cục bộ, không phải đánh giá chứng đắc.
AI từ xa bị vô hiệu hóa, kể cả khi truyền `OPENAI_API_KEY` qua build define.
Chưa phát hành lên Play Store/App Store; chưa có đồng bộ tài khoản.

## Thiết lập

- Flutter **3.44.0** (stable) là pin mặc định của CI, khai báo **một chỗ duy nhất**:
  `env.FLUTTER_VERSION_DEFAULT` trong `.github/workflows/quality.yml`; `full_build.yml` và
  `premium_build.yml` nhận lại qua output của quality gate nên không thể lệch pin.
  `pubspec.lock` (Dart `>=3.11.0`) và `pubspec.yaml` (Flutter `>=3.41.0`) đều tương thích
  Dart 3.12.2 đi kèm 3.44.0; PR #4 (run `37219148852`) đã chứng minh analyze + tests + APK debug đạt trên 3.44.0.
  Nếu PR đỏ vì lint/lockfile sau bump: chạy `Quality checks` thủ công với `flutter_version=3.41.4`
  để đối chiếu, lùi một dòng pin đó, rồi resolve `pubspec.lock` riêng (ZEN-002) — không nới gate.
- Android SDK và Java 17 để build Android.
- Không cần khóa API hoặc cấu hình Firebase cho beta offline.

```sh
python3 scripts/validate_content.py
python3 -m unittest discover -s scripts -p 'test_*.py'
flutter --version
flutter pub get
flutter gen-l10n
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test --coverage
flutter run
flutter build apk --debug --target-platform android-arm64
```

Analyzer hiện chặn **errors**; warnings và lint infos là nợ kỹ thuật cần giảm dần.
APK debug chỉ dùng thử nội bộ, không phải gói ký phát hành cho cửa hàng.
Sau lần resolve dependencies thành công, rà soát và lưu thay đổi `pubspec.lock`.

## Cấu trúc

- `lib/presentation/`: giao diện và providers.
- `lib/data/`: models, repository JSON, lưu trữ cục bộ; Firebase là mã dự phòng.
- `lib/ai/`: bộ phân tích phản hồi cục bộ và service từ xa chưa sử dụng trong beta.
- `lib/l10n/*.arb`: nguồn bản dịch; **chỉ sửa bản dịch tại đây**.
- `lib/l10n/app_localizations.dart`: facade ổn định và extension `context.l10n`.
- `lib/l10n/generated/`: do `flutter gen-l10n` sinh, không commit/sửa tay.
- `test/`: kiểm thử models/assets, repository, phản hồi, hồ sơ và widget.

Font tiêu đề Merriweather đóng gói sẵn; nội dung dùng font hệ thống, không tải Google Fonts lúc chạy.
Tám bài hiện chưa có bản thu Input: app đọc bằng **giọng tổng hợp (TTS)** của thiết bị và gắn nhãn rõ ràng; khi có file thu thật trong `audio_url` thì bản thu được ưu tiên tự động. Engine TTS nằm sau interface `SpeechSynthesizer` nên thay được (ví dụ Sherpa-onnx offline) mà không sửa UI.
Màn hình **Thư viện bài học** (`/lessons`) liệt kê toàn bộ bài trong registry; Home chỉ hiển thị bài đề xuất và 4 thẻ trình pháp nhanh.
Xem [báo cáo nội dung và backlog thu âm](docs/CONTENT_AUDIT.md).
Các locale ngoài Việt–Anh còn cần kiểm định bản dịch và tương thích widget/font.

## CI

Bản cập nhật workflow (soạn 18/09, chốt 04/10/2026) nằm ở [PR #4](https://github.com/Pabhassaracitto/zenglish/pull/4) — **chưa merge**. Gate đã chạy thật và xanh trên PR đó: run `37219148852`, 6m48s, trên Flutter 3.44.0 (xem `docs/HANDOFF.md` mục 0 cho chi tiết từng job). Nếu đọc tài liệu này mà chưa thấy workflow mới trên `main` thì gate mới chưa áp dụng cho main: kiểm tra `gh run list --workflow quality.yml`, không suy từ file YAML.

`quality.yml` là quality gate: chạy ngay trên **pull request** vào main, push `main`/`arena/**`, `workflow_dispatch`, và `workflow_call` cho hai workflow đóng gói. Ba job song song/nối tiếp:

1. `Content validator + Python tests` — `validate_content.py` + unittest.
2. `Flutter analyze + tests` — `pub get` (cache theo `pubspec.lock`) → `gen-l10n` → `analyze` (chặn errors) → `flutter test --coverage`, kèm summary log test trong job và artifact `flutter-coverage`.
3. `Android debug APK (ARM64)` — chạy **trên mọi PR và push** (chỉ sau khi job Flutter đạt), cache Gradle, upload artifact `android-offline-beta-debug-<run_id>` (14 ngày) + SHA-256 trong summary để cài thử ngay từ PR. Repo **public** nên phút runner và storage artifact không tính tiền; `main` không bật branch protection. Đo thực tế trên PR #4: job Android 4m21s, APK debug 55.67 MB, cả gate 6m48s (run `37219148852`).

Runner mới nhất của cùng PR thay run cũ (`cancel-in-progress`), mỗi job có `timeout-minutes`. `full_build.yml` chỉ còn manual và phải qua gate; `premium_build.yml` gọi gate trước `prepare`, build chỉ khi gate+prepare thành công, release chỉ khi không build nào fail, và tag `*-beta.*` không kích hoạt nó. Người dùng đã yêu cầu APK thử nghiệm; xem [quy trình beta release](docs/DELIVERY.md), chỉ tạo release có APK đúng commit sau khi build/checks đạt.

## Giới hạn bảo mật và dữ liệu

- Không truyền khóa dịch vụ vào ứng dụng hoặc commit credentials.
- AI online chỉ triển khai sau khi có backend xác thực, hạn mức và chính sách dữ liệu.
- SharedPreferences không phải kho dữ liệu nhạy cảm mã hóa; không nhập thông tin riêng tư vào beta.
- Gỡ ứng dụng/xóa dữ liệu có thể làm mất tiến độ; chưa có backup hoặc cloud sync.

Xem [kế hoạch và tiêu chí nghiệm thu](docs/IMPLEMENTATION_PLAN.md).

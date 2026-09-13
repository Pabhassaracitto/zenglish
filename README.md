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

- Flutter **3.44.0** (stable), dùng cùng phiên bản trong tất cả workflow.
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
Tám bài hiện chưa có bản thu Input; giao diện hỗ trợ đọc nội dung để tiếp tục.
Xem [báo cáo nội dung và backlog thu âm](docs/CONTENT_AUDIT.md).
Các locale ngoài Việt–Anh còn cần kiểm định bản dịch và tương thích widget/font.

## CI

**Đợt push hiện tại không gồm thay đổi workflow, theo yêu cầu người dùng.** Chủ repository sẽ cập nhật thủ công theo [hướng dẫn](docs/WORKFLOW_MANUAL.md). Các mô tả dưới đây là cấu hình **dự kiến sau cập nhật**, không phải xác nhận CI đã chạy. Workflow cũ còn nguyên trên GitHub; chưa tạo tag để tránh kích hoạt chúng ngoài ý muốn.


`quality.yml` chạy trên pull request, push main/arena và theo yêu cầu:
resolve dependencies → sinh bản dịch → analyzer → tests → APK debug → artifact (14 ngày).
Các workflow đóng gói cũ phải qua quality gate. Chỉ `premium_build.yml` còn nhận tag;
`full_build.yml` dành cho build thủ công, tránh hai workflow cùng tạo release theo tag.
Tag `*-beta.*` không kích hoạt premium workflow. Người dùng đã yêu cầu APK thử nghiệm; xem [quy trình beta release](docs/DELIVERY.md), chỉ tạo release có APK đúng commit sau khi build/checks đạt.

## Giới hạn bảo mật và dữ liệu

- Không truyền khóa dịch vụ vào ứng dụng hoặc commit credentials.
- AI online chỉ triển khai sau khi có backend xác thực, hạn mức và chính sách dữ liệu.
- SharedPreferences không phải kho dữ liệu nhạy cảm mã hóa; không nhập thông tin riêng tư vào beta.
- Gỡ ứng dụng/xóa dữ liệu có thể làm mất tiến độ; chưa có backup hoặc cloud sync.

Xem [kế hoạch và tiêu chí nghiệm thu](docs/IMPLEMENTATION_PLAN.md).

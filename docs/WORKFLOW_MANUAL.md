# Workflow — bản cập nhật đã nộp vào repository

Cập nhật **18/09/2026**, chốt phương án **04/10/2026**: chủ dự án yêu cầu agent nộp đúng bộ workflow để test Flutter ngay trên pull request. Ba file đã sửa xong và commit trên nhánh phiên (`ci(quality): chạy Flutter tests + APK debug ngay trên pull request`), nhưng **push bị GitHub từ chối** vì GitHub App của phiên không có quyền `workflows`. Bản cập nhật vì vậy bàn giao bằng patch + ZIP (không commit ZIP vào repo, không tự áp dụng). Chủ repository chọn một trong hai đường:

- **Cấp quyền `workflows`** cho GitHub App / kết nối Arena rồi báo agent push lại và mở PR — checks Flutter chạy ngay trên PR đó; hoặc
- **Tự áp patch**: tạo nhánh từ main, `git am < zenglish-workflows-2026-09-18.patch` (đã kiểm tra apply sạch trên main), push và mở PR. ZIP kèm ba file YAML + `SHA256SUMS.txt` cho ai muốn diff thủ công.

Bảng dưới mô tả đúng nội dung đã commit; **chưa có run Actions nào** chứng minh cấu hình mới đạt. Phần còn lại của tài liệu giữ làm đặc tả lịch sử và hướng review.

Bản đã nộp so với đặc tả cũ:

| Đặc tả cũ | Bản đã nộp | Lý do |
|---|---|---|
| `quality.yml` pin Flutter 3.44.0 | Pin `3.44.0` trong `env.FLUTTER_VERSION_DEFAULT` (một chỗ duy nhất), có input `flutter_version` cho `workflow_dispatch` để thử bản khác | Chủ dự án chốt 3.44.0 cho khớp README/local SDK. Chưa có run xanh cho bản này: nếu analyze hoặc lockfile vỡ sau bump thì lùi đúng một dòng về `3.41.4` (bản đang xanh, run `34786664905`) và xử `pubspec.lock` riêng ở ZEN-002 |
| Java 17 hardcode từng workflow | `env.JAVA_VERSION_DEFAULT` trong `quality.yml`, hai workflow đóng gói nhận `needs.*.outputs.java_version` | Một chỗ đổi pin; job `sdk-pin` fail nếu workflow khác tự hardcode |
| ZIP bàn giao ngoài repo | Không còn ZIP; toàn bộ nằm trong repo, review bằng diff PR | Tránh bàn giao phụ thuộc workspace/phiên cũ |
| Ba workflow độc lập | `full_build.yml` và `premium_build.yml` đều `uses: ./.github/workflows/quality.yml`; build chỉ chạy khi gate + prepare thành công; release khi không build nào fail; tag `!v*-beta.*` loại beta khỏi premium | Đúng tinh thần "không đánh đổi chất lượng để lấy artifact" |
| Không nói tới feedback speed | `concurrency.cancel-in-progress` cho PR, `timeout-minutes` từng job, cache `~/.pub-cache` và `~/.gradle`, summary + coverage + APK artifact ngay trên PR | Mục tiêu "test Flutter ngay khi mở pull request"; job Flutter báo check ở ~2 phút, APK (~6 phút) chạy song song sau đó |
| APK build trên mọi run? | **Giữ**: chạy ở mọi PR/push, upload artifact 14 ngày | Repo public nên phút + storage không tính tiền (chỉ có trần 6h/job và giới hạn concurrency theo tài khoản); `main` không bật branch protection nên không chặn merge. Build là cách duy nhất chứng minh packaging + là nguồn APK cho `docs/DELIVERY.md`. Muốn PR nhẹ hơn thì thêm `if:` chặn theo nhãn — một dòng |

## Đặc tả gốc (13/09/2026)

Người dùng đã yêu cầu push ứng dụng, nội dung và tài liệu trước; **không push thay đổi trong `.github/workflows/`**. Các file workflow cũ trên remote không bị xóa hoặc chỉnh trong commit này.

## Ba file cần cập nhật

1. Thêm `.github/workflows/quality.yml`: pin Flutter 3.44.0, Java 17; chạy Python content validator/tests, pub get, gen-l10n, analyzer, Flutter tests; build APK debug ARM64 và upload artifact 14 ngày. Chạy trên pull request, push main/arena, workflow_dispatch và workflow_call. Chỉ cần quyền contents: read.
2. Sửa `.github/workflows/full_build.yml`: chỉ chạy thủ công, pin cùng Flutter; các build phụ thuộc reusable quality gate, không nhận tag để tránh release trùng.
3. Sửa `.github/workflows/premium_build.yml`: pin cùng Flutter; prepare phụ thuộc quality gate; build chỉ sau prepare thành công; release chỉ sau tất cả build thành công. Loại tag `!v*-beta.*`; beta sẽ được xuất bản riêng với APK đã kiểm tra.

Bản YAML đã soạn được giữ nguyên trong workspace và bàn giao qua `zenglish-workflows-manual.zip`, chứa đúng ba đường dẫn trên và SHA256SUMS.txt. ZIP là tệp bàn giao, không commit vào repository và không tự áp dụng. Nếu không còn ZIP/workspace trong phiên mới, dùng đặc tả trên, AGENTS.md và DELIVERY.md để tái tạo cấu hình rồi review; không dựa vào nhánh cũ.

## Cách cập nhật

- Giải nén, xem diff và dùng tài khoản GitHub có quyền workflow để cập nhật ba file **cùng nhau**. Nên dùng PR riêng vào main; chọn main mới nhất đã có scripts/code của bản beta để workflow không chạy với file còn thiếu.
- Nếu cập nhật trực tiếp trên nhánh ứng dụng, báo agent fetch/merge thay đổi của bạn trước push tiếp. Không ghi đè file bạn đã sửa bằng bản workspace cũ.
- Chạy quality workflow trên commit đã có cả code và workflow mới. Nếu chưa merge code, có thể mở PR workflow sau PR ứng dụng hoặc kết hợp ở bước review; không tuyên bố đã đạt CI khi mới upload YAML.
- Nếu fail dependency/analyzer/tests, lưu log và sửa, không bỏ gate để lấy APK. Lockfile vẫn cần resolve bằng Flutter thực tế.
- Không tạo tag trước khi kiểm tra triggers. Workflow cũ vẫn có thể chạy build đa nền tảng theo tag.
- Chỉ tạo beta release khi có APK build thành công đúng SHA; đính kèm checksum, nhãn debug/pre-release và giới hạn đã biết.

Sau khi cập nhật: ghi commit/PR/run URL thực vào HANDOFF và chuyển ZEN-001/003 theo kết quả. Không coi việc push code thành công là workflow đã được triển khai.

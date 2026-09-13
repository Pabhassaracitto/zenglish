# Workflow — chủ repository cập nhật thủ công

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

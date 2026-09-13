# Đồng bộ main, Pull Request và beta release

Quy trình không phụ thuộc tên nhánh của phiên làm việc. Dùng nhánh hiện tại mà môi trường cho phép; không chuyển nhánh nếu phiên được cố định.

## Quyết định hiện tại: workflow do chủ repository cập nhật

Theo yêu cầu người dùng, push code/tests/docs trước và loại `.github/workflows/` khỏi commit. Không xóa workflow cũ trên remote; giữ bản sửa ở workspace để bàn giao riêng. Xem WORKFLOW_MANUAL.md. Chỉ sau khi chủ repository cập nhật mới dùng hướng dẫn CI/beta bên dưới; hiện chưa có quality gate mới trên remote.

## A. Trước khi mở/cập nhật PR

```sh
git status --short
git branch --show-current
git fetch origin main
git log --oneline HEAD..origin/main
```

Nếu working tree có thay đổi: rà soát và commit công việc cần giữ trước khi merge. Không dùng reset/clean để bỏ thay đổi. Nếu dùng stash, phải phục hồi và giải quyết conflict trước khi tiếp tục.

```sh
git merge --no-edit origin/main
python3 scripts/validate_content.py
python3 -m unittest discover -s scripts -p 'test_*.py' -v
git diff --check
```

`fetch + merge origin/main` nhập main mới nhất vào nhánh làm việc (không phải chuyển sang main). Chạy lại Flutter checks trong AGENTS.md khi SDK có sẵn; ghi rõ những bước chưa chạy. Review code, lockfile, AGENTS, README và docs trước commit.

Push **chỉ nhánh hiện tại được môi trường cho phép**. Sau khi push thành công:

```sh
gh pr list --state open --head "$(git branch --show-current)"
# Nếu chưa có PR:
gh pr create --base main --head "$(git branch --show-current)" \
  --title "Prepare offline Android beta and durable project handoff" \
  --body-file /path/to/prepared-pr-body.md
```

Dùng `.github/pull_request_template.md` để chuẩn bị nội dung, không để placeholder trong PR thật. Nếu đã có PR, cập nhật PR đó thay vì tạo bản trùng.

**Nếu push bị từ chối vì thiếu quyền workflows:** giữ nguyên công việc local, báo chủ dự án sửa quyền GitHub App/kết nối Arena. Không thể coi PR đã được tạo. Không lách quyền qua API khác hoặc bỏ quality gate.

## B. Merge và xóa nhánh

- Chỉ merge khi review và các checks bắt buộc đạt; bảo đảm PR bao gồm tài liệu bàn giao và tests, không chỉ code app.
- Nếu main thay đổi trước merge: đồng bộ lại và chạy checks trên kết quả mới.
- Sau merge: `git fetch origin main`, xác nhận PR ở trạng thái MERGED, đọc `AGENTS.md`/docs và catalog từ main; kiểm tra CI của main.
- Nếu squash merge, dùng merge commit do GitHub trả về, không kiểm tra chỉ bằng commit ID của nhánh cũ.
- Xóa nhánh chỉ là tùy chọn sau bước xác minh. **Đóng PR chưa merge không lưu công việc vào main.**
- Agent trong phiên cố định nhánh không tự xóa nhánh phiên. Chủ repository có thể dọn nhánh sau khi phiên kết thúc và merge đã được xác minh.

## C. Tạo APK beta để người dùng tải

Version dự kiến: `v1.0.1-beta.1`, pubspec `1.0.1-beta.1+2`. Kiểm tra tag/release trước khi tạo; nếu đã xuất bản, dùng beta tiếp theo, không di chuyển tag hoặc ghi đè APK người dùng đã tải.

1. Ưu tiên build từ commit đã merge vào main. Nếu cần beta trước merge, ghi rõ SHA của commit nhánh đã push và phải giữ tag/release; không dùng đường dẫn nhánh làm định danh bản build.
2. Chọn **run thành công đúng SHA**, không chỉ chọn run mới nhất theo thời gian:

```sh
gh run list --workflow quality.yml --limit 10
gh run view RUN_ID --json headSha,conclusion,url
```

3. Tải artifact `android-offline-beta-debug-RUN_ID` vào thư mục tạm ngoài Git. Kiểm tra APK có thật, tính SHA-256. Dùng thư mục và tên chính xác được trả về bởi run.

```sh
gh run download RUN_ID --name android-offline-beta-debug-RUN_ID --dir /tmp/zenglish-beta
# Đổi tên bản sao APK thành zenglish-1.0.1-beta.1-android-arm64-debug.apk.
# Trong thư mục chứa APK:
sha256sum zenglish-1.0.1-beta.1-android-arm64-debug.apk > SHA256SUMS.txt
```

4. Viết release notes: SHA nguồn, run URL, version/build number, ARM64/debug, 8 bài (4 draft), không AI online, chưa có audio Input, các checks thực sự đạt và các mục chờ người dùng test.
5. Khi APK/checksum/notes đều có, tạo tag trên **SHA đúng bản build** và pre-release bằng `gh`:

```sh
gh release create v1.0.1-beta.1 \
  /tmp/zenglish-beta/zenglish-1.0.1-beta.1-android-arm64-debug.apk \
  /tmp/zenglish-beta/SHA256SUMS.txt \
  --target BUILD_COMMIT_SHA --prerelease --latest=false \
  --title "ZenGlish 1.0.1 Beta 1 — Android offline" \
  --notes-file /tmp/zenglish-beta/release-notes.md
```

`RUN_ID`, `BUILD_COMMIT_SHA` là placeholder phải thay bằng giá trị đã xác minh. `gh release create --target` tạo tag nếu chưa tồn tại; không tạo release rỗng khi chưa có APK.

6. Xác minh release qua `gh release view`, kiểm tra assets tải xuống và checksum; ghi URL/SHA/run thật vào HANDOFF/Kanban qua PR. Không đặt APK trong Git.

### Điểm dễ nhầm của CI hiện tại

- `quality.yml` build APK debug và upload artifact **14 ngày**, không xuất bản Release.
- `premium_build.yml` loại tag `*-beta.*`; không tự build/publish beta này. Workflow này dành cho đóng gói đa nền tảng, không phải đường tắt để bỏ qua quality.
- `full_build.yml` chỉ manual. Không đổi beta thành stable tag để kích hoạt tất cả nền tảng.
- Cần tải artifact và gắn APK vào Release trước khi artifact hết hạn, hoặc build lại đúng commit.

## D. Hướng dẫn người dùng thử APK

- Chỉ dành cho Android ARM64; cho phép cài từ nguồn này theo hướng dẫn Android.
- APK debug không phải gói Play Store. Debug keystore giữa các runner có thể khác; cập nhật đè có thể báo lỗi chữ ký. Không bảo người dùng gỡ app mà không cảnh báo **mất tiến độ local**; chưa có export/backup.
- Test lần đầu, placement, CH01–04/đọc email, hoàn thành bài, mở lại và chế độ máy bay. Thiếu audio là giới hạn đã biết, không phải bằng chứng nút phát hoạt động.
- Báo lỗi kèm version, thiết bị/Android, bước tái hiện và ảnh không chứa thông tin riêng tư.

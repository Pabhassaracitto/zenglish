# ZEN-011 — Checklist nghiệm thu bản beta Android (người dùng tự cài)

Dành cho chủ dự án sau khi cài APK `v1.0.1-beta.1` (debug, ARM64). Trả lời ngắn
theo số thứ tự: **Đạt / Không đạt + mô tả**. Mỗi mục "Không đạt" sẽ được chuyển
thành một thẻ Kanban kèm bước tái hiện; thẻ chỉ đóng khi đã sửa và có bằng chứng.

## Trước khi bắt đầu

- Thiết bị: Android ARM64. Cần bật **cài từ nguồn không rõ** cho app dùng để mở
  file APK (Chrome/Files): Cài đặt → Ứng dụng → Truy cập đặc biệt → Cài ứng dụng
  không xác định.
- Đây là **bản debug chưa ký release**: chạy chậm hơn, Play Protect có thể cảnh
  báo. Nếu đã cài bản beta khác, cập nhật đè có thể báo lỗi chữ ký → gỡ rồi cài
  lại, nhưng **gỡ app là mất toàn bộ tiến độ** (chưa có sao lưu/đồng bộ).
- Ghi lại: phiên bản APK, tên máy, phiên bản Android.

## Checklist

1. **Thư viện bài học — đủ 8 bài?**
   Mở Trang chủ → thẻ "Thư viện bài học" (`/lessons`). Đếm xem có đủ **8 bài**:
   A1 CH01, CH02, CH03, CH04, CH05 · A2 CH06, CH07 · B1 CH12. Nếu thiếu, ghi rõ
   thấy bao nhiêu bài và tên những bài hiện ra.

2. **Nghe thử ở phần Input (TTS).**
   Mở một bài bất kỳ → phần Input → nhấn nút nghe.
   - Có phát ra tiếng đọc không?
   - Có thấy nhãn **"giọng tổng hợp"** (máy đọc, không phải bản thu người thật)?
   - Nếu máy thiếu gói giọng tiếng Anh: app báo gì? Chụp lại thông báo đó.
   - Đọc có ngắt quãng/sai ngôn ngữ (đọc tiếng Anh bằng giọng Việt) không?

3. **Tiến độ có được giữ sau khi thoát app?**
   Làm bài kiểm tra xếp lớp (placement) → học xong **1 bài** (bấm "Hoàn Thành
   Bài Học") → thoát hẳn app (vuốt khỏi danh sách ứng dụng) → mở lại.
   - Hồ sơ/trình độ còn không?
   - Bài vừa học có hiển thị **đã hoàn thành** trong thư viện không?
   - Trang chủ có gợi ý **bài kế tiếp** (không để trống) không?
   (Mục này kiểm chứng ZEN-008 — nếu bạn đã cài bản beta trước đó, hãy báo thêm
   là tiến độ cũ còn hay mất sau khi cập nhật.)

4. **Chế độ máy bay.**
   Bật chế độ máy bay → mở lại app: vào được thư viện, mở bài, nghe TTS, hoàn
   thành bài? Ghi lại bất kỳ màn hình lỗi/trống hoặc vòng xoay tải vô hạn nào.

5. **Màn hình nhỏ + cỡ chữ hệ thống lớn.**
   Cài đặt → Hiển thị → Cỡ chữ/Cỡ hiển thị đặt mức lớn nhất, rồi duyệt Trang
   chủ, thư viện, các bước trong bài: có chữ bị cắt, tràn ra ngoài, nút bị che
   hay không bấm được không? Chụp màn hình chỗ lỗi.

6. **Đổi ngôn ngữ Việt ↔ Anh.**
   Đổi ngôn ngữ trong app theo cả hai chiều: nhãn/nút có dịch hết không, có chỗ
   nào còn lẫn ngôn ngữ kia, hay mất chữ sau khi đổi? Đổi xong khởi động lại app
   xem ngôn ngữ có được nhớ không.

## Những điều **đã biết**, không cần báo là lỗi

- Chưa có bản thu giọng người: tất cả 8 bài đọc bằng TTS máy (ZEN-010).
- 4 bài A1 (CH01–CH04) còn cờ `needs_review` — bản nháp chờ người phụ trách nội
  dung duyệt (ZEN-009), không phải giáo trình đã được nghiệm thu.
- Không có đồng bộ đám mây, không có tài khoản, không có AI trực tuyến.
- Bản debug nặng (~55 MB) và chậm hơn bản release.

## Cách báo lỗi để triage nhanh

Với mỗi mục "Không đạt", gửi: **số mục** · bước tái hiện (1-2-3) · kết quả mong
đợi vs thực tế · ảnh chụp màn hình (không chứa thông tin riêng tư) · tên máy +
phiên bản Android.

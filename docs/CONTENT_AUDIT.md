# Rà soát nội dung và âm thanh — 13/09/2026

## Kết quả triển khai

- Bộ beta tăng từ 4 lên **8 bài**, bổ sung A1 chương 1–4 từ TASK_002–TASK_005.
- Không tự viết lại giáo trình hay bỏ điều kiện tiên quyết. Tất cả prerequisite hiện trỏ tới bài có trong assets; không có chu trình.
- Sửa mã `A1CH01_L01` thành `A1_CH01_L01` trong xếp lớp cho người mới.
- Chuẩn hóa `ai_interview_sequence` thành `interview_steps`; giữ lại ghi chú pattern/tình huống trong các trường mà model đọc được.
- Bài A1 chương 4 có email thay vì hội thoại: bổ sung model và giao diện cho `reading_text_en` và `email_structure_note`.
- Bốn bài nhập mới có `needs_review=true`; model lưu/khôi phục cờ này và giao diện Input hiển thị nhãn chờ duyệt.
- Sửa cách đọc `needs_audio`: ưu tiên cờ JSON, fallback về `[NEEDS AUDIO]` của dữ liệu cũ.
- Chưa có bản thu âm mới. Khi thiếu audio, người học được hướng dẫn đọc để tiếp tục; không hứa ngày có bản thu.
- Audio provider xử lý kết quả lỗi trả về từ service thay vì chỉ bắt exception.

## Danh mục thu âm

Cột “cần thu từ vựng” là số mục đang được đánh dấu trong dữ liệu, **không** phải toàn bộ nhu cầu thu âm.
`needs_audio` là việc cần làm, không phải bằng chứng đã có file để phát.

| Mã bài | Nội dung | Từ vựng | Cần thu từ vựng | Bản thu phần Input |
|---|---|---:|---:|---|
| A1_CH01_L01 | How I Found the Dhamma | 10 | 4 | Chưa có |
| A1_CH02_L01 | Arriving at the Monastery | 10 | 2 | Chưa có |
| A1_CH03_L01 | Daily Life at the Monastery | 10 | 0 | Chưa có |
| A1_CH04_L01 | Registering for a Retreat | 10 | 0 | Chưa có |
| A1_CH05_L01 | Health and Personal Needs at the Monastery | 12 | 1 | Chưa có |
| A2_CH06_L01 | Ānāpāna — Reporting Your Breath Meditation | 4 | 4 | Chưa có |
| A2_CH07_L01 | Five Precepts & Eight Precepts — Reporting Your Practice | 10 | 5 | Chưa có |
| B1_CH12_L01 | The 5-Part Meditation Interview Report (Core) | 10 | 5 | Chưa có |

## Thứ tự sản xuất âm thanh đề xuất

1. Duyệt văn bản Việt–Anh và cách phát âm Pāli trước khi thu.
2. Thu phần Input A1 chương 1–3; chương 4 ưu tiên bài đọc email, không bắt buộc có audio để học.
3. Thu chương 5, rồi hai bài A2 và bài B1; bổ sung các từ vựng được đánh dấu.
4. Quyết định giọng đọc và quyền sử dụng bản thu; không gắn nhãn bản thu thật cho audio tổng hợp.
5. Đặt file trong `assets/audio/`, khai báo thư mục trong pubspec, gán `audio_url` cho Input.
   Validator chặn file không tồn tại và URL từ xa trong catalog offline.
6. Nghe nghiệm thu trên Android, kiểm tra chế độ im lặng, pause/resume và chuyển bài.

## Hạng mục chờ người phụ trách nội dung duyệt

- Mức độ A1 của câu kể quá khứ, email và mẫu diễn đạt kinh nghiệm thiền.
- Phát âm/phiên âm các từ dukkha, kuṭi, dāna và thuật ngữ khác.
- Các nhận định theo từng thiền viện về giờ ăn, thủ tục, cách gọi phòng ở; không coi tập quán một nơi là quy tắc chung.
- Email chương 4 là **văn bản mẫu luyện tập**; chưa có bằng chứng đây là thư thực tế.
- Độ phù hợp phản hồi cục bộ cho bài giao tiếp/đăng ký: bộ phân tích hiện thiên về trình pháp.
- Tính nhất quán giữa bài đề xuất sau placement và thứ tự học/fast-track. Sửa mã bài không đồng nghĩa đã nghiệm thu chính sách mở khóa.

## Kiểm tra đã chạy

- `python3 scripts/validate_content.py`: đạt, 8 bài; registry, nội dung tối thiểu, prerequisite, mã routing và tham chiếu audio.
- `python3 -m unittest discover -s scripts -p 'test_*.py' -v`: **7/7 đạt**, gồm kiểm tra prerequisite thiếu/vòng lặp, audio thiếu/từ xa, bài đọc thiếu và registry sai.
- `git diff --check`: đạt.
- Đã thêm kiểm thử Dart cho round-trip bài đọc, cờ audio/review và routing tới assets; **chưa chạy** vì Flutter/Dart SDK chưa sẵn sàng.
- Chưa nghiệm thu phát âm, bản dịch, UI trên thiết bị hoặc build APK.

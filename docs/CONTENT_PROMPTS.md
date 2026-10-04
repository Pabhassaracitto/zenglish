# Prompt mở rộng nội dung học đa ngôn ngữ

## Quyết định giai đoạn hiện tại

Tám bài hiện tại được giữ làm mốc beta và có thể duyệt trước. Không dịch máy hàng loạt
trước khi khóa schema, kiểm tra sư phạm và kiểm định font. Ưu tiên hoàn thiện Việt–Anh;
Trung, Sinhala (Sri Lanka), Myanmar và Hindi đưa vào **pilot nội dung**, không chặn bản web.

## Prompt cho người biên soạn

> Bạn là biên tập viên nội dung cho ZenGlish, ứng dụng học tiếng Anh trong bối cảnh
> Theravāda, trí tuệ và thiền tập. Hãy tạo **một bài học A1/A2** theo schema JSON đang
> dùng trong `assets/data/lessons/`, giữ nguyên các trường và kiểu dữ liệu của bài mẫu.
> Ngôn ngữ học là tiếng Anh; ngôn ngữ hỗ trợ của người học là **[ZH / SI / MY / HI]**.
> Mỗi bài cần có: mục tiêu đo được, 8–12 từ vựng, 3–5 câu hội thoại tự nhiên, một hoạt
> động nghe–nhận biết, nối từ và tự nói. Câu tiếng Anh ngắn, đúng trình độ, có IPA khi
> phù hợp. Dịch nghĩa phải được người bản ngữ kiểm tra, không dịch từng chữ.
>
> Bối cảnh được dùng: chào hỏi tại thiền viện, xin phép, lịch thiền, giới luật căn bản,
> hỏi đường trong khuôn viên và phục vụ cộng đồng. Không khẳng định người học đã chứng
> đắc, không pha trộn thuật ngữ Pāḷi nếu không giải thích, không đưa giáo lý gây tranh cãi.
> Chỉ dùng nội dung an toàn, tôn trọng các truyền thống Theravāda.
>
> Đầu ra gồm: (1) JSON hợp lệ, không markdown; (2) bảng kiểm tra bản dịch [ngôn ngữ]
> → tiếng Anh; (3) ghi chú những chỗ cần người duyệt chuyên môn. Không tự thêm trường
> mới, không dùng `audio_url` giả, không lặp lại ví dụ giữa các bài. Đánh dấu `needs_review`
> nếu còn điểm cần duyệt.

## Thứ tự triển khai đề xuất

1. Khóa 8 bài beta đã duyệt và sửa các lỗi blocker UI/audio.
2. Biên soạn 4 bài bổ sung bằng Việt–Anh trước (mỗi chương 2 bài), rồi kiểm tra trên
   màn hình nhỏ, cỡ chữ lớn và web.
3. Chọn 2 bài A1 để pilot đồng thời cho ZH, SI, MY, HI; kiểm định bản dịch với người
   bản ngữ trước khi mở rộng.
4. Chỉ sau khi pilot ổn định mới thêm audio thu thật và nội dung A2/B1.

Mục tiêu hợp lý không phải “chỉ có 8 bài”, mà là một thư viện tăng dần theo chương,
trong đó mỗi bài có mục tiêu riêng và được duyệt trước khi phát hành.

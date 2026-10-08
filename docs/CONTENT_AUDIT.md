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

## Chính sách âm thanh — cập nhật 04/10/2026

Chủ dự án chốt: **bài nào chưa có bản thu thì đọc bằng giọng tổng hợp (TTS); khi có file thu thật thì app tự ưu tiên bản thu.**

- Thứ tự ưu tiên do `resolveInputAudio()` (`lib/data/services/input_audio_resolver.dart`) quyết định:
  1. `lesson_flow.input.audio_url` có giá trị → phát bản thu (asset hoặc URL).
  2. Chưa có → đọc `reading_text_en`, nếu không có thì ghép `sample_dialogues` (đã bỏ nhãn người nói).
  3. Không có cả hai → giữ thông báo cũ, người học đọc văn bản để tiếp tục.
- Thêm `audio_url` vào JSON là đủ để chuyển sang bản thu, **không phải sửa code**.
- UI luôn gắn nhãn "Giọng đọc tổng hợp của thiết bị (TTS)" khi không dùng bản thu — không được trình bày giọng máy như bản thu của vị thầy.
- Engine hiện tại là TTS của hệ điều hành qua `flutter_tts`, phụ thuộc gói giọng người dùng đã cài. Nếu thiếu, app báo cách cài và vẫn cho đọc văn bản.
- Dự án đa ngôn ngữ: `SpeechSynthesizer` là interface, đổi sang engine offline đóng gói (ví dụ Sherpa-onnx kế thừa từ dự án khác của chủ dự án) chỉ cần `SpeechService.overrideWith(...)`, không đụng tới UI.

Chưa nghiệm thu: chất lượng phát âm Pāḷi bằng TTS, tốc độ đọc, hành vi khi tắt màn hình, và dung lượng APK sau khi thêm `flutter_tts`.

## Lựa chọn nguồn giọng đọc — phân tích cho quyết định ZEN-010 (05/10/2026)

Câu hỏi của chủ dự án: dùng **Sherpa-onnx đọc trên máy** hay **xuất văn bản rồi
nhờ TTS chất lượng cao (Grok, Google AI Studio/Gemini TTS…) tạo file sẵn**?

| Tiêu chí | File dựng sẵn từ TTS chất lượng cao | Sherpa-onnx chạy trên máy |
|---|---|---|
| Chất lượng nghe | Cao nhất; nghe lại và chỉnh từng câu trước khi phát hành | Khá, thua TTS đám mây; phụ thuộc model |
| Phát âm Pāḷi (kuṭi, dukkha, dāna) | **Nghe kiểm tra được từng file**, sai thì tạo lại | Không kiểm soát trước, sai là sai với mọi người dùng |
| Offline | Có (file nằm trong assets) | Có |
| Dung lượng app | ~0,3–1 MB/bài đọc (Opus/AAC 48–64 kbps) → 8 bài vài MB | Model TTS 20–100 MB+/giọng, nhân cho mỗi ngôn ngữ |
| Chi phí vận hành | Một lần, lúc sản xuất | Không |
| Nội dung động (câu người học tự nhập, từ vựng mới) | Không phủ được | Phủ được |
| Pháp lý | **Phải đọc ToS**: quyền phân phối lại audio sinh ra trong app; ghi rõ "giọng tổng hợp", không gán cho một vị thầy | Model có giấy phép riêng (Apache/CC), tự chủ hoàn toàn |

**Khuyến nghị:** 8 bài hiện tại là **nội dung tĩnh, số lượng nhỏ** → nên **xuất
văn bản rồi dựng file bằng TTS chất lượng cao**, đặt vào `assets/audio/` và gán
`audio_url`; app đã tự ưu tiên bản thu nên **không phải sửa code**. Giữ
`flutter_tts` (giọng hệ điều hành) làm fallback cho máy chưa tải xong/nội dung
chưa có file. Chỉ chuyển sang **Sherpa-onnx khi cần đọc văn bản động** (đọc câu
người học viết, từ vựng mở rộng, nhiều ngôn ngữ) — khi đó chỉ cần
`SpeechService.overrideWith(...)`, không đụng UI.

Việc cần làm nếu chọn hướng file dựng sẵn: (1) chốt một giọng/một tốc độ cho cả
bộ; (2) kiểm tra ToS của nhà cung cấp về phân phối lại; (3) nghe soát riêng các
từ Pāḷi; (4) nén Opus/AAC mono 24 kHz; (5) thêm file + `audio_url`, chạy
validator (validator chặn file không tồn tại và URL từ xa).

## Thứ tự sản xuất âm thanh đề xuất

1. Duyệt văn bản Việt–Anh và cách phát âm Pāli trước khi thu.
2. Thu phần Input A1 chương 1–3; chương 4 ưu tiên bài đọc email, không bắt buộc có audio để học.
3. Thu chương 5, rồi hai bài A2 và bài B1; bổ sung các từ vựng được đánh dấu.
4. Quyết định giọng đọc và quyền sử dụng bản thu; không gắn nhãn bản thu thật cho audio tổng hợp.
5. Đặt file trong `assets/audio/`, khai báo thư mục trong pubspec, gán `audio_url` cho Input.
   Validator chặn file không tồn tại và URL từ xa trong catalog offline.
6. Nghe nghiệm thu trên Android, kiểm tra chế độ im lặng, pause/resume và chuyển bài.

## Khả năng truy cập nội dung trên giao diện — 04/10/2026

Chủ dự án báo trong app chỉ thấy 4 mục (Ānāpāna, Giới, 5 Phần, Sức khoẻ). Đối chiếu mã nguồn:

- `assets/data/lessons/` **vẫn đủ 8 bài** và `validate_content.py` đạt — không phải mất nội dung.
- Bốn mục đó là `_QuickCardGrid` hardcode trong `lib/presentation/screens/home/components/ai_interview_quick_start.dart`.
- Trước bản sửa này **không màn hình nào gọi `loadAllLessons()`**; Home chỉ hiển thị một bài đề xuất, nên A1 chương 1–4 không có đường vào trừ khi placement route đúng vào đó.
- Đã bổ sung màn hình `/lessons` (`LessonCatalogScreen`) đọc thẳng từ repository: thêm bài vào registry là bài tự hiện, kèm nhãn "chờ duyệt", "giọng tổng hợp" và gợi ý bài tiên quyết.

## Duyệt nội dung — 05/10/2026 (ZEN-009)

**Chủ dự án đã duyệt nội dung bài đọc của 4 bản nháp A1 (CH01–CH04).** Cờ
`needs_review` trong 4 file JSON được đặt `false`, `needs_review_note` ghi lại
ngày và phạm vi duyệt. Agent **không** tự quyết định việc này — đây là quyết
định của người phụ trách nội dung, ghi ngày 05/10/2026.

**Chưa được duyệt bởi quyết định này:** giọng đọc và quyền sử dụng bản thu
(ZEN-010), chất lượng phát âm Pāḷi khi đọc bằng máy, và chính sách mở khoá bài
học. Các điểm dưới đây giữ nguyên để tham chiếu khi nội dung được sửa tiếp.

## Hạng mục chờ người phụ trách nội dung duyệt (danh sách gốc, đã duyệt ngày 05/10 với 4 bài A1)

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

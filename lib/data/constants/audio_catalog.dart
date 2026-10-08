// lib/data/constants/audio_catalog.dart
//
// Danh mục audio dựng sẵn cho các bài học (kết quả của hướng đi
// "file dựng sẵn bằng TTS chất lượng cao" — ZEN-010, docs/CONTENT_AUDIT.md).
//
// Toàn bộ file được host tại dataset Hugging Face `Beyou8778/zenglish-audio`.
// Quy ước đặt tên: `<LESSON_ID>_input_<NN>.mp3`
//   ví dụ: A1_CH01_L01_input_01.mp3
//
// Quy tắc runtime (xem `input_audio_resolver.dart`):
//   1. File bundle trong `assets/audio/` khi build          → phát trực tiếp.
//   2. File người học đã tải về bộ nhớ app (AudioDownloadService) → phát trực tiếp.
//   3. Chưa có local                                          → stream từ URL bên
//      dưới và hiện nút "Tải audio" để lưu về máy.
//
// Các file này là giọng tổng hợp (AI) nên UI phải giữ nhãn "giọng tổng hợp".
// Khi đội nội dung có bản thu thật của con người, gán `audio_url` trong lesson
// JSON (validator bắt buộc file bundle) — bản thu thật luôn được ưu tiên hơn
// danh mục này và không gắn nhãn AI.

/// Một file audio trong danh mục từ xa.
class RemoteAudioFile {
  const RemoteAudioFile({
    required this.lessonId,
    required this.fileName,
    required this.estimatedBytes,
  });

  /// ID bài học sở hữu file, ví dụ `A1_CH01_L01`.
  final String lessonId;

  /// Tên file trên Hugging Face, ví dụ `A1_CH01_L01_input_01.mp3`.
  final String fileName;

  /// Dung lượng ước tính (bytes) để hiển thị trước khi tải.
  /// Khi tải thật, HEAD request sẽ lấy Content-Length chính xác nếu server
  /// trả về; con số này chỉ dùng cho màn hình "ước tính dung lượng".
  final int estimatedBytes;

  /// Đường dẫn nếu file được bundle kèm app khi build.
  String get bundledAssetPath => 'assets/audio/$fileName';

  /// Link tải trực tiếp từ Hugging Face.
  String get remoteUrl => '${AudioCatalog.huggingFaceBaseUrl}$fileName';
}

/// Danh mục tập trung — nguồn sự thật duy nhất về audio từ xa.
///
/// Thêm file mới: thêm một [RemoteAudioFile] vào [files], tuân thủ quy ước
/// đặt tên; `scripts/validate_content.py` sẽ kiểm tra convention này.
abstract final class AudioCatalog {
  /// Base URL của dataset Hugging Face (dạng resolve để lấy file trực tiếp).
  static const String huggingFaceBaseUrl =
      'https://huggingface.co/datasets/Beyou8778/zenglish-audio/resolve/main/';

  /// ~1,5 MB/file — ước tính dè dặt cho bản TTS dài ~1-2 phút.
  /// Được validator kiểm tra > 0; UI luôn ghi rõ đây là ước tính.
  static const int _estimatedInputClipBytes = 1500000;

  /// Tất cả file audio đã biết, theo thứ tự bài học trong registry.
  static const List<RemoteAudioFile> files = [
    // ── Foundation (A1) ───────────────────────────────────────
    RemoteAudioFile(
      lessonId: 'A1_CH01_L01',
      fileName: 'A1_CH01_L01_input_01.mp3',
      estimatedBytes: _estimatedInputClipBytes,
    ),
    RemoteAudioFile(
      lessonId: 'A1_CH02_L01',
      fileName: 'A1_CH02_L01_input_01.mp3',
      estimatedBytes: _estimatedInputClipBytes,
    ),
    RemoteAudioFile(
      lessonId: 'A1_CH03_L01',
      fileName: 'A1_CH03_L01_input_01.mp3',
      estimatedBytes: _estimatedInputClipBytes,
    ),
    RemoteAudioFile(
      lessonId: 'A1_CH04_L01',
      fileName: 'A1_CH04_L01_input_01.mp3',
      estimatedBytes: _estimatedInputClipBytes,
    ),
    // ── Chapter 05 (A1) ───────────────────────────────────────
    RemoteAudioFile(
      lessonId: 'A1_CH05_L01',
      fileName: 'A1_CH05_L01_input_01.mp3',
      estimatedBytes: _estimatedInputClipBytes,
    ),
    // ── Chapter 06 (A2) ───────────────────────────────────────
    RemoteAudioFile(
      lessonId: 'A2_CH06_L01',
      fileName: 'A2_CH06_L01_input_01.mp3',
      estimatedBytes: _estimatedInputClipBytes,
    ),
    // ── Chapter 07 (A2) ───────────────────────────────────────
    RemoteAudioFile(
      lessonId: 'A2_CH07_L01',
      fileName: 'A2_CH07_L01_input_01.mp3',
      estimatedBytes: _estimatedInputClipBytes,
    ),
    // ── Chapter 12 (B1) ───────────────────────────────────────
    RemoteAudioFile(
      lessonId: 'B1_CH12_L01',
      fileName: 'B1_CH12_L01_input_01.mp3',
      estimatedBytes: _estimatedInputClipBytes,
    ),
  ];

  /// Toàn bộ tên file trong danh mục (độ dài = số file).
  static List<String> get allFileNames =>
      files.map((f) => f.fileName).toList(growable: false);

  /// Các file thuộc một bài học (theo thứ tự khai báo).
  static List<RemoteAudioFile> filesForLesson(String lessonId) => files
      .where((f) => f.lessonId == lessonId)
      .toList(growable: false);

  /// Dung lượng ước tính để tải đủ audio của một bài.
  static int estimatedBytesForLesson(String lessonId) =>
      filesForLesson(lessonId).fold(0, (sum, f) => sum + f.estimatedBytes);

  /// Dung lượng ước tính của toàn bộ danh mục.
  static int get estimatedBytesTotal =>
      files.fold(0, (sum, f) => sum + f.estimatedBytes);

  /// Tên file có thuộc danh mục AI này không?
  ///
  /// Dùng để quyết định nhãn "giọng tổng hợp": file theo quy ước của danh mục
  /// là giọng AI; `audio_url` ngoài danh mục được coi là bản thu con người.
  static bool isCatalogFileName(String fileName) =>
      files.any((f) => f.fileName == fileName);

  /// Regex quy ước đặt tên — validator Python kiểm tra cùng quy tắc này.
  static final RegExp fileNamePattern =
      RegExp(r'^([A-C][12]_CH\d+_L\d+)_input_\d{2}\.mp3$');

  /// true nếu [fileName] tuân thủ quy ước `<LESSON_ID>_input_<NN>.mp3`.
  static bool followsFileNameConvention(String lessonId, String fileName) {
    final match = fileNamePattern.firstMatch(fileName);
    return match != null && match.group(1) == lessonId;
  }
}

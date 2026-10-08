// lib/data/services/input_audio_resolver.dart

import '../constants/audio_catalog.dart';
import '../models/lesson.dart';

/// Nguồn âm thanh được chọn cho phần Input của một bài học.
enum InputAudioMode {
  /// Có bản thu/file audio thật (asset, file đã tải hoặc URL) — ưu tiên tuyệt
  /// đối so với giọng tổng hợp của thiết bị.
  recording,

  /// Chưa có file audio nào → đọc bằng giọng tổng hợp (TTS) của thiết bị.
  synthesized,

  /// Không có file audio và cũng không có văn bản để đọc.
  none,
}

/// Nguồn cụ thể mà [InputAudioPlan] sẽ phát — UI dựa vào đây để quyết định
/// có hiện nút "Tải audio" hay không.
enum InputAudioOrigin {
  /// File bundle sẵn trong `assets/audio/` khi build app.
  bundledAsset,

  /// File người học đã tải về bộ nhớ app trước đó.
  downloadedFile,

  /// Chưa có local — sẽ stream từ Hugging Face; UI nên mời tải về.
  remoteUrl,

  /// Giọng tổng hợp (TTS) của thiết bị — chỉ dùng khi danh mục không có file.
  deviceTts,

  /// Không có gì để phát.
  none,
}

/// Kết quả tra cứu các nguồn audio **local** tại thời điểm hiển thị bài học.
///
/// Tách khỏi resolver để resolver giữ nguyên là hàm thuần, kiểm thử được mà
/// không cần filesystem hay asset bundle thật.
class LocalAudioLookup {
  const LocalAudioLookup({
    this.bundled = const {},
    this.downloaded = const {},
  });

  /// File bundle kèm app: `fileName` → đường dẫn asset (`assets/audio/...`).
  final Map<String, String> bundled;

  /// File đã tải về máy: `fileName` → đường dẫn tuyệt đối trên thiết bị.
  final Map<String, String> downloaded;

  static const LocalAudioLookup empty = LocalAudioLookup();

  bool get isEmpty => bundled.isEmpty && downloaded.isEmpty;
}

/// Kế hoạch phát âm thanh cho phần Input.
///
/// Logic được tách khỏi UI để kiểm thử được bằng `flutter test` mà không cần
/// thiết bị hay engine TTS thật.
class InputAudioPlan {
  const InputAudioPlan({
    required this.mode,
    this.sources = const [],
    this.text,
    this.language = 'en-US',
    this.origin = InputAudioOrigin.none,
    this.remoteFiles = const [],
    this.isAiGenerated = false,
  });

  final InputAudioMode mode;

  /// Danh sách đường dẫn asset / đường dẫn file / URL sẽ phát theo thứ tự.
  /// Chỉ có khi [mode] là [InputAudioMode.recording].
  final List<String> sources;

  /// Văn bản để đọc — chỉ có khi [mode] là [InputAudioMode.synthesized].
  final String? text;

  /// BCP-47 của văn bản cần đọc. Nội dung Input hiện là tiếng Anh.
  final String language;

  /// Nguồn thực tế được chọn — UI dựa vào đây để hiện nút tải.
  final InputAudioOrigin origin;

  /// Các file cần tải khi [origin] là [InputAudioOrigin.remoteUrl].
  final List<RemoteAudioFile> remoteFiles;

  /// true nếu audio là giọng tổng hợp (AI hoặc TTS) — UI phải gắn nhãn
  /// "giọng tổng hợp" để minh bạch với người học.
  final bool isAiGenerated;

  /// Nguồn đầu tiên — tiện cho code cũ và test chỉ quan tâm 1 file.
  String? get source => sources.isEmpty ? null : sources.first;

  bool get hasRecording => mode == InputAudioMode.recording;
  bool get isSynthesized => mode == InputAudioMode.synthesized;
  bool get canPlay => mode != InputAudioMode.none;

  /// true nếu phát từ file có sẵn trên máy (bundle hoặc đã tải) —
  /// không cần mạng, không cần nút tải.
  bool get isLocal =>
      origin == InputAudioOrigin.bundledAsset ||
      origin == InputAudioOrigin.downloadedFile;

  /// true nếu sẽ stream từ xa — UI nên mời người học tải về máy.
  bool get needsDownload => origin == InputAudioOrigin.remoteUrl;

  /// Khoá nhận diện nguồn đang phát (để toggle play/pause đúng nguồn).
  String get playbackKey => sources.join('|');
}

/// Quy tắc ưu tiên (mở rộng 07/10/2026 — audio Hugging Face):
///
/// 1. `lesson_flow.input.audio_url` có giá trị → dùng **bản thu/file được gán
///    tường minh** trong lesson JSON (validator bắt buộc là file bundle).
///    Bản thu thật luôn thắng danh mục audio AI.
/// 2. Bài có file trong [AudioCatalog] (host trên Hugging Face):
///    a. File đã bundle trong `assets/audio/` khi build → phát từ asset.
///    b. File đã được người học tải về máy → phát từ file local.
///    c. Chưa có local → stream URL Hugging Face + mời tải về.
///    Audio trong danh mục là giọng AI nên [InputAudioPlan.isAiGenerated]
///    luôn true (UI giữ nhãn "giọng tổng hợp").
/// 3. Bài ngoài danh mục → đọc bằng **giọng tổng hợp** của thiết bị nếu có
///    văn bản (`reading_text_en` / `sample_dialogues`), nhãn rõ ràng trên UI.
/// 4. Không có gì → UI hướng dẫn người học tự đọc, không chặn tiến độ.
InputAudioPlan resolveInputAudio(
  Lesson lesson, {
  String language = 'en-US',
  LocalAudioLookup? localAudio,
}) {
  final lookup = localAudio ?? LocalAudioLookup.empty;
  final input = lesson.lessonFlow.input;

  // ── 1. audio_url tường minh trong lesson JSON ─────────────────────────────
  final explicit = input.audioUrl?.trim();
  if (explicit != null && explicit.isNotEmpty) {
    // File theo quy ước danh mục (dù bundle hay URL) vẫn là giọng AI;
    // audio_url ngoài danh mục được coi là bản thu con người.
    final isAi = AudioCatalog.isCatalogFileName(_basename(explicit));
    return InputAudioPlan(
      mode: InputAudioMode.recording,
      sources: [explicit],
      origin: (explicit.startsWith('http://') || explicit.startsWith('https://'))
          ? InputAudioOrigin.remoteUrl
          : InputAudioOrigin.bundledAsset,
      isAiGenerated: isAi,
      language: language,
    );
  }

  // ── 2. Danh mục audio AI trên Hugging Face ────────────────────────────────
  final files = AudioCatalog.filesForLesson(lesson.lessonId);
  if (files.isNotEmpty) {
    // Ưu tiên local: chỉ phát local khi **tất cả** file của bài đã có trên
    // máy, tránh playlist nửa local nửa remote.
    final localSources = <String>[];
    var allLocal = true;
    for (final file in files) {
      final local =
          lookup.bundled[file.fileName] ?? lookup.downloaded[file.fileName];
      if (local == null) {
        allLocal = false;
        break;
      }
      localSources.add(local);
    }

    if (allLocal) {
      final allBundled =
          localSources.every((s) => s.startsWith('assets/'));
      return InputAudioPlan(
        mode: InputAudioMode.recording,
        sources: localSources,
        origin: allBundled
            ? InputAudioOrigin.bundledAsset
            : InputAudioOrigin.downloadedFile,
        isAiGenerated: true,
        language: language,
      );
    }

    return InputAudioPlan(
      mode: InputAudioMode.recording,
      sources: files.map((f) => f.remoteUrl).toList(growable: false),
      origin: InputAudioOrigin.remoteUrl,
      remoteFiles: files,
      isAiGenerated: true,
      language: language,
    );
  }

  // ── 3. Ngoài danh mục → TTS thiết bị / không có gì ────────────────────────
  final text = buildInputSpeechText(lesson);
  if (text.isEmpty) {
    return const InputAudioPlan(mode: InputAudioMode.none);
  }

  return InputAudioPlan(
    mode: InputAudioMode.synthesized,
    text: text,
    language: language,
    origin: InputAudioOrigin.deviceTts,
    isAiGenerated: true,
  );
}

/// Ghép văn bản tiếng Anh của phần Input thành một đoạn đọc liền mạch.
///
/// Ưu tiên bài đọc (`reading_text_en`, ví dụ email chương 4); nếu không có
/// thì ghép các dòng hội thoại mẫu.
String buildInputSpeechText(Lesson lesson) {
  final input = lesson.lessonFlow.input;

  final reading = input.readingTextEn?.trim();
  if (reading != null && reading.isNotEmpty) {
    return reading;
  }

  final lines = <String>[];
  for (final dialogue in input.sampleDialogues) {
    for (final line in dialogue.lines) {
      final cleaned = _stripSpeakerLabel(line).trim();
      if (cleaned.isNotEmpty) lines.add(cleaned);
    }
  }

  return lines.join('\n');
}

/// Bỏ nhãn người nói ("Bhante: ...", "Yogi — ...") để TTS không đọc tên vai.
///
/// Chỉ cắt khi nhãn ngắn và không chứa dấu câu kết thúc, tránh cắt nhầm
/// những câu có dấu hai chấm ở giữa.
String _stripSpeakerLabel(String line) {
  final match = RegExp(r'^\s*([^:.!?]{1,24}):\s+(.*)$').firstMatch(line);
  if (match != null) {
    return match.group(2) ?? line;
  }
  return line;
}

/// Lấy tên file từ đường dẫn/URL (không phụ thuộc package `path`).
String _basename(String source) {
  final cleaned = source.replaceFirst('asset:///', '');
  final slash = cleaned.lastIndexOf('/');
  return slash >= 0 ? cleaned.substring(slash + 1) : cleaned;
}

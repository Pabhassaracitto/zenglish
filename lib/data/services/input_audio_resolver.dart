// lib/data/services/input_audio_resolver.dart

import '../models/lesson.dart';

/// Nguồn âm thanh được chọn cho phần Input của một bài học.
enum InputAudioMode {
  /// Có bản thu thật trong assets (hoặc URL) — ưu tiên tuyệt đối.
  recording,

  /// Chưa có bản thu → đọc bằng giọng tổng hợp (TTS).
  synthesized,

  /// Không có bản thu và cũng không có văn bản để đọc.
  none,
}

/// Kế hoạch phát âm thanh cho phần Input.
///
/// Logic được tách khỏi UI để kiểm thử được bằng `flutter test` mà không cần
/// thiết bị hay engine TTS thật.
class InputAudioPlan {
  const InputAudioPlan({
    required this.mode,
    this.source,
    this.text,
    this.language = 'en-US',
  });

  final InputAudioMode mode;

  /// Đường dẫn asset hoặc URL — chỉ có khi [mode] là [InputAudioMode.recording].
  final String? source;

  /// Văn bản để đọc — chỉ có khi [mode] là [InputAudioMode.synthesized].
  final String? text;

  /// BCP-47 của văn bản cần đọc. Nội dung Input hiện là tiếng Anh.
  final String language;

  bool get hasRecording => mode == InputAudioMode.recording;
  bool get isSynthesized => mode == InputAudioMode.synthesized;
  bool get canPlay => mode != InputAudioMode.none;
}

/// Quy tắc ưu tiên:
///
/// 1. `lesson_flow.input.audio_url` có giá trị → dùng **bản thu thật**.
///    Khi đội nội dung bổ sung file thu âm, app tự chuyển sang bản thu mà
///    không cần sửa code.
/// 2. Chưa có bản thu nhưng có `reading_text_en` hoặc `sample_dialogues`
///    → đọc bằng **giọng tổng hợp**, có nhãn rõ ràng trên UI.
/// 3. Không có gì → UI hướng dẫn người học tự đọc, không chặn tiến độ.
InputAudioPlan resolveInputAudio(Lesson lesson, {String language = 'en-US'}) {
  final input = lesson.lessonFlow.input;

  final source = input.audioUrl?.trim();
  if (source != null && source.isNotEmpty) {
    return InputAudioPlan(
      mode: InputAudioMode.recording,
      source: source,
      language: language,
    );
  }

  final text = buildInputSpeechText(lesson);
  if (text.isEmpty) {
    return const InputAudioPlan(mode: InputAudioMode.none);
  }

  return InputAudioPlan(
    mode: InputAudioMode.synthesized,
    text: text,
    language: language,
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

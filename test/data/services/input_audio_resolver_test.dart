import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenglish/data/constants/lesson_asset_registry.dart';
import 'package:zenglish/data/models/lesson.dart';
import 'package:zenglish/data/services/input_audio_resolver.dart';

Future<Lesson> _load(String path) async {
  final json = jsonDecode(await rootBundle.loadString(path))
      as Map<String, dynamic>;
  return Lesson.fromJson(json);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bài chưa có bản thu thì chuyển sang giọng tổng hợp, không bị bỏ trống',
      () async {
    for (final path in LessonAssetRegistry.allPaths) {
      final lesson = await _load(path);
      final plan = resolveInputAudio(lesson);

      final audioUrl = lesson.lessonFlow.input.audioUrl;
      if (audioUrl != null && audioUrl.isNotEmpty) {
        expect(plan.mode, InputAudioMode.recording, reason: path);
        expect(plan.source, audioUrl, reason: path);
      } else {
        // Toàn bộ bài beta hiện chưa có bản thu → phải đọc được bằng TTS.
        expect(plan.mode, InputAudioMode.synthesized, reason: path);
        expect(plan.text, isNotEmpty, reason: path);
        expect(plan.canPlay, isTrue, reason: path);
      }
    }
  });

  test('bản thu thật luôn được ưu tiên hơn giọng tổng hợp', () async {
    final lesson = await _load(LessonAssetRegistry.allPaths.first);
    final withAudio = Lesson.fromJson({
      ...lesson.toJson(),
      'lesson_flow': {
        ...lesson.lessonFlow.toJson(),
        'input': {
          ...lesson.lessonFlow.input.toJson(),
          'audio_url': 'assets/audio/demo.mp3',
        },
      },
    });

    final plan = resolveInputAudio(withAudio);
    expect(plan.mode, InputAudioMode.recording);
    expect(plan.source, 'assets/audio/demo.mp3');
    expect(plan.isSynthesized, isFalse);
  });

  test('văn bản đọc bỏ nhãn người nói nhưng giữ nội dung câu', () async {
    final lesson = await _load(LessonAssetRegistry.allPaths.first);
    final text = buildInputSpeechText(lesson);

    expect(text, isNotEmpty);
    for (final line in text.split('\n')) {
      expect(line.trim(), isNotEmpty);
    }
  });
}

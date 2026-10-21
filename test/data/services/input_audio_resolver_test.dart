import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenglish/data/constants/audio_catalog.dart';
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

  test('chưa có local: ưu tiên stream Hugging Face và mời tải về', () async {
    for (final path in LessonAssetRegistry.allPaths) {
      final lesson = await _load(path);
      final plan = resolveInputAudio(lesson);

      expect(plan.mode, InputAudioMode.recording, reason: path);
      expect(plan.origin, InputAudioOrigin.remoteUrl, reason: path);
      expect(plan.isLocal, isFalse, reason: path);
      expect(plan.needsDownload, isTrue, reason: path);
      expect(plan.isAiGenerated, isTrue, reason: path);
      expect(plan.remoteFiles, isNotEmpty, reason: path);
      for (final source in plan.sources) {
        expect(
          source,
          startsWith(AudioCatalog.huggingFaceBaseUrl),
          reason: path,
        );
      }
    }
  });

  test('file bundle trong assets/audio thắng link Hugging Face', () async {
    final lesson = await _load(LessonAssetRegistry.allPaths.first);
    final fileName =
        AudioCatalog.filesForLesson(lesson.lessonId).first.fileName;
    final lookup = LocalAudioLookup(
      bundled: {fileName: 'assets/audio/$fileName'},
    );

    final plan = resolveInputAudio(lesson, localAudio: lookup);

    expect(plan.mode, InputAudioMode.recording);
    expect(plan.origin, InputAudioOrigin.bundledAsset);
    expect(plan.sources, ['assets/audio/$fileName']);
    expect(plan.isLocal, isTrue);
    expect(plan.needsDownload, isFalse);
    // File trong danh mục AI vẫn phải gắn nhãn giọng tổng hợp.
    expect(plan.isAiGenerated, isTrue);
  });

  test('file đã tải về máy thắng link Hugging Face', () async {
    final lesson = await _load(LessonAssetRegistry.allPaths.first);
    final fileName =
        AudioCatalog.filesForLesson(lesson.lessonId).first.fileName;
    final lookup = LocalAudioLookup(
      downloaded: {fileName: '/data/app/zenglish_audio/$fileName'},
    );

    final plan = resolveInputAudio(lesson, localAudio: lookup);

    expect(plan.mode, InputAudioMode.recording);
    expect(plan.origin, InputAudioOrigin.downloadedFile);
    expect(plan.sources, ['/data/app/zenglish_audio/$fileName']);
    expect(plan.needsDownload, isFalse);
    expect(plan.isAiGenerated, isTrue);
  });

  test('file bundle vẫn được ưu tiên hơn file đã tải', () async {
    final lesson = await _load(LessonAssetRegistry.allPaths.first);
    final fileName =
        AudioCatalog.filesForLesson(lesson.lessonId).first.fileName;
    final lookup = LocalAudioLookup(
      bundled: {fileName: 'assets/audio/$fileName'},
      downloaded: {fileName: '/data/app/zenglish_audio/$fileName'},
    );

    final plan = resolveInputAudio(lesson, localAudio: lookup);

    expect(plan.origin, InputAudioOrigin.bundledAsset);
    expect(plan.sources, ['assets/audio/$fileName']);
  });

  test('audio_url tường minh (bản thu thật) vẫn được ưu tiên nhất', () async {
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
    expect(plan.needsDownload, isFalse);
    // Ngoài danh mục AI → coi là bản thu con người, không gắn nhãn AI.
    expect(plan.isAiGenerated, isFalse);
  });

  test('bài ngoài danh mục audio → fallback giọng tổng hợp của thiết bị',
      () async {
    final base = await _load(LessonAssetRegistry.allPaths.first);
    final renamed = Lesson.fromJson({
      ...base.toJson(),
      'lesson_id': 'C2_CH99_L01',
    });

    final plan = resolveInputAudio(renamed);

    expect(plan.mode, InputAudioMode.synthesized);
    expect(plan.origin, InputAudioOrigin.deviceTts);
    expect(plan.text, isNotEmpty);
    expect(plan.canPlay, isTrue);
    expect(plan.isAiGenerated, isTrue);
  });

  test('văn bản đọc bỏ nhãn người nói nhưng giữ nội dung câu', () async {
    final lesson = await _load(LessonAssetRegistry.allPaths.first);
    final text = buildInputSpeechText(lesson);

    expect(text, isNotEmpty);
    for (final line in text.split('\n')) {
      expect(line.trim(), isNotEmpty);
    }
  });

  test('số file audio khớp số đoạn Input của từng bài', () async {
    for (final path in LessonAssetRegistry.allPaths) {
      final lesson = await _load(path);
      final dialogues = lesson.lessonFlow.input.sampleDialogues;
      final expected = dialogues.isNotEmpty ? dialogues.length : 1;
      expect(
        AudioCatalog.filesForLesson(lesson.lessonId).length,
        expected,
        reason: lesson.lessonId,
      );
    }
  });

  test('plan phát đúng file của hội thoại đang xem (hội thoại 2/2)', () async {
    Lesson? twoDialogues;
    for (final path in LessonAssetRegistry.allPaths) {
      final lesson = await _load(path);
      if (lesson.lessonFlow.input.sampleDialogues.length == 2) {
        twoDialogues = lesson;
        break;
      }
    }
    expect(twoDialogues, isNotNull,
        reason: 'cần ít nhất một bài có 2 hội thoại mẫu');
    final lesson = twoDialogues!;

    final first = resolveInputAudio(lesson, dialogueIndex: 0);
    final second = resolveInputAudio(lesson, dialogueIndex: 1);

    expect(first.sources, hasLength(1));
    expect(first.sources.single, endsWith('_input_01.mp3'));
    expect(second.sources, hasLength(1));
    expect(second.sources.single, endsWith('_input_02.mp3'));
    // Nút tải vẫn tải trọn bài (cả hai file).
    expect(second.remoteFiles, hasLength(2));
  });

  test('hội thoại 2 dùng file đã tải riêng của nó, không cần đủ cả bài',
      () async {
    Lesson? found;
    for (final path in LessonAssetRegistry.allPaths) {
      final lesson = await _load(path);
      if (lesson.lessonFlow.input.sampleDialogues.length == 2) {
        found = lesson;
        break;
      }
    }
    final lesson = found!;
    final secondFile =
        AudioCatalog.filesForLesson(lesson.lessonId)[1].fileName;
    final lookup = LocalAudioLookup(
      downloaded: {secondFile: '/data/app/zenglish_audio/$secondFile'},
    );

    final plan = resolveInputAudio(
      lesson,
      localAudio: lookup,
      dialogueIndex: 1,
    );

    expect(plan.origin, InputAudioOrigin.downloadedFile);
    expect(plan.sources, ['/data/app/zenglish_audio/$secondFile']);
    expect(plan.needsDownload, isFalse);
  });

  test('bài đọc CH04 dùng file _input_reading', () async {
    Lesson? reading;
    for (final path in LessonAssetRegistry.allPaths) {
      final lesson = await _load(path);
      if (lesson.lessonFlow.input.sampleDialogues.isEmpty) {
        reading = lesson;
        break;
      }
    }
    expect(reading, isNotNull);
    final plan = resolveInputAudio(reading!);
    expect(plan.sources.single, endsWith('_input_reading.mp3'));
  });

  test('TTS ngoài danh mục chỉ đọc hội thoại đang xem', () async {
    Lesson? found;
    for (final path in LessonAssetRegistry.allPaths) {
      final lesson = await _load(path);
      if (lesson.lessonFlow.input.sampleDialogues.length == 2) {
        found = lesson;
        break;
      }
    }
    final base = found!;
    final renamed = Lesson.fromJson({
      ...base.toJson(),
      'lesson_id': 'C2_CH99_L01',
    });

    final plan = resolveInputAudio(renamed, dialogueIndex: 1);

    expect(plan.mode, InputAudioMode.synthesized);
    expect(
      plan.text,
      buildDialogueSpeechText(base.lessonFlow.input.sampleDialogues[1]),
    );
    expect(plan.text, isNot(buildInputSpeechText(base)));
  });
}

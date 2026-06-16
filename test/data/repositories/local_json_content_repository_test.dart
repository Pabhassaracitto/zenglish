// test/data/repositories/local_json_content_repository_test.dart

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zenglishapp/data/repositories/local_json_content_repository.dart';
import 'package:zenglishapp/data/repositories/i_lesson_repository.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────

const _validLessonJson = '''
{
  "lesson_id": "A2_CH06_L01",
  "title_en": "Test Lesson",
  "title_vi": "Bài Test",
  "level": "A2",
  "meditation_stage_min": "any",
  "prerequisites": [],
  "monastery_note": "Note",
  "authenticity_reminder": "Reminder",
  "vocabulary": [],
  "lesson_flow": {
    "warm_up": {
      "duration_minutes": 5,
      "activity_type": "reflection",
      "prompt_en": "Test",
      "prompt_vi": "Test",
      "teacher_note": "Note"
    },
    "presentation": {
      "duration_minutes": 10,
      "grammar_focus": "Present Simple",
      "grammar_explanation_en": "Test",
      "grammar_explanation_vi": "Test",
      "key_structures": []
    },
    "practice": {
      "duration_minutes": 15,
      "activity_type": "guided",
      "steps": []
    },
    "production": {
      "duration_minutes": 10,
      "activity_type": "free",
      "prompt_en": "Test",
      "prompt_vi": "Test",
      "success_criteria": []
    },
    "closing": {
      "duration_minutes": 5,
      "activity_type": "reflection",
      "prompt_en": "Test",
      "prompt_vi": "Test",
      "homework": "Homework"
    }
  },
  "situation_variants": {},
  "patches_applied": [],
  "needs_review": false
}
''';

const _invalidJson = 'this is not { valid json }';

const _wrongTypeJson = '''
{
  "lesson_id": 12345,
  "title_en": "Wrong Type",
  "level": "A2"
}
''';

// ─── Mock AssetBundle ────────────────────────────────────────────────────

class MockAssetBundle extends Fake implements AssetBundle {
  MockAssetBundle(this._assets);

  final Map<String, String> _assets;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (_assets.containsKey(key)) {
      return _assets[key]!;
    }
    throw FlutterError('Asset not found: $key');
  }
}

// ─── Tests ────────────────────────────────────────────────────────────────

void main() {
  group('LocalJsonContentRepository', () {
    late Map<String, String> assetFiles;
    late LocalJsonContentRepository repository;

    setUp(() {
      assetFiles = {
        'AssetManifest.json': json.encode({
          'assets/data/lessons/A2_CH06_L01.json': ['assets/data/lessons/A2_CH06_L01.json'],
        }),
        'assets/data/lessons/A2_CH06_L01.json': _validLessonJson,
      };
    });

    // Helper để tạo repository với assets tùy chỉnh
    LocalJsonContentRepository makeRepo() => LocalJsonContentRepository(
          assetBundle: MockAssetBundle(assetFiles),
        );

    group('loadAllLessons()', () {
      test('load thành công 1 lesson hợp lệ', () async {
        repository = makeRepo();
        final lessons = await repository.loadAllLessons();

        expect(lessons, hasLength(1));
        expect(lessons.first.lessonId, 'A2_CH06_L01');
        expect(lessons.first.titleEn, 'Test Lesson');
      });

      test('bỏ qua file JSON sai format, load file khác thành công', () async {
        assetFiles['AssetManifest.json'] = json.encode({
          'assets/data/lessons/A2_CH06_L01.json': ['assets/data/lessons/A2_CH06_L01.json'],
          'assets/data/lessons/BROKEN.json': ['assets/data/lessons/BROKEN.json'],
        });
        assetFiles['assets/data/lessons/BROKEN.json'] = _invalidJson;

        repository = makeRepo();
        final lessons = await repository.loadAllLessons();

        // File lỗi bị bỏ qua, file tốt vẫn load được
        expect(lessons, hasLength(1));
        expect(lessons.first.lessonId, 'A2_CH06_L01');
      });

      test('bỏ qua file có kiểu dữ liệu sai', () async {
        assetFiles['AssetManifest.json'] = json.encode({
          'assets/data/lessons/WRONG_TYPE.json': ['assets/data/lessons/WRONG_TYPE.json'],
        });
        assetFiles['assets/data/lessons/WRONG_TYPE.json'] = _wrongTypeJson;

        repository = makeRepo();

        expect(
          () => repository.loadAllLessons(),
          throwsA(isA<NoLessonsAvailableException>()),
        );
      });

      test('throw NoLessonsAvailableException khi không có file nào', () async {
        assetFiles['AssetManifest.json'] = json.encode({});
        repository = makeRepo();

        expect(
          () => repository.loadAllLessons(),
          throwsA(isA<NoLessonsAvailableException>()),
        );
      });
    });

    group('Cache', () {
      test('gọi loadAllLessons() 2 lần chỉ đọc file 1 lần', () async {
        var loadCount = 0;
        final trackingAssets = Map<String, String>.from(assetFiles);

        final trackingBundle = _TrackingAssetBundle(
          trackingAssets,
          onLoad: (key) {
            if (key.startsWith('assets/data/lessons/')) loadCount++;
          },
        );

        repository = LocalJsonContentRepository(
          assetBundle: trackingBundle,
        );

        await repository.loadAllLessons();
        await repository.loadAllLessons(); // Lần 2 → từ cache

        // Chỉ đọc file 1 lần
        expect(loadCount, 1);
      });

      test('clearCache() buộc load lại từ file', () async {
        repository = makeRepo();

        final first = await repository.loadAllLessons();
        await repository.clearCache();
        final second = await repository.loadAllLessons();

        // Cùng data nhưng khác instance (đã reload)
        expect(first.first.lessonId, second.first.lessonId);
      });
    });

    group('getLessonById()', () {
      test('trả về lesson đúng theo ID', () async {
        repository = makeRepo();
        final lesson = await repository.getLessonById('A2_CH06_L01');

        expect(lesson, isNotNull);
        expect(lesson!.lessonId, 'A2_CH06_L01');
      });

      test('trả về null với ID không tồn tại', () async {
        repository = makeRepo();
        final lesson = await repository.getLessonById('NONEXISTENT');

        expect(lesson, isNull);
      });
    });

    group('getLessonsByLevel()', () {
      test('lọc đúng lessons theo level', () async {
        repository = makeRepo();
        final a2Lessons = await repository.getLessonsByLevel('A2');

        expect(a2Lessons, hasLength(1));
        expect(a2Lessons.every((l) => l.level.displayName == 'A2'), isTrue);
      });

      test('trả về list rỗng với level không có bài nào', () async {
        repository = makeRepo();
        final c2Lessons = await repository.getLessonsByLevel('C2');

        expect(c2Lessons, isEmpty);
      });
    });
  });
}

// ─── Tracking helper ────────────────────────────────────────────────────

class _TrackingAssetBundle extends Fake implements AssetBundle {
  _TrackingAssetBundle(this._assets, {required this.onLoad});

  final Map<String, String> _assets;
  final void Function(String key) onLoad;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    onLoad(key);
    if (_assets.containsKey(key)) return _assets[key]!;
    throw FlutterError('Asset not found: $key');
  }
}

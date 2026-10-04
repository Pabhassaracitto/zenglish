import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenglish/core/enums/cefr_level.dart';
import 'package:zenglish/core/enums/meditation_stage.dart';
import 'package:zenglish/data/constants/lesson_asset_registry.dart';
import 'package:zenglish/data/models/lesson.dart';
import 'package:zenglish/data/models/user_profile.dart';
import 'package:zenglish/presentation/providers/catalog_provider.dart';

Future<List<Lesson>> _loadAll() async {
  final lessons = <Lesson>[];
  for (final path in LessonAssetRegistry.allPaths) {
    final json =
        jsonDecode(await rootBundle.loadString(path)) as Map<String, dynamic>;
    lessons.add(Lesson.fromJson(json));
  }
  return lessons;
}

UserProfile _profile({
  List<String> completed = const [],
  List<String> inProgress = const [],
}) {
  return UserProfile(
    userId: 'test',
    displayName: 'Tester',
    languageLevel: CEFRLevel.a1,
    meditationStage: MeditationStage.any,
    paliKnowledgeLevel: 0,
    completedLessonIds: completed,
    inProgressLessonIds: inProgress,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('thư viện hiển thị toàn bộ bài trong registry, không chỉ 4 quick-start',
      () async {
    final lessons = await _loadAll();
    final catalog = buildCatalog(lessons, null);

    expect(catalog.total, LessonAssetRegistry.allPaths.length);
    expect(catalog.total, greaterThanOrEqualTo(8));

    final ids = catalog.entries.map((e) => e.lesson.lessonId).toSet();
    // Bốn bài A1 nhập từ TASK trước đây không có đường vào từ giao diện.
    expect(ids, containsAll(<String>[
      'A1_CH01_L01',
      'A1_CH02_L01',
      'A1_CH03_L01',
      'A1_CH04_L01',
    ]));
  });

  test('nhóm theo level và sắp xếp A1 trước A2/B1', () async {
    final lessons = await _loadAll();
    final catalog = buildCatalog(lessons, null);

    final levels = catalog.byLevel.keys.toList();
    final sortedLevels = [...levels]
      ..sort((a, b) => a.index.compareTo(b.index));
    expect(levels, sortedLevels);
    expect(levels.first, CEFRLevel.a1);
  });

  test('trạng thái hoàn thành và bài tiên quyết còn thiếu được tính đúng',
      () async {
    final lessons = await _loadAll();
    final catalog = buildCatalog(
      lessons,
      _profile(
        completed: const ['A1_CH01_L01'],
        inProgress: const ['A1_CH02_L01'],
      ),
    );

    final first = catalog.entries
        .firstWhere((e) => e.lesson.lessonId == 'A1_CH01_L01');
    final second = catalog.entries
        .firstWhere((e) => e.lesson.lessonId == 'A1_CH02_L01');

    expect(first.status, LessonProgressStatus.completed);
    expect(second.status, LessonProgressStatus.inProgress);
    expect(catalog.completedCount, 1);
    expect(first.missingPrerequisites, isNot(contains('A1_CH01_L01')));

    // Bài tiên quyết đã hoàn thành thì không còn nằm trong danh sách thiếu.
    for (final entry in catalog.entries) {
      expect(entry.missingPrerequisites, isNot(contains('A1_CH01_L01')));
    }
  });

  test('bài chưa có bản thu được đánh dấu dùng giọng tổng hợp', () async {
    final lessons = await _loadAll();
    final catalog = buildCatalog(lessons, null);

    expect(
      catalog.entries.where((e) => e.usesSynthesizedVoice).length,
      catalog.total,
      reason: 'Hiện chưa bài nào có bản thu Input',
    );
  });

  test('ZEN-008: hoàn thành bài gợi ý vẫn còn bài kế tiếp (Home không trống)',
      () async {
    final lessons = await _loadAll();
    final all = buildCatalog(lessons, null).entries;
    final firstId = all.first.lesson.lessonId;

    final catalog = buildCatalog(lessons, _profile(completed: [firstId]));
    final next = resolveNextEntry(catalog, suggestedId: firstId);

    expect(next, isNotNull);
    expect(next!.lesson.lessonId, isNot(firstId));
    expect(next.status, LessonProgressStatus.notStarted);
  });

  test('ZEN-008: bài đang học dở được ưu tiên hơn gợi ý của ContentRouter',
      () async {
    final lessons = await _loadAll();
    final catalog = buildCatalog(
      lessons,
      _profile(inProgress: const ['A1_CH03_L01']),
    );

    final next = resolveNextEntry(catalog, suggestedId: 'A1_CH01_L01');
    expect(next!.lesson.lessonId, 'A1_CH03_L01');
  });

  test('ZEN-008: hoàn thành toàn bộ thư viện → không còn bài kế tiếp',
      () async {
    final lessons = await _loadAll();
    final allIds = lessons.map((l) => l.lessonId).toList();
    final catalog = buildCatalog(lessons, _profile(completed: allIds));

    expect(resolveNextEntry(catalog, suggestedId: allIds.first), isNull);
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenglish/data/constants/lesson_asset_registry.dart';
import 'package:zenglish/data/models/lesson.dart';
import 'package:zenglish/logic/content_router.dart';
import 'package:zenglish/data/repositories/local_json_content_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registry includes every bundled lesson exactly once', () {
    final files = Directory('assets/data/lessons')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .map((file) => file.path.replaceAll('\\', '/'))
        .toSet();
    expect(LessonAssetRegistry.allPaths.toSet(), files);
    expect(LessonAssetRegistry.allPaths.toSet().length,
        LessonAssetRegistry.allPaths.length);
  });

  test('every registered asset parses and survives a model round trip', () async {
    final ids = <String>{};
    for (final path in LessonAssetRegistry.allPaths) {
      final json = jsonDecode(await rootBundle.loadString(path))
          as Map<String, dynamic>;
      final lesson = Lesson.fromJson(json);
      expect(ids.add(lesson.lessonId), isTrue, reason: path);
      expect(lesson.titleEn, isNotEmpty, reason: path);
      expect(lesson.lessonFlow.input.title, isNotEmpty, reason: path);
      expect(lesson.lessonFlow.output.promptForUser, isNotEmpty, reason: path);
      final restored = Lesson.fromJson(lesson.toJson());
      expect(restored.lessonId, lesson.lessonId);
      expect(restored.needsReview, json['needs_review'] ?? false);
      expect(restored.needsReviewNote, json['needs_review_note']);
      expect(restored.lessonFlow.input.readingTextEn,
          json['lesson_flow']['input']['reading_text_en']);
      for (var i = 0; i < lesson.vocabulary.length; i++) {
        expect(restored.vocabulary[i].needsAudio, lesson.vocabulary[i].needsAudio);
      }
    }
    for (final id in RoutingTable.allCombinations.values) {
      expect(ids, contains(id), reason: 'Placement must point to a bundled lesson');
    }
    final repository = LocalJsonContentRepository(
      lessonAssetPaths: LessonAssetRegistry.allPaths,
    );
    final lessons = await repository.loadAllLessons();
    expect(lessons, hasLength(ids.length));
    for (final lesson in lessons) {
      for (final prerequisite in lesson.prerequisites) {
        expect(ids, contains(prerequisite), reason: lesson.lessonId);
      }
    }
  });
}

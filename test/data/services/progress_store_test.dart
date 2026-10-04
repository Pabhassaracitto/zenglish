import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenglish/core/enums/cefr_level.dart';
import 'package:zenglish/core/enums/meditation_stage.dart';
import 'package:zenglish/data/models/user_profile.dart';
import 'package:zenglish/data/services/progress_store.dart';

UserProfile _profile({
  List<String> completed = const [],
  List<String> inProgress = const [],
}) {
  return UserProfile(
    userId: 'u1',
    displayName: 'Learner',
    languageLevel: CEFRLevel.a1,
    meditationStage: MeditationStage.any,
    paliKnowledgeLevel: 0,
    completedLessonIds: completed,
    inProgressLessonIds: inProgress,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ZEN-008: migration dựng lại hồ sơ từ các key legacy', () async {
    SharedPreferences.setMockInitialValues({
      'has_user_profile': true,
      'user_id': 'beta_user',
      'display_name': 'Beta',
      'language_level': 'A2',
      'meditation_stage': 'preRetreat',
      'pali_knowledge_level': 2,
      'completed_lesson_ids': <String>['A1_CH01_L01'],
      'in_progress_lesson_ids': <String>['A1_CH02_L01'],
    });
    final prefs = await SharedPreferences.getInstance();
    final store = ProgressStore(prefs);

    expect(await store.migrateIfNeeded(), isTrue);

    final profile = store.read();
    expect(profile, isNotNull);
    expect(profile!.displayName, 'Beta');
    expect(profile.languageLevel, CEFRLevel.a2);
    expect(profile.completedLessonIds, ['A1_CH01_L01']);
    expect(profile.inProgressLessonIds, ['A1_CH02_L01']);

    // Key legacy đã được dọn và migration không chạy lại.
    expect(prefs.getBool('has_user_profile'), isNull);
    expect(await store.migrateIfNeeded(), isFalse);
  });

  test('ZEN-008: hai kho cùng có dữ liệu → hợp nhất, không mất tiến độ',
      () async {
    SharedPreferences.setMockInitialValues({
      'userprofile': jsonEncode(
        _profile(completed: ['A1_CH01_L01'], inProgress: ['A1_CH03_L01'])
            .toJson(),
      ),
      'has_user_profile': true,
      'user_id': 'u1',
      'display_name': 'Learner',
      'language_level': 'A1',
      'meditation_stage': 'any',
      'completed_lesson_ids': <String>['A1_CH02_L01', 'A1_CH03_L01'],
      'in_progress_lesson_ids': <String>['A1_CH04_L01'],
    });
    final store = ProgressStore(await SharedPreferences.getInstance());

    await store.migrateIfNeeded();

    final profile = store.read()!;
    expect(
      profile.completedLessonIds.toSet(),
      {'A1_CH01_L01', 'A1_CH02_L01', 'A1_CH03_L01'},
    );
    // Bài đã hoàn thành không còn nằm trong danh sách đang học.
    expect(profile.inProgressLessonIds, ['A1_CH04_L01']);
  });

  test('ZEN-008: dữ liệu hỏng được backup, app không kẹt', () async {
    SharedPreferences.setMockInitialValues({'userprofile': '{broken'});
    final prefs = await SharedPreferences.getInstance();
    final store = ProgressStore(prefs);

    expect(store.read(), isNull);
    await store.migrateIfNeeded();

    expect(prefs.getString(ProgressStore.corruptBackupKey), '{broken');
    expect(prefs.getString(ProgressStore.canonicalKey), isNull);
    expect(store.hasProfile, isFalse);
  });

  test('ZEN-008: hoàn thành bài ghi một lần, bỏ khỏi danh sách đang học',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = ProgressStore(prefs);
    await store.write(_profile());

    await store.markLessonInProgress('A1_CH01_L01');
    expect(store.read()!.inProgressLessonIds, ['A1_CH01_L01']);

    await store.markLessonCompleted('A1_CH01_L01');
    await store.markLessonCompleted('A1_CH01_L01');

    // Đọc lại từ prefs = mô phỏng restart app.
    final afterRestart = ProgressStore(prefs).read()!;
    expect(afterRestart.completedLessonIds, ['A1_CH01_L01']);
    expect(afterRestart.inProgressLessonIds, isEmpty);

    await store.clear();
    expect(prefs.getString(ProgressStore.canonicalKey), isNull);
  });
}

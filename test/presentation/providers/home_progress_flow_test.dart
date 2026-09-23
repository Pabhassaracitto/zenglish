// test/presentation/providers/home_progress_flow_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenglish/core/enums/cefr_level.dart';
import 'package:zenglish/core/enums/meditation_stage.dart';
import 'package:zenglish/core/providers/user_profile_provider.dart';
import 'package:zenglish/data/di/repository_provider.dart';
import 'package:zenglish/data/models/user_profile.dart';
import 'package:zenglish/data/services/user_session_service.dart';
import 'package:zenglish/presentation/providers/home_provider.dart';

/// ZEN-008 — tiến độ chỉ đi qua MỘT nguồn lưu trữ.
///
/// Chu trình được kiểm ở đây: placement lưu profile → Home đọc thấy →
/// còn bài học dở thì tiếp tục → hoàn thành bài thì gợi ý bài kế tiếp →
/// mở lại app (container mới) vẫn còn tiến độ → reset đưa về onboarding.
///
/// Test này fail trên phiên bản cũ: Home đọc `UserSessionService`
/// (key `has_user_profile` không ai ghi) nên `userProfile` luôn null,
/// dù `userProfileProvider` đã lưu profile thành công.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  ProviderContainer createContainer() => ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

  UserProfile buildProfile({
    List<String> completed = const [],
    List<String> inProgress = const [],
    CEFRLevel level = CEFRLevel.a1,
    MeditationStage stage = MeditationStage.any,
  }) {
    return UserProfile(
      userId: 'offline-test',
      displayName: 'Learner',
      languageLevel: level,
      meditationStage: stage,
      paliKnowledgeLevel: 0,
      completedLessonIds: completed,
      inProgressLessonIds: inProgress,
    );
  }

  Future<HomeState> homeStateAfterInit(ProviderContainer container) async {
    await container.read(homeProvider.notifier).init();
    return container.read(homeProvider);
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await UserSessionService.instance.init();
    RepositoryProvider.reset();
  });

  tearDown(() => RepositoryProvider.reset());

  test('profile saved by placement is visible to Home', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container
        .read(userProfileProvider.notifier)
        .saveProfile(buildProfile());

    final state = await homeStateAfterInit(container);
    expect(state.error, isNull);
    expect(state.hasProfile, isTrue,
        reason: 'Home phải đọc được đúng profile mà placement đã lưu');
    expect(state.userProfile?.displayName, 'Learner');
    expect(state.greeting, contains('Learner'));
    expect(state.nextLesson?.lessonId, 'A1_CH01_L01');
  });

  test('a lesson in progress wins over the router suggestion', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(userProfileProvider.notifier).saveProfile(
          buildProfile(inProgress: ['A1_CH03_L01']),
        );

    final state = await homeStateAfterInit(container);
    expect(state.nextLesson?.lessonId, 'A1_CH03_L01');
  });

  test('completing a lesson advances the suggestion and survives restart',
      () async {
    final first = createContainer();
    addTearDown(first.dispose);
    final notifier = first.read(userProfileProvider.notifier);

    await notifier.saveProfile(buildProfile());
    await first.read(homeProvider.notifier).init();
    expect(first.read(homeProvider).nextLesson?.lessonId, 'A1_CH01_L01');

    await notifier.markLessonCompleted('A1_CH01_L01');
    await first.read(homeProvider.notifier).refresh();
    expect(first.read(homeProvider).nextLesson?.lessonId, 'A1_CH02_L01',
        reason: 'CH02 đã mở khoá sau khi xong CH01; không được trả về null');

    final restarted = createContainer();
    addTearDown(restarted.dispose);
    final restored = await homeStateAfterInit(restarted);
    expect(restored.userProfile?.completedLessonIds, ['A1_CH01_L01']);
    expect(restored.nextLesson?.lessonId, 'A1_CH02_L01');
  });

  test('reset clears the profile so the learner returns to onboarding',
      () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(userProfileProvider.notifier).saveProfile(
          buildProfile(completed: ['A1_CH01_L01']),
        );
    expect(container.read(hasUserProfileProvider), isTrue);

    // Đúng thứ tự mà HomeHeader đang làm khi người dùng bấm reset
    await UserSessionService.instance.clearSession();
    await container.read(userProfileProvider.notifier).clearProfile();

    expect(prefs.getString('userprofile'), isNull);
    expect(await container.read(userProfileProvider.future), isNull);
    expect(container.read(hasUserProfileProvider), isFalse);

    final state = await homeStateAfterInit(container);
    expect(state.hasProfile, isFalse);
    expect(state.hasNextLesson, isFalse);
  });
}

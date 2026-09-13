import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenglish/core/enums/cefr_level.dart';
import 'package:zenglish/core/enums/meditation_stage.dart';
import 'package:zenglish/core/providers/user_profile_provider.dart';
import 'package:zenglish/data/models/user_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('completion persists across provider restarts without duplicate IDs', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    ProviderContainer createContainer() => ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ]);
    final first = createContainer();
    addTearDown(first.dispose);
    expect(await first.read(userProfileProvider.future), isNull);
    final notifier = first.read(userProfileProvider.notifier);
    await notifier.saveProfile(const UserProfile(
      userId: 'offline-test', displayName: 'Learner',
      languageLevel: CEFRLevel.a1, meditationStage: MeditationStage.any,
      paliKnowledgeLevel: 0, completedLessonIds: [],
      inProgressLessonIds: [],
    ));
    await notifier.markLessonCompleted('A1_CH05_L01');
    await notifier.markLessonCompleted('A1_CH05_L01');

    final restarted = createContainer();
    addTearDown(restarted.dispose);
    final restored = await restarted.read(userProfileProvider.future);
    expect(restored?.completedLessonIds, ['A1_CH05_L01']);
    await restarted.read(userProfileProvider.notifier).clearProfile();
    expect(prefs.getString('userprofile'), isNull);
  });

  test('corrupted profile safely returns to onboarding', () async {
    SharedPreferences.setMockInitialValues({'userprofile': '{broken'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ]);
    addTearDown(container.dispose);
    expect(await container.read(userProfileProvider.future), isNull);
  });
}

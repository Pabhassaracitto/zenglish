// ============================================================
// PROVIDER: Lesson data & Smart Suggestion logic
// ============================================================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_profile.dart';
import '../../models/lesson.dart';
import '../../models/user_profile.dart';
import 'user_profile_provider.dart';

// ── Mock lesson repository (thay bằng API/Firestore sau) ──
final lessonRepositoryProvider = Provider<List<Lesson>>((ref) {
  return mockLessons;
});

// ── Smart Suggestion: Tính bài học phù hợp nhất ──
final suggestedLessonProvider = Provider<Lesson?>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final lessons = ref.watch(lessonRepositoryProvider);

  if (profile == null || lessons.isEmpty) return null;

  // Scoring algorithm: match 3 trục
  Lesson? bestLesson;
  int bestScore = -1;

  for (final lesson in lessons) {
    int score = 0;

    // Trục 1: English Level match (±1 level)
    final levelDiff = (lesson.targetLevel.index - profile.englishLevel.index).abs();
    if (levelDiff == 0) {
      score += 3;      // Perfect match
    } else if (levelDiff == 1) {
      score += 2; // Một bậc
    } else if (levelDiff == 2) {
      score += 1; // Hai bậc
    } else {
      score -= 1;                      // Quá xa
    }

    // Trục 2: Meditation Experience match
    if (lesson.suitableFor.contains(profile.meditationExperience)) {
      score += 2;
    }

    // Trục 3: Pali content match
    if (lesson.hasPaliContent && profile.paliLevel != PaliLevel.none) {
      score += 1;
    }
    if (!lesson.hasPaliContent && profile.paliLevel == PaliLevel.none) {
      score += 1;
    }

    if (score > bestScore) {
      bestScore = score;
      bestLesson = lesson;
    }
  }

  return bestLesson;
});

// ── Mock Data ──
final mockLessons = <Lesson>[
  const Lesson(
    id: 'lesson_001',
    title: 'The Art of Mindful Breathing',
    titlePali: 'Ānāpānasati',
    description: 'Learn vocabulary and phrases used when explaining breath meditation to English-speaking practitioners.',
    type: LessonType.vocabulary,
    difficulty: LessonDifficulty.beginner,
    targetLevel: EnglishLevel.a2,
    suitableFor: [MeditationExperience.none, MeditationExperience.beginner],
    estimatedMinutes: 15,
    tags: ['breathing', 'basic', 'vipassana'],
    iconAsset: 'assets/icons/breath.svg',
    content: {'words': [], 'exercises': []},
    hasPaliContent: true,
  ),
  const Lesson(
    id: 'lesson_002',
    title: 'Describing Impermanence',
    titlePali: 'Anicca',
    description: 'Advanced vocabulary to articulate the concept of impermanence in English dharma talks.',
    type: LessonType.dhamma,
    difficulty: LessonDifficulty.intermediate,
    targetLevel: EnglishLevel.b1,
    suitableFor: [MeditationExperience.intermediate, MeditationExperience.advanced],
    estimatedMinutes: 20,
    tags: ['dhamma', 'intermediate', 'three-marks'],
    iconAsset: 'assets/icons/lotus.svg',
    content: {'words': [], 'exercises': []},
    hasPaliContent: true,
  ),
  const Lesson(
    id: 'lesson_003',
    title: 'Welcoming Retreat Guests',
    titlePali: '',
    description: 'Practical English conversations for welcoming and orienting international visitors at the monastery.',
    type: LessonType.conversation,
    difficulty: LessonDifficulty.beginner,
    targetLevel: EnglishLevel.a1,
    suitableFor: [
      MeditationExperience.none,
      MeditationExperience.beginner,
      MeditationExperience.intermediate,
    ],
    estimatedMinutes: 10,
    tags: ['conversation', 'monastery', 'practical'],
    iconAsset: 'assets/icons/monastery.svg',
    content: {'words': [], 'exercises': []},
    hasPaliContent: false,
  ),
];

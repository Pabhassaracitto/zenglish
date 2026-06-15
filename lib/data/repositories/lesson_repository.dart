import '../models/lesson.dart';
import '../models/user_profile.dart';
import '../../core/enums/cefr_level.dart';
import '../../core/enums/meditation_stage.dart';

/// Abstract interface — không phụ thuộc implementation
/// Có thể swap giữa MockDatabase và FirebaseRepository
abstract class LessonRepository {

  // ─── Lessons ────────────────────────────────

  Future<Lesson?> getLessonById(String lessonId);

  Future<List<Lesson>> getLessonsByLevel(CEFRLevel level);

  Future<List<Lesson>> getLessonsForUser(UserProfile user);

  Future<List<Lesson>> searchLessons({
    String? keyword,
    CEFRLevel? level,
    MeditationStage? stage,
  });

  Future<void> upsertLesson(Lesson lesson);

  Future<void> deleteLesson(String lessonId);

  // ─── User Progress ───────────────────────────

  Future<UserProfile?> getUserProfile(String userId);

  Future<void> saveUserProfile(UserProfile profile);

  Future<void> markLessonCompleted({
    required String userId,
    required String lessonId,
  });

  Future<void> markLessonInProgress({
    required String userId,
    required String lessonId,
  });

  // ─── Vocabulary ─────────────────────────────

  Future<List<Lesson>> getLessonsNeedingAudio();

  Future<List<String>> getAllPaliTerms();
}

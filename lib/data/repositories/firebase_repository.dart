import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/enums/cefr_level.dart';
import '../../core/enums/meditation_stage.dart';
import '../models/lesson.dart';
import '../models/user_profile.dart';
import '../repositories/i_lesson_repository.dart';

/// FirebaseRepository — production implementation
/// Swap MockDatabase → FirebaseRepository
/// trong DI layer khi sẵn sàng
class FirebaseRepository implements ILessonRepository {
  FirebaseRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ─── Collection refs ────────────────────────

  CollectionReference<Map<String, dynamic>> get _lessons =>
      _db.collection('lessons');

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  // ─── ILessonRepository ──────────────────────

  @override
  Future<List<Lesson>> loadAllLessons() async {
    final snap = await _lessons.orderBy('lesson_id').get();
    return snap.docs.map((doc) => Lesson.fromJson(doc.data())).toList();
  }

  @override
  Future<Lesson?> getLessonById(String lessonId) async {
    final doc = await _lessons.doc(lessonId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Lesson.fromJson(doc.data()!);
  }

  @override
  Future<List<Lesson>> getLessonsByLevel(String level) async {
    final snap = await _lessons
        .where('level', isEqualTo: level)
        .orderBy('lesson_id')
        .get();
    return snap.docs.map((doc) => Lesson.fromJson(doc.data())).toList();
  }

  @override
  Future<void> clearCache() async {
    // FirebaseRepository không có cache, đây là no-op
  }

  @override
  Future<List<Lesson>> getLessonsForUser(UserProfile user) async {
    // Lấy tất cả lessons ở level phù hợp
    // Prerequisites check xảy ra ở client
    final snap = await _lessons
        .where('level', isEqualTo: user.languageLevel.displayName)
        .orderBy('lesson_id')
        .get();

    return snap.docs
        .map((doc) => Lesson.fromJson(doc.data()))
        .where((lesson) => user.canAccessLesson(
              lessonLevel: lesson.level,
              lessonMinStage: lesson.meditationStageMin,
              prerequisites: lesson.prerequisites,
            ))
        .toList();
  }

  @override
  Future<List<Lesson>> searchLessons({
    String? keyword,
    CEFRLevel? level,
    MeditationStage? stage,
  }) async {
    // Firestore không hỗ trợ full-text search tốt
    // → Lọc đơn giản theo level/stage; keyword filter ở client
    Query<Map<String, dynamic>> query = _lessons;

    if (level != null) {
      query = query.where('level', isEqualTo: level.displayName);
    }
    if (stage != null) {
      query = query.where(
        'meditation_stage_min',
        isEqualTo: stage.name,
      );
    }

    final snap = await query.orderBy('lesson_id').get();
    var results = snap.docs.map((doc) => Lesson.fromJson(doc.data())).toList();

    // Client-side keyword filter
    if (keyword != null && keyword.isNotEmpty) {
      final kw = keyword.toLowerCase();
      results = results
          .where((lesson) =>
              lesson.titleEn.toLowerCase().contains(kw) ||
              lesson.titleVi.toLowerCase().contains(kw) ||
              lesson.vocabulary.any(
                (v) =>
                    v.english.toLowerCase().contains(kw) ||
                    v.vietnamese.toLowerCase().contains(kw) ||
                    (v.pali?.toLowerCase().contains(kw) ?? false),
              ))
          .toList();
    }

    return results;
  }

  @override
  Future<void> upsertLesson(Lesson lesson) async {
    await _lessons.doc(lesson.lessonId).set(
          lesson.toJson(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> deleteLesson(String lessonId) async {
    await _lessons.doc(lessonId).delete();
  }

  // ─── User Progress ───────────────────────────

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromJson(doc.data()!);
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    await _users.doc(profile.userId).set(
          profile.toJson(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> markLessonCompleted({
    required String userId,
    required String lessonId,
  }) async {
    await _users.doc(userId).update({
      'completed_lesson_ids': FieldValue.arrayUnion([lessonId]),
      'in_progress_lesson_ids': FieldValue.arrayRemove([lessonId]),
      'last_active_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> markLessonInProgress({
    required String userId,
    required String lessonId,
  }) async {
    await _users.doc(userId).update({
      'in_progress_lesson_ids': FieldValue.arrayUnion([lessonId]),
      'last_active_at': DateTime.now().toIso8601String(),
    });
  }

  // ─── Vocabulary ─────────────────────────────

  @override
  Future<List<Lesson>> getLessonsNeedingAudio() async {
    // Không thể query nested field trong Firestore trực tiếp
    // → Thêm top-level flag khi upsert lesson
    final snap =
        await _lessons.where('has_audio_needed_vocab', isEqualTo: true).get();
    return snap.docs.map((doc) => Lesson.fromJson(doc.data())).toList();
  }

  @override
  Future<List<String>> getAllPaliTerms() async {
    // Query tất cả lesson và extract Pāḷi terms ở client
    final snap = await _lessons.get();
    final terms = <String>{};
    for (final doc in snap.docs) {
      final lesson = Lesson.fromJson(doc.data());
      for (final vocab in lesson.vocabulary) {
        if (vocab.pali != null) terms.add(vocab.pali!);
      }
    }
    return terms.toList()..sort();
  }

  // ─── Bulk Import ─────────────────────────────

  /// Import nhiều lesson lên Firestore cùng lúc
  /// Dùng khi migrate từ JSON → Firebase
  /// Batch write: max 500 operations/batch
  Future<void> importLessons(List<Lesson> lessons) async {
    const batchSize = 400; // Safety margin dưới 500
    final chunks = <List<Lesson>>[];

    for (var i = 0; i < lessons.length; i += batchSize) {
      chunks.add(
        lessons.sublist(
          i,
          (i + batchSize).clamp(0, lessons.length),
        ),
      );
    }

    for (final chunk in chunks) {
      final batch = _db.batch();
      for (final lesson in chunk) {
        batch.set(
          _lessons.doc(lesson.lessonId),
          lesson.toJson(),
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    }
  }

  /// Export tất cả lesson ra List (dùng khi backup)
  Future<List<Lesson>> exportAllLessons() async {
    final snap = await _lessons.orderBy('lesson_id').get();
    return snap.docs.map((doc) => Lesson.fromJson(doc.data())).toList();
  }
}

// lib/data/repositories/i_lesson_repository.dart

import '../models/lesson.dart';

/// Contract mà mọi lesson data source phải implement.
///
/// Nguyên tắc Dependency Inversion: UI và BLoC chỉ biết đến
/// interface này, không biết gì về implementation cụ thể.
///
/// Dễ dàng swap:
///   - LocalJsonContentRepository   → đọc từ assets
///   - FirebaseRepository           → Firestore
///   - RemoteConfigRepository       → Firebase Remote Config
///   - MockDatabase                 → Testing
abstract interface class ILessonRepository {
  /// Load tất cả lessons. Có thể throw [LessonLoadException].
  Future<List<Lesson>> loadAllLessons();

  /// Load một lesson cụ thể theo ID.
  /// Trả về null nếu không tìm thấy.
  Future<Lesson?> getLessonById(String lessonId);

  /// Load lessons theo level (ví dụ: "A2", "B1").
  Future<List<Lesson>> getLessonsByLevel(String level);

  /// Xóa cache nếu có. No-op với implementations không có cache.
  Future<void> clearCache();
}

/// Exception tùy chỉnh cho lỗi load lesson.
/// Giúp caller phân biệt lỗi JSON parse vs lỗi file không tồn tại.
sealed class LessonLoadException implements Exception {
  const LessonLoadException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message${cause != null ? '\nCaused by: $cause' : ''}';
}

/// File JSON không tìm thấy trong assets
final class LessonAssetNotFoundException extends LessonLoadException {
  const LessonAssetNotFoundException(super.message, {super.cause});
}

/// File JSON có format sai, không parse được
final class LessonJsonParseException extends LessonLoadException {
  const LessonJsonParseException(super.message, {super.cause});
}

/// Không có lesson nào được load thành công
final class NoLessonsAvailableException extends LessonLoadException {
  const NoLessonsAvailableException(super.message, {super.cause});
}

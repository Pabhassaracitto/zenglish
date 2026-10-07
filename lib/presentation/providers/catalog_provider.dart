// lib/presentation/providers/catalog_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/cefr_level.dart';
import '../../data/di/repository_provider.dart';
import '../../data/models/lesson.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/input_audio_resolver.dart';
import '../../data/services/user_session_service.dart';

/// Trạng thái học của một bài trong thư viện.
enum LessonProgressStatus { completed, inProgress, notStarted }

/// Một dòng trong thư viện bài học.
class CatalogEntry {
  const CatalogEntry({
    required this.lesson,
    required this.status,
    required this.missingPrerequisites,
  });

  final Lesson lesson;
  final LessonProgressStatus status;

  /// Các bài tiên quyết chưa hoàn thành (hiển thị để gợi ý, **không chặn**
  /// người học mở bài — chính sách mở khoá chưa được nghiệm thu, xem
  /// docs/CONTENT_AUDIT.md).
  final List<String> missingPrerequisites;

  bool get isCompleted => status == LessonProgressStatus.completed;
  bool get isInProgress => status == LessonProgressStatus.inProgress;
  bool get hasMissingPrerequisites => missingPrerequisites.isNotEmpty;

  /// Bài chưa có bản thu thật → sẽ đọc bằng giọng tổng hợp.
  bool get usesSynthesizedVoice => resolveInputAudio(lesson).isSynthesized;

  bool get needsReview => lesson.needsReview;
}

/// Thư viện bài học, nhóm theo trình độ CEFR, giữ nguyên thứ tự A1 → C2.
class LessonCatalog {
  const LessonCatalog({required this.entries});

  final List<CatalogEntry> entries;

  int get total => entries.length;
  int get completedCount => entries.where((e) => e.isCompleted).length;

  /// Nhóm theo level, chỉ giữ những level thực sự có bài.
  Map<CEFRLevel, List<CatalogEntry>> get byLevel {
    final grouped = <CEFRLevel, List<CatalogEntry>>{};
    for (final level in CEFRLevel.values) {
      final items = entries.where((e) => e.lesson.level == level).toList();
      if (items.isNotEmpty) grouped[level] = items;
    }
    return grouped;
  }
}

/// Xây thư viện từ danh sách bài và hồ sơ người học.
///
/// Hàm thuần — kiểm thử được mà không cần assets hay SharedPreferences.
LessonCatalog buildCatalog(List<Lesson> lessons, UserProfile? profile) {
  final completed = profile?.completedLessonIds.toSet() ?? <String>{};
  final inProgress = profile?.inProgressLessonIds.toSet() ?? <String>{};

  final sorted = [...lessons]..sort((a, b) {
      final levelCompare =
          a.level.index.compareTo(b.level.index);
      if (levelCompare != 0) return levelCompare;
      return a.lessonId.compareTo(b.lessonId);
    });

  final entries = sorted.map((lesson) {
    final LessonProgressStatus status;
    if (completed.contains(lesson.lessonId)) {
      status = LessonProgressStatus.completed;
    } else if (inProgress.contains(lesson.lessonId)) {
      status = LessonProgressStatus.inProgress;
    } else {
      status = LessonProgressStatus.notStarted;
    }

    final missing = lesson.prerequisites
        .where((id) => !completed.contains(id))
        .toList();

    return CatalogEntry(
      lesson: lesson,
      status: status,
      missingPrerequisites: missing,
    );
  }).toList();

  return LessonCatalog(entries: entries);
}

/// Tải **toàn bộ** bài học trong assets (không phải danh sách quick-start
/// hardcode trên Home).
final lessonCatalogProvider = FutureProvider<LessonCatalog>((ref) async {
  final lessons = await RepositoryProvider.instance.loadAllLessons();
  final profile = UserSessionService.instance.loadUserProfile();
  return buildCatalog(lessons, profile);
});

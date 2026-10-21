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
    this.nextPrerequisite,
  });

  final Lesson lesson;
  final LessonProgressStatus status;

  /// Các bài tiên quyết chưa hoàn thành (chỉ dùng cho logic/test, **không
  /// chặn** người học mở bài — chính sách mở khoá chưa được nghiệm thu, xem
  /// docs/CONTENT_AUDIT.md). UI không hiển thị danh sách mã bài này nữa;
  /// xem [nextPrerequisite].
  final List<String> missingPrerequisites;

  /// Bài tiên quyết chưa hoàn thành **đầu tiên** theo thứ tự học — tức bài
  /// người học nên làm kế tiếp. UI gợi ý bằng tên bài này thay vì liệt kê
  /// mã của mọi bài còn thiếu (audit 22/10/2026: mã như `A1_CH01_L01`
  /// không có ý nghĩa với người học và làm thẻ bài đầy chữ; thứ tự danh
  /// sách đã tự nó là lộ trình gợi ý). `null` khi không thiếu bài nào
  /// hoặc mã tiên quyết không tra được trong thư viện.
  final Lesson? nextPrerequisite;

  bool get isCompleted => status == LessonProgressStatus.completed;
  bool get isInProgress => status == LessonProgressStatus.inProgress;
  bool get hasMissingPrerequisites => missingPrerequisites.isNotEmpty;

  /// Audio của bài là giọng tổng hợp (file AI trên Hugging Face, file bundle
  /// theo danh mục AI, hoặc TTS thiết bị) → gắn nhãn minh bạch trên thư viện.
  /// Chỉ bản thu con người được gán `audio_url` ngoài danh mục mới không gắn.
  bool get usesAiVoice => resolveInputAudio(lesson).isAiGenerated;

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

  final byId = {for (final lesson in sorted) lesson.lessonId: lesson};

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

    // Bài nên học kế tiếp = bài tiên quyết còn thiếu đầu tiên tra được.
    Lesson? nextPrerequisite;
    for (final id in missing) {
      nextPrerequisite = byId[id];
      if (nextPrerequisite != null) break;
    }

    return CatalogEntry(
      lesson: lesson,
      status: status,
      missingPrerequisites: missing,
      nextPrerequisite: nextPrerequisite,
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

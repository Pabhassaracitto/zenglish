// lib/presentation/screens/settings/audio_manager_screen.dart
//
// Màn hình "Quản lý audio" — nơi NGƯỜI HỌC chủ động chọn tải audio theo
// chương hoặc toàn bộ, xem dung lượng ước tính trước khi tải và xoá file đã
// tải. Theo yêu cầu UX: KHÔNG tự động tải hàng loạt; tải từng bài do màn
// hình bài học đảm nhiệm.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/constants/audio_catalog.dart';
import '../../../data/models/lesson.dart';
import '../../../data/services/audio_download_service.dart';
import '../../providers/audio_availability_provider.dart';
import '../../providers/audio_download_provider.dart';
import '../../providers/catalog_provider.dart';

class AudioManagerScreen extends ConsumerWidget {
  const AudioManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(lessonCatalogProvider);
    final downloadState = ref.watch(audioDownloadProvider);
    final revision = downloadState.revision;
    final indexAsync = ref.watch(audioIndexProvider(revision));

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Quản lý audio'),
        backgroundColor: AppTheme.cardBackground,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: catalogAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLG),
            child: Text('Không tải được danh sách bài học: $error'),
          ),
        ),
        data: (catalog) {
          final lessons = catalog.entries
              .map((e) => e.lesson)
              .where(
                (l) => AudioCatalog.filesForLesson(l.lessonId).isNotEmpty,
              )
              .toList();

          if (lessons.isEmpty) {
            return const Center(child: Text('Chưa có bài học nào có audio.'));
          }

          final index =
              indexAsync.valueOrNull ?? const <String, DownloadedAudioInfo>{};

          return ListView(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            children: [
              _SummaryCard(lessons: lessons, index: index),
              const SizedBox(height: AppTheme.spaceMD),
              _DownloadAllCard(lessons: lessons, index: index),
              if (downloadState.batchTotal > 0) ...[
                const SizedBox(height: AppTheme.spaceSM),
                _BatchProgressCard(state: downloadState),
              ],
              const SizedBox(height: AppTheme.spaceLG),
              for (final chapter in _groupByChapter(lessons).entries) ...[
                _ChapterCard(
                  chapter: chapter.key,
                  lessons: chapter.value,
                  index: index,
                ),
                const SizedBox(height: AppTheme.spaceMD),
              ],
            ],
          );
        },
      ),
    );
  }

  Map<String, List<Lesson>> _groupByChapter(List<Lesson> lessons) {
    final grouped = <String, List<Lesson>>{};
    for (final lesson in lessons) {
      grouped.putIfAbsent(lesson.chapter, () => []).add(lesson);
    }
    return grouped;
  }
}

/// true nếu mọi file audio của bài đã nằm trong index.
bool _lessonDownloaded(Lesson lesson, Map<String, DownloadedAudioInfo> index) {
  final files = AudioCatalog.filesForLesson(lesson.lessonId);
  return files.isNotEmpty && files.every((f) => index.containsKey(f.fileName));
}

// ─────────────────────────────────────────────────────────────────────────────
// SUMMARY
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.lessons, required this.index});

  final List<Lesson> lessons;
  final Map<String, DownloadedAudioInfo> index;

  @override
  Widget build(BuildContext context) {
    final downloadedLessons =
        lessons.where((l) => _lessonDownloaded(l, index)).length;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.headphones,
              color: AppTheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio trên máy: $downloadedLessons/${lessons.length} bài',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chiếm ${formatMb(downloadedBytesOf(index))} · tải đủ bộ '
                  'ước tính ${formatMb(AudioCatalog.estimatedBytesTotal)}',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DOWNLOAD ALL
// ─────────────────────────────────────────────────────────────────────────────

class _DownloadAllCard extends ConsumerWidget {
  const _DownloadAllCard({required this.lessons, required this.index});

  final List<Lesson> lessons;
  final Map<String, DownloadedAudioInfo> index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(audioDownloadProvider);
    final notifier = ref.read(audioDownloadProvider.notifier);
    final pending = lessons
        .map((l) => l.lessonId)
        .where(
          (id) => !AudioCatalog.filesForLesson(id)
              .every((f) => index.containsKey(f.fileName)),
        )
        .toList();

    if (pending.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        decoration: BoxDecoration(
          color: AppTheme.secondary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.secondary),
            const SizedBox(width: AppTheme.spaceSM),
            const Expanded(
              child: Text('Đã tải đủ audio cho tất cả bài học. 🎉'),
            ),
            TextButton(
              onPressed: downloadState.isBusy
                  ? null
                  : () => _confirmDeleteAll(context, notifier),
              child: const Text('Xoá tất cả'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tải toàn bộ (${pending.length} bài còn thiếu)',
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Ước tính ${formatMb(pending.fold<int>(
              0,
              (sum, id) => sum + AudioCatalog.estimatedBytesForLesson(id),
            ))}. Bạn cũng có thể tải theo từng chương ở bên dưới.',
            style: AppTheme.labelSmall.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          Row(
            children: [
              if (downloadState.isBusy)
                OutlinedButton.icon(
                  onPressed: notifier.cancel,
                  icon: const Icon(Icons.stop, size: 16),
                  label: const Text('Huỷ tải'),
                )
              else
                FilledButton.icon(
                  onPressed: () => notifier.downloadBatch(
                    lessons.map((l) => l.lessonId).toList(),
                  ),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Tải tất cả'),
                ),
              const SizedBox(width: AppTheme.spaceSM),
              TextButton(
                onPressed: downloadState.isBusy
                    ? null
                    : () => _confirmDeleteAll(context, notifier),
                child: const Text('Xoá tất cả'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(
    BuildContext context,
    AudioDownloadNotifier notifier,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xoá toàn bộ audio đã tải?'),
        content: const Text(
          'Các file audio đã lưu trên máy sẽ bị xoá. Bạn vẫn nghe được khi '
          'có mạng hoặc tải lại bất cứ lúc nào.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Giữ lại'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              notifier.deleteAll();
            },
            child: const Text('Xoá tất cả'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BATCH PROGRESS
// ─────────────────────────────────────────────────────────────────────────────

class _BatchProgressCard extends StatelessWidget {
  const _BatchProgressCard({required this.state});

  final AudioDownloadState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đang tải ${state.batchDone}/${state.batchTotal} bài…',
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.batchTotal > 0
                  ? (state.batchDone / state.batchTotal).clamp(0.0, 1.0)
                  : 0,
              minHeight: 5,
              backgroundColor: AppTheme.divider.withOpacity(0.5),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bài hiện tại: ${state.activeLessonId ?? "—"} · '
            '${formatMb(state.receivedBytes)}/${formatMb(state.totalBytes)}',
            style: AppTheme.labelSmall.copyWith(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHAPTER CARD + LESSON ROWS
// ─────────────────────────────────────────────────────────────────────────────

class _ChapterCard extends ConsumerWidget {
  const _ChapterCard({
    required this.chapter,
    required this.lessons,
    required this.index,
  });

  final String chapter;
  final List<Lesson> lessons;
  final Map<String, DownloadedAudioInfo> index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(audioDownloadProvider);
    final notifier = ref.read(audioDownloadProvider.notifier);

    final estimated = lessons.fold<int>(
      0,
      (sum, l) => sum + AudioCatalog.estimatedBytesForLesson(l.lessonId),
    );
    final allDownloaded = lessons.every((l) => _lessonDownloaded(l, index));
    final isChapterDownloading =
        lessons.any((l) => l.lessonId == downloadState.activeLessonId);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceMD,
              AppTheme.spaceMD,
              AppTheme.spaceSM,
              AppTheme.spaceSM,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Chương $chapter · ${lessons.length} bài · '
                    'ước tính ${formatMb(estimated)}',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (allDownloaded)
                  const Padding(
                    padding: EdgeInsets.only(right: AppTheme.spaceSM),
                    child: Icon(
                      Icons.check_circle,
                      color: AppTheme.secondary,
                      size: 20,
                    ),
                  )
                else if (!isChapterDownloading)
                  FilledButton.tonal(
                    onPressed: downloadState.isBusy
                        ? null
                        : () => notifier.downloadBatch(
                              lessons.map((l) => l.lessonId).toList(),
                            ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Tải chương'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          for (final lesson in lessons)
            _LessonAudioRow(lesson: lesson, index: index),
        ],
      ),
    );
  }
}

class _LessonAudioRow extends ConsumerWidget {
  const _LessonAudioRow({required this.lesson, required this.index});

  final Lesson lesson;
  final Map<String, DownloadedAudioInfo> index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(audioDownloadProvider);
    final notifier = ref.read(audioDownloadProvider.notifier);
    final lessonId = lesson.lessonId;
    final files = AudioCatalog.filesForLesson(lessonId);
    final isDownloaded = _lessonDownloaded(lesson, index);
    final isDownloading = downloadState.activeLessonId == lessonId;
    final hasError = downloadState.errorLessonId == lessonId;

    final downloadedBytes = files
        .map((f) => index[f.fileName]?.bytes ?? 0)
        .fold<int>(0, (sum, bytes) => sum + bytes);

    Widget trailing;
    if (isDownloading) {
      trailing = SizedBox(
        width: 110,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(downloadState.progress * 100).round()}%',
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: downloadState.progress,
                minHeight: 4,
                backgroundColor: AppTheme.divider.withOpacity(0.5),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
          ],
        ),
      );
    } else if (isDownloaded) {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatMb(downloadedBytes),
            style: AppTheme.labelSmall.copyWith(color: AppTheme.textMuted),
          ),
          IconButton(
            tooltip: 'Xoá audio bài này',
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: AppTheme.textMuted,
            ),
            onPressed: downloadState.isBusy
                ? null
                : () => notifier.deleteLesson(lessonId),
          ),
        ],
      );
    } else if (hasError) {
      trailing = FilledButton.tonal(
        onPressed: downloadState.isBusy
            ? null
            : () => notifier.downloadLesson(lessonId),
        style: FilledButton.styleFrom(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
        child: const Text('Thử lại'),
      );
    } else {
      trailing = IconButton(
        tooltip: 'Tải audio bài này',
        icon: const Icon(
          Icons.download,
          color: AppTheme.primary,
        ),
        onPressed: downloadState.isBusy
            ? null
            : () => notifier.downloadLesson(lessonId),
      );
    }

    return ListTile(
      dense: true,
      leading: Icon(
        isDownloaded
            ? Icons.check_circle
            : isDownloading
                ? Icons.downloading
                : hasError
                    ? Icons.error_outline
                    : Icons.music_note_outlined,
        size: 20,
        color: isDownloaded
            ? AppTheme.secondary
            : hasError
                ? AppColors.error
                : AppTheme.textMuted,
      ),
      title: Text(
        lesson.titleVi,
        style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        hasError && downloadState.errorMessage != null
            ? downloadState.errorMessage!
            : '$lessonId · ước tính '
                '${formatMb(AudioCatalog.estimatedBytesForLesson(lessonId))}',
        style: AppTheme.labelSmall.copyWith(
          color: hasError ? AppColors.error : AppTheme.textMuted,
        ),
        maxLines: hasError ? 3 : 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing,
    );
  }
}

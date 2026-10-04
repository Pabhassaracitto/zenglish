// lib/presentation/screens/catalog/lesson_catalog_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/cefr_level.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/catalog_provider.dart';

/// Thư viện bài học — hiển thị **toàn bộ** bài có trong assets.
///
/// Trước đây Home chỉ có 4 thẻ quick-start hardcode, nên các bài A1 chương
/// 1–4 tuy đã nằm trong `assets/data/lessons/` nhưng không có đường vào từ
/// giao diện. Màn hình này đọc thẳng từ repository nên khi thêm bài mới vào
/// registry là bài tự xuất hiện, không cần sửa UI.
class LessonCatalogScreen extends ConsumerWidget {
  const LessonCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(lessonCatalogProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Thư viện bài học'),
        backgroundColor: AppTheme.cardBackground,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: catalogAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (error, _) => _CatalogError(
          message: error.toString(),
          onRetry: () => ref.invalidate(lessonCatalogProvider),
        ),
        data: (catalog) {
          if (catalog.entries.isEmpty) {
            return const _CatalogError(
              message: 'Không tìm thấy bài học nào trong assets.',
            );
          }

          final grouped = catalog.byLevel;

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async => ref.invalidate(lessonCatalogProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceMD,
                AppTheme.spaceMD,
                AppTheme.spaceMD,
                AppTheme.spaceXXL,
              ),
              children: [
                _CatalogSummary(
                  total: catalog.total,
                  completed: catalog.completedCount,
                ),
                const SizedBox(height: AppTheme.spaceLG),
                for (final entry in grouped.entries) ...[
                  _LevelHeader(level: entry.key, count: entry.value.length),
                  const SizedBox(height: AppTheme.spaceSM),
                  for (final item in entry.value) ...[
                    _LessonTile(entry: item),
                    const SizedBox(height: AppTheme.spaceSM),
                  ],
                  const SizedBox(height: AppTheme.spaceMD),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _CatalogSummary extends StatelessWidget {
  const _CatalogSummary({required this.total, required this.completed});

  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đã hoàn thành $completed / $total bài',
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppTheme.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          Text(
            'Nội dung beta: các bài gắn nhãn "chờ duyệt" chưa được người phụ '
            'trách nội dung nghiệm thu.',
            style: AppTheme.labelSmall.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _LevelHeader extends StatelessWidget {
  const _LevelHeader({required this.level, required this.count});

  final CEFRLevel level;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Text(
            level.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spaceSM),
        Text(
          '$count bài',
          style: AppTheme.labelSmall,
        ),
      ],
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.entry});

  final CatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    final lesson = entry.lesson;

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      onTap: () => context.push('/lesson/${lesson.lessonId}'),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: entry.isInProgress ? AppTheme.secondary : AppTheme.divider,
            width: entry.isInProgress ? 1.5 : 1,
          ),
          boxShadow: AppTheme.subtleShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusIcon(status: entry.status),
                const SizedBox(width: AppTheme.spaceSM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.titleVi,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lesson.titleEn,
                        style: AppTheme.labelSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${lesson.lessonId} · ${lesson.vocabulary.length} từ vựng',
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ],
            ),
            if (entry.needsReview ||
                entry.usesSynthesizedVoice ||
                entry.hasMissingPrerequisites) ...[
              const SizedBox(height: AppTheme.spaceSM),
              Wrap(
                spacing: AppTheme.spaceXS,
                runSpacing: AppTheme.spaceXS,
                children: [
                  if (entry.needsReview)
                    const _Badge(
                      label: 'Chờ duyệt nội dung',
                      icon: Icons.fact_check_outlined,
                      color: AppTheme.warning,
                    ),
                  if (entry.usesSynthesizedVoice)
                    const _Badge(
                      label: 'Giọng tổng hợp (TTS)',
                      icon: Icons.record_voice_over_outlined,
                      color: AppTheme.paliColor,
                    ),
                  if (entry.hasMissingPrerequisites)
                    _Badge(
                      label:
                          'Nên học trước: ${entry.missingPrerequisites.join(', ')}',
                      icon: Icons.schema_outlined,
                      color: AppTheme.textSecondary,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final LessonProgressStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case LessonProgressStatus.completed:
        return const Icon(
          Icons.check_circle,
          color: AppTheme.success,
          size: 22,
        );
      case LessonProgressStatus.inProgress:
        return const Icon(
          Icons.play_circle_fill,
          color: AppTheme.secondary,
          size: 22,
        );
      case LessonProgressStatus.notStarted:
        return const Icon(
          Icons.circle_outlined,
          color: AppTheme.textMuted,
          size: 22,
        );
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppTheme.errorSoft),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              message,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.spaceMD),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

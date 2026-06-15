import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/home_provider.dart';
import '../../../../data/models/lesson.dart';

class SmartSuggestionCard extends ConsumerWidget {
  const SmartSuggestionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    if (!state.hasNextLesson) return const SizedBox();

    final lesson = state.nextLesson!;
    final isInProgress =
        state.userProfile?.inProgressLessonIds.contains(lesson.lessonId) ??
            false;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.07),
            AppTheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.15),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _SuggestionHeader(isInProgress: isInProgress),

          const Divider(height: 1, color: AppTheme.divider),

          // Lesson info
          _LessonInfo(lesson: lesson),

          const Divider(height: 1, color: AppTheme.divider),

          // Action buttons
          _SuggestionActions(
            lesson: lesson,
            isInProgress: isInProgress,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _SuggestionHeader extends StatelessWidget {
  const _SuggestionHeader({required this.isInProgress});
  final bool isInProgress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMD,
        AppTheme.spaceMD,
        AppTheme.spaceMD,
        AppTheme.spaceSM,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isInProgress
                  ? Icons.play_circle_outline
                  : Icons.lightbulb_outline,
              size: 16,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: AppTheme.spaceSM),
          Text(
            isInProgress ? 'Tiếp tục bài đang học' : 'Gợi ý tiếp theo',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const Spacer(),
          if (isInProgress)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Text(
                'ĐANG HỌC',
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _LessonInfo extends StatelessWidget {
  const _LessonInfo({required this.lesson});
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level badge (large)
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Text(
                lesson.level.displayName,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spaceMD),

          // Title + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.titleVi,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  lesson.titleEn,
                  style: AppTheme.bodyMedium.copyWith(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spaceSM),

                // Tags
                Row(
                  children: [
                    _Tag(
                      label: lesson.chapter,
                      color: AppTheme.secondary,
                    ),
                    const SizedBox(width: AppTheme.spaceXS),
                    _Tag(
                      label: lesson.meditationStageMin.displayName,
                      color: AppTheme.paliColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _SuggestionActions extends StatelessWidget {
  const _SuggestionActions({
    required this.lesson,
    required this.isInProgress,
  });
  final Lesson lesson;
  final bool isInProgress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      child: Row(
        children: [
          // Vocab preview
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Vocab preview bottom sheet
              },
              icon: const Icon(Icons.list_alt, size: 16),
              label: Text(
                '${lesson.vocabulary.length} từ vựng',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: const BorderSide(color: AppTheme.divider),
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spaceSM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spaceSM),

          // Start / Continue button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/lesson/${lesson.lessonId}'),
              icon: Icon(
                isInProgress ? Icons.play_arrow : Icons.arrow_forward,
                size: 18,
              ),
              label: Text(
                isInProgress ? 'Tiếp tục' : 'Bắt đầu học',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spaceSM + 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/lesson_provider.dart';

class LessonProgressBar extends ConsumerWidget {
  const LessonProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonProvider);
    final notifier = ref.read(lessonProvider.notifier);
    final stages = LessonStage.values;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
        vertical: AppTheme.spaceSM,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.divider, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Stage dots
          Row(
            children: stages.asMap().entries.map((entry) {
              final index = entry.key;
              final stage = entry.value;
              final isCurrent = stage == state.currentStage;
              final isCompleted = state.isStageCompleted(stage);
              final isSkipped =
                  stage == LessonStage.output && state.isSilentMode;

              return Expanded(
                child: GestureDetector(
                  onTap: isCompleted ? () => notifier.goToStage(stage) : null,
                  child: Column(
                    children: [
                      // Connector line (except first)
                      Row(
                        children: [
                          if (index > 0)
                            Expanded(
                              child: Container(
                                height: 1,
                                color: isCompleted
                                    ? AppTheme.primary
                                    : AppTheme.divider,
                              ),
                            ),
                          _StageDot(
                            stage: stage,
                            isCurrent: isCurrent,
                            isCompleted: isCompleted,
                            isSkipped: isSkipped,
                          ),
                          if (index < stages.length - 1)
                            Expanded(
                              child: Container(
                                height: 1,
                                color: isCompleted
                                    ? AppTheme.primary
                                    : AppTheme.divider,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spaceXS),
                      // Stage label
                      Text(
                        stage.displayName,
                        style: AppTheme.labelSmall.copyWith(
                          color: isCurrent
                              ? AppTheme.primary
                              : isCompleted
                                  ? AppTheme.textSecondary
                                  : AppTheme.textMuted,
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StageDot extends StatelessWidget {
  const _StageDot({
    required this.stage,
    required this.isCurrent,
    required this.isCompleted,
    required this.isSkipped,
  });

  final LessonStage stage;
  final bool isCurrent;
  final bool isCompleted;
  final bool isSkipped;

  @override
  Widget build(BuildContext context) {
    if (isSkipped) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surfaceVariant,
          border: Border.all(color: AppTheme.divider),
        ),
        child: const Icon(
          Icons.volume_off,
          size: 12,
          color: AppTheme.textMuted,
        ),
      );
    }

    if (isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.secondary,
        ),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    }

    if (isCurrent) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primary,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${LessonStage.values.indexOf(stage) + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    // Upcoming
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.surfaceVariant,
        border: Border.all(color: AppTheme.divider),
      ),
      child: Center(
        child: Text(
          '${LessonStage.values.indexOf(stage) + 1}',
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenglish/core/theme/app_theme.dart';

import '../../../providers/home_provider.dart';

class UserProfileCard extends ConsumerWidget {
  const UserProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final axes = ref.watch(threeAxisProvider);
    final profile = ref.watch(
      homeProvider.select((s) => s.userProfile),
    );

    if (profile == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Card header
          _CardHeader(
            completedCount: profile.completedLessonIds.length,
          ),

          const Divider(height: 1),

          // 3-axis display
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            child: Column(
              children: axes.map((axis) => _AxisRow(data: axis)).toList(),
            ),
          ),

          // Progress footer
          _ProgressFooter(
            completed: profile.completedLessonIds.length,
            inProgress: profile.inProgressLessonIds.length,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.completedCount});
  final int completedCount;

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
            child: const Icon(
              Icons.person_outline,
              size: 16,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: AppTheme.spaceSM),
          const Text(
            'Hồ Sơ Học Tập',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceSM,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Text(
              '$completedCount bài hoàn thành',
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _AxisRow extends StatelessWidget {
  const _AxisRow({required this.data});
  final AxisData data;

  Color get _color {
    switch (data.color) {
      case AxisColor.primary:
        return AppTheme.primary;
      case AxisColor.secondary:
        return AppTheme.secondary;
      case AxisColor.pali:
        return AppTheme.paliColor;
    }
  }

  IconData get _icon {
    switch (data.color) {
      case AxisColor.primary:
        return Icons.language;
      case AxisColor.secondary:
        return Icons.self_improvement;
      case AxisColor.pali:
        return Icons.translate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSM),
      child: Row(
        children: [
          // Icon
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _color.withOpacity(0.08),
            ),
            child: Icon(_icon, size: 16, color: _color),
          ),
          const SizedBox(width: AppTheme.spaceSM),

          // Label + sublabel
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  data.sublabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Value badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceSM,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Text(
              data.value,
              style: TextStyle(
                color: _color,
                fontSize: 13,
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

class _ProgressFooter extends StatelessWidget {
  const _ProgressFooter({
    required this.completed,
    required this.inProgress,
  });
  final int completed;
  final int inProgress;

  @override
  Widget build(BuildContext context) {
    // Total lessons available (approximate based on our 10 tasks)
    const totalAvailable = 10;
    final progress = completed / totalAvailable;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusLG),
          bottomRight: Radius.circular(AppTheme.radiusLG),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tiến độ tổng thể',
                style: AppTheme.labelSmall,
              ),
              Text(
                '$completed / $totalAvailable bài',
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppTheme.divider,
              color: AppTheme.primary,
              minHeight: 4,
            ),
          ),
          if (inProgress > 0) ...[
            const SizedBox(height: AppTheme.spaceXS),
            Text(
              '$inProgress bài đang học dở',
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

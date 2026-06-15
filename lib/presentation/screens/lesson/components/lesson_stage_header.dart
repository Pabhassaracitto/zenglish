import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/lesson_provider.dart';

class LessonStageHeader extends StatelessWidget {
  const LessonStageHeader({
    super.key,
    required this.stage,
    required this.titleEn,
    required this.titleVi,
  });

  final LessonStage stage;
  final String titleEn;
  final String titleVi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spaceMD,
        right: AppTheme.spaceMD,
        top: AppTheme.spaceLG,
        bottom: AppTheme.spaceSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stage badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceSM,
              vertical: AppTheme.spaceXS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Text(
              stage.displayName.toUpperCase(),
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          // Title
          Text(titleEn, style: AppTheme.headingLarge),
          const SizedBox(height: 2),
          Text(titleVi, style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}

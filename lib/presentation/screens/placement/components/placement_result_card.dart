import 'package:flutter/material.dart';
import '../../../../data/models/placement_result.dart';
import '../../../../core/enums/cefr_level.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../logic/placement_logic.dart';

class PlacementResultCard extends StatelessWidget {
  const PlacementResultCard({
    super.key,
    required this.result,
    required this.onStartLesson,
  });

  final PlacementResult result;
  final VoidCallback onStartLesson;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ResultHeader(result: result),
          const SizedBox(height: AppTheme.spaceLG),
          // 3-axis coordinates
          ThreeAxisCard(result: result),
          const SizedBox(height: AppTheme.spaceMD),
          // Fast track notice
          if (result.fastTracked) ...[
            const FastTrackNotice(),
            const SizedBox(height: AppTheme.spaceMD),
          ],
          // Recommended lesson
          RecommendedLessonCard(lessonId: result.recommendedStartLessonId),
          const SizedBox(height: AppTheme.spaceLG),
          // Start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartLesson,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spaceMD,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                elevation: 0,
              ),
              child: Text(
                'Bắt đầu học ${result.recommendedStartLessonId}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class ResultHeader extends StatelessWidget {
  const ResultHeader({super.key, required this.result});
  final PlacementResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.08),
            AppTheme.secondary.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.spa_outlined,
              size: 28,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          const Text(
            'Kết Quả Đánh Giá',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: AppTheme.spaceXS),
          Text(
            _getWelcomeMessage(result.meditationExperience),
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getWelcomeMessage(MeditationExperience exp) {
    switch (exp) {
      case MeditationExperience.curious:
        return 'Chào mừng bạn đến với con đường tu học.';
      case MeditationExperience.beginner:
        return 'Bạn đã có những bước đầu trên con đường.';
      case MeditationExperience.samathaActive:
        return 'Bạn đang trong giai đoạn samatha — rất tốt.';
      case MeditationExperience.samathaAdvanced:
        return 'Bạn đã đi khá sâu trong samatha. Ngôn ngữ sẽ hỗ trợ thêm.';
      case MeditationExperience.vipassanaActive:
        return 'Bạn đang thực hành vipassanā. App sẽ giúp bạn diễn đạt kinh nghiệm.';
      case MeditationExperience.longTermPractitioner:
        return 'Bạn là người tu lâu năm. App sẽ giúp bạn giao tiếp quốc tế.';
    }
  }
}

// ─────────────────────────────────────────────
class ThreeAxisCard extends StatelessWidget {
  const ThreeAxisCard({super.key, required this.result});
  final PlacementResult result;

  @override
  Widget build(BuildContext context) {
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
            'Tọa Độ 3 Trục',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          AxisRow(
            axis: 'Trục 1',
            label: 'Tiếng Anh',
            value: result.derivedLanguageLevel.displayName,
            color: AppTheme.primary,
            icon: Icons.language,
          ),
          const SizedBox(height: AppTheme.spaceSM),
          AxisRow(
            axis: 'Trục 2',
            label: 'Thiền tập',
            value: meditationLabel(result.meditationExperience),
            color: AppTheme.secondary,
            icon: Icons.self_improvement,
          ),
          const SizedBox(height: AppTheme.spaceSM),
          AxisRow(
            axis: 'Trục 3',
            label: 'Pāḷi',
            value: paliLabel(result.derivedPaliLevel),
            color: AppTheme.paliColor,
            icon: Icons.translate,
          ),
          const SizedBox(height: AppTheme.spaceMD),
          // Vocab score
          const Divider(height: 1),
          const SizedBox(height: AppTheme.spaceSM),
          Row(
            children: [
              const Icon(
                Icons.quiz_outlined,
                size: 16,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: AppTheme.spaceSM),
              Text(
                'Vocab test: ${result.vocabScore}/${PlacementLogic.vocabQuestions.length} câu đúng',
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String meditationLabel(MeditationExperience exp) {
    switch (exp) {
      case MeditationExperience.curious:
        return 'Tìm hiểu';
      case MeditationExperience.beginner:
        return 'Mới bắt đầu';
      case MeditationExperience.samathaActive:
        return 'Samatha đang thực hành';
      case MeditationExperience.samathaAdvanced:
        return 'Samatha nâng cao';
      case MeditationExperience.vipassanaActive:
        return 'Vipassanā';
      case MeditationExperience.longTermPractitioner:
        return 'Tu lâu năm';
    }
  }

  String paliLabel(int level) {
    if (level == 0) return 'Chưa biết';
    if (level <= 2) return 'Nghe quen';
    if (level <= 4) return 'Hiểu nghĩa';
    return 'Đọc được';
  }
}

class AxisRow extends StatelessWidget {
  const AxisRow({
    super.key,
    required this.axis,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String axis;
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: AppTheme.spaceSM),
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceSM,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
class FastTrackNotice extends StatelessWidget {
  const FastTrackNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: AppTheme.accent.withOpacity(0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: AppTheme.spaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fast Track',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Kinh nghiệm thiền của bạn vượt trước tiếng Anh. '
                  'App đề xuất bắt đầu thẳng ở bài trình pháp '
                  'với ngôn ngữ đơn giản hơn.',
                  style: AppTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class RecommendedLessonCard extends StatelessWidget {
  const RecommendedLessonCard({super.key, required this.lessonId});
  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final info = getLessonInfo(lessonId);
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: AppTheme.secondary.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.secondary.withOpacity(0.12),
            ),
            child: const Icon(
              Icons.play_circle_outline,
              color: AppTheme.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bài học đề xuất',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info['titleVi']!,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  info['titleEn']!,
                  style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceSM,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              info['level']!,
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> getLessonInfo(String lessonId) {
    const lessonMap = {
      'A1CH01_L01': {
        'titleVi': 'Cơ Duyên Đến Với Đạo Phật',
        'titleEn': 'How I Found the Dhamma',
        'level': 'A1',
      },
      'A1_CH02_L01': {
        'titleVi': 'Đến Thiền Viện Lần Đầu',
        'titleEn': 'Arriving at the Monastery',
        'level': 'A1',
      },
      'A1_CH03_L01': {
        'titleVi': 'Sinh Hoạt Hằng Ngày',
        'titleEn': 'Daily Life at the Monastery',
        'level': 'A1',
      },
      'A2_CH06_L01': {
        'titleVi': 'Ānāpāna — Trình Pháp Về Thiền Hơi Thở',
        'titleEn': 'Reporting Your Breath Meditation',
        'level': 'A2',
      },
      'B1_CH12_L01': {
        'titleVi': 'Trình Pháp 5 Phần (Cốt Lõi)',
        'titleEn': 'The 5-Part Meditation Interview',
        'level': 'B1',
      },
    };
    return lessonMap[lessonId] ??
        {
          'titleVi': lessonId,
          'titleEn': lessonId,
          'level': '—',
        };
  }
}

import 'package:flutter/material.dart';
import 'package:zenglish/core/theme/app_theme.dart';

import '../models/interview_feedback.dart';
import 'feedback_section.dart';

/// Bottom sheet hiển thị kết quả phân tích
/// Thiết kế: bình an, không gamification,
/// nhấn mạnh cải thiện không phán xét
void showFeedbackBottomSheet({
  required BuildContext context,
  required InterviewFeedback feedback,
  required VoidCallback onRetry,
  required VoidCallback onContinue,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FeedbackBottomSheet(
      feedback: feedback,
      onRetry: onRetry,
      onContinue: onContinue,
    ),
  );
}

class FeedbackBottomSheet extends StatelessWidget {
  const FeedbackBottomSheet({
    super.key,
    required this.feedback,
    required this.onRetry,
    required this.onContinue,
  });

  final InterviewFeedback feedback;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.92;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: const BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: AppTheme.spaceSM),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSM),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceMD,
                0,
                AppTheme.spaceMD,
                AppTheme.spaceMD,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _FeedbackHeader(feedback: feedback),
                  const SizedBox(height: AppTheme.spaceLG),

                  // Score ring
                  _ScoreDisplay(score: feedback.overallScore),
                  const SizedBox(height: AppTheme.spaceLG),

                  // 5-Point Check results
                  FeedbackSection(
                    title: '5 Điểm Kiểm Tra',
                    icon: Icons.checklist,
                    child: _CheckResultsList(
                      results: feedback.checkResults,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceMD),

                  // Language feedback
                  if (feedback.languageFeedback.isNotEmpty)
                    FeedbackSection(
                      title: 'Nhận Xét Ngôn Ngữ',
                      icon: Icons.language,
                      child: Text(
                        feedback.languageFeedback,
                        style: AppTheme.bodyMedium,
                      ),
                    ),
                  const SizedBox(height: AppTheme.spaceMD),

                  // Semantic hint
                  if (feedback.semanticHint.hasContent)
                    _SemanticHintCard(hint: feedback.semanticHint),
                  const SizedBox(height: AppTheme.spaceMD),

                  // Detected keywords
                  if (feedback.detectedKeywords.isNotEmpty)
                    _KeywordsDisplay(
                      keywords: feedback.detectedKeywords,
                    ),
                  const SizedBox(height: AppTheme.spaceMD),

                  // Encouragement
                  _EncouragementCard(
                    encouragement: feedback.encouragement,
                    nextStep: feedback.suggestedNextStep,
                  ),
                  const SizedBox(height: AppTheme.spaceLG),

                  // Action buttons
                  _ActionButtons(
                    onRetry: onRetry,
                    onContinue: onContinue,
                    feedback: feedback,
                  ),

                  // Safe area bottom
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _FeedbackHeader extends StatelessWidget {
  const _FeedbackHeader({required this.feedback});
  final InterviewFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final isGood = feedback.isGoodReport;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isGood ? AppTheme.secondary : AppTheme.primary)
                .withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isGood ? Icons.check_circle_outline : Icons.analytics_outlined,
            size: 22,
            color: isGood ? AppTheme.secondary : AppTheme.primary,
          ),
        ),
        const SizedBox(width: AppTheme.spaceSM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Phân Tích Báo Cáo',
                style: AppTheme.headingMedium,
              ),
              Text(
                isGood
                    ? 'Báo cáo tốt — đủ thông tin cho thiền sư'
                    : 'Có thể cải thiện thêm',
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────

class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay({required this.score});
  final int score;

  Color get _color {
    if (score >= 80) return AppTheme.secondary;
    if (score >= 60) return AppTheme.accent;
    return AppTheme.primary;
  }

  String get _label {
    if (score >= 85) return 'Xuất sắc';
    if (score >= 70) return 'Tốt';
    if (score >= 55) return 'Khá';
    if (score >= 40) return 'Đang xây dựng';
    return 'Cần thêm luyện tập';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: AppTheme.divider,
                    color: _color,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _color,
                      ),
                    ),
                    const Text(
                      '/ 100',
                      style: AppTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceSM),
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
              _label,
              style: TextStyle(
                color: _color,
                fontSize: 13,
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

class _CheckResultsList extends StatelessWidget {
  const _CheckResultsList({required this.results});
  final List<CheckResult> results;

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          results.map((result) => _CheckResultRow(result: result)).toList(),
    );
  }
}

class _CheckResultRow extends StatefulWidget {
  const _CheckResultRow({required this.result});
  final CheckResult result;

  @override
  State<_CheckResultRow> createState() => _CheckResultRowState();
}

class _CheckResultRowState extends State<_CheckResultRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final color = r.passed ? AppTheme.secondary : AppTheme.errorSoft;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spaceSM),
        padding: const EdgeInsets.all(AppTheme.spaceSM + 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status icon
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.1),
                  ),
                  child: Icon(
                    r.passed ? Icons.check : Icons.close,
                    size: 14,
                    color: color,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSM),

                // Name + detected value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.checkNameVi,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (r.detectedValue != null)
                        Text(
                          '→ "${r.detectedValue}"',
                          style: AppTheme.labelSmall.copyWith(
                            color: color,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),

                // Expand icon
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
              ],
            ),

            // Expanded: description + tip
            if (_expanded) ...[
              const SizedBox(height: AppTheme.spaceSM),
              const Divider(height: 1),
              const SizedBox(height: AppTheme.spaceSM),
              Text(
                r.description,
                style: AppTheme.bodyMedium.copyWith(fontSize: 13),
              ),
              if (!r.passed && r.tip.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spaceXS),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spaceSM),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💡 ',
                        style: TextStyle(fontSize: 13),
                      ),
                      Expanded(
                        child: Text(
                          r.tip,
                          style: AppTheme.bodyMedium.copyWith(
                            fontSize: 13,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _SemanticHintCard extends StatelessWidget {
  const _SemanticHintCard({required this.hint});
  final SemanticHint hint;

  Color get _color {
    switch (hint.level) {
      case SemanticHintLevel.noteworthy:
        return AppTheme.accent;
      case SemanticHintLevel.possible:
        return AppTheme.secondary;
      case SemanticHintLevel.suggestion:
        return AppTheme.primary;
      case SemanticHintLevel.none:
        return AppTheme.textMuted;
    }
  }

  String get _levelLabel {
    switch (hint.level) {
      case SemanticHintLevel.noteworthy:
        return '⚠️ Đáng Chú Ý';
      case SemanticHintLevel.possible:
        return '🔍 Có Thể';
      case SemanticHintLevel.suggestion:
        return '💡 Gợi Ý';
      case SemanticHintLevel.none:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: _color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level badge
          Row(
            children: [
              Text(
                _levelLabel,
                style: TextStyle(
                  color: _color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              // Pāḷi term
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.paliColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  hint.paliTerm,
                  style: AppTheme.paliText.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSM),

          // Title
          Text(
            hint.titleVi,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint.titleEn,
            style: AppTheme.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSM),

          // Body
          Text(hint.body, style: AppTheme.bodyMedium),

          // Teacher note
          if (hint.teacherNote != null) ...[
            const SizedBox(height: AppTheme.spaceSM),
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceSM),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 13,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      hint.teacherNote!,
                      style: AppTheme.monasteryNote.copyWith(
                        fontStyle: FontStyle.normal,
                        fontSize: 12,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _KeywordsDisplay extends StatelessWidget {
  const _KeywordsDisplay({required this.keywords});
  final List<String> keywords;

  @override
  Widget build(BuildContext context) {
    return FeedbackSection(
      title: 'Từ Khoá Nhận Diện',
      icon: Icons.label_outline,
      child: Wrap(
        spacing: AppTheme.spaceSM,
        runSpacing: AppTheme.spaceXS,
        children: keywords
            .map((kw) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceSM,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    kw,
                    style: AppTheme.paliText.copyWith(fontSize: 12),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _EncouragementCard extends StatelessWidget {
  const _EncouragementCard({
    required this.encouragement,
    required this.nextStep,
  });
  final String encouragement;
  final String nextStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            encouragement,
            style: AppTheme.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
              color: AppTheme.textSecondary,
            ),
          ),
          if (nextStep.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spaceSM),
            const Divider(height: 1),
            const SizedBox(height: AppTheme.spaceSM),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    nextStep,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onRetry,
    required this.onContinue,
    required this.feedback,
  });
  final VoidCallback onRetry;
  final VoidCallback onContinue;
  final InterviewFeedback feedback;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Retry
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Thử lại'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: const BorderSide(color: AppTheme.divider),
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.spaceSM + 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spaceSM),

        // Continue
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onContinue();
            },
            icon: const Icon(Icons.check, size: 16),
            label: Text(
              feedback.isGoodReport ? 'Hoàn thành bài học' : 'Tiếp tục anyway',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  feedback.isGoodReport ? AppTheme.secondary : AppTheme.primary,
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/placement_result.dart';
import '../../../../logic/placement_logic.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/placement_provider.dart';
import 'shared_step_widgets.dart';

class StepVocab extends ConsumerWidget {
  const StepVocab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(
      placementProvider.select((s) => s.vocabAnswers),
    );
    final notifier = ref.read(placementProvider.notifier);
    final questions = PlacementLogic.vocabQuestions;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMD,
        0,
        AppTheme.spaceMD,
        AppTheme.spaceXXL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepHeader(
            stepNumber: 3,
            question: 'Thử chọn nghĩa đúng\ncủa các từ tiếng Anh sau:',
            subtitle: 'Chọn nghĩa tiếng Việt phù hợp với ngữ cảnh thiền viện.',
          ),
          const SizedBox(height: AppTheme.spaceLG),
          // Questions
          ...questions.asMap().entries.map(
                (entry) => VocabQuestionCard(
                  index: entry.key,
                  question: entry.value,
                  selectedIndex: answers[entry.value.id],
                  onSelect: (idx) => notifier.answerVocabQuestion(
                    entry.value.id,
                    idx,
                  ),
                ),
              ),
          const SizedBox(height: AppTheme.spaceMD),
          const PlacementNote(
            note: 'Không sao nếu bạn chưa biết những từ này. '
                'Đây chỉ là để app hiểu điểm bắt đầu của bạn.',
          ),
        ],
      ),
    );
  }
}

class VocabQuestionCard extends StatelessWidget {
  const VocabQuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int index;
  final VocabQuestion question;
  final int? selectedIndex;
  final void Function(int) onSelect;

  bool get hasAnswered => selectedIndex != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: hasAnswered
              ? AppTheme.primary.withOpacity(0.3)
              : AppTheme.divider,
        ),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question number
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceSM),
                    Text(
                      'Câu ${index + 1}',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.primary,
                      ),
                    ),
                    if (hasAnswered) ...[
                      const Spacer(),
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppTheme.secondary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppTheme.spaceSM),
                // Word
                Text(
                  '"${question.wordEn}"',
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXS),
                // Context hint
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceSM,
                    vertical: AppTheme.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Text(
                    question.contextHint,
                    style: AppTheme.monasteryNote.copyWith(
                      fontStyle: FontStyle.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Options
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceSM),
            child: Column(
              children: question.options.asMap().entries.map((entry) {
                final idx = entry.key;
                final option = entry.value;
                final isSelected = selectedIndex == idx;
                return GestureDetector(
                  onTap: () => onSelect(idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(
                      bottom: AppTheme.spaceXS,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceSM + 2,
                      vertical: AppTheme.spaceSM,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      border: Border.all(
                        color:
                            isSelected ? AppTheme.primary : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Option letter
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.surfaceVariant,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + idx), // A B C D
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceSM),
                        Expanded(
                          child: Text(
                            option,
                            style: AppTheme.bodyLarge.copyWith(
                              fontSize: 15,
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:zenglishapp/data/models/vocab_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenglishapp/core/theme/app_theme.dart';
import '../../../providers/lesson_provider.dart';

class PatternStage extends ConsumerWidget {
  const PatternStage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonProvider);
    final notifier = ref.read(lessonProvider.notifier);
    final vocab = ref.watch(shuffledVocabProvider);

    if (vocab.isEmpty) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: AppTheme.spaceMD,
        right: AppTheme.spaceMD,
        bottom: AppTheme.spaceXXL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('Nối Từ Tam Ngữ', style: AppTheme.headingMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: notifier.resetPatternAnswers,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Làm lại'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  textStyle: AppTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceXS),
          Text(
            'Nối mỗi từ tiếng Anh với nghĩa tiếng Việt và '
            'từ Pāḷi tương ứng',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.spaceMD),

          // Match cards
          ...vocab.map((item) => _TrilingualMatchCard(
                vocabItem: item,
                state: state,
                notifier: notifier,
                allVocab: vocab,
              )),

          const SizedBox(height: AppTheme.spaceLG),

          // Progress indicator
          _MatchProgress(state: state, total: vocab.length),
          const SizedBox(height: AppTheme.spaceLG),

          SizedBox(
            width: double.infinity,
            child: AnimatedOpacity(
              opacity: state.canProceedFromPattern ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
                onPressed: state.canProceedFromPattern
                    ? () {
                        notifier.markCurrentStageComplete();
                        notifier.nextStage();
                      }
                    : null,
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
                  'Tiếp tục → Luyện Tập',
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          if (!state.canProceedFromPattern)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.spaceSM),
              child: Center(
                child: Text(
                  'Cần đúng ít nhất 70% để tiếp tục',
                  style: AppTheme.bodyMedium.copyWith(
                    fontStyle: FontStyle.italic,
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

class _MatchProgress extends StatelessWidget {
  const _MatchProgress({
    required this.state,
    required this.total,
  });

  final LessonState state;
  final int total;

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox();
    final correct = state.patternCorrect.values.where((v) => v).length;
    final answered = state.patternAnswers.length;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đúng: $correct / $total',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXS),
                LinearProgressIndicator(
                  value: total > 0 ? correct / total : 0,
                  backgroundColor: AppTheme.divider,
                  color: AppTheme.secondary,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spaceMD),
          Text(
            '$answered/$total\nđã trả lời',
            style: AppTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TrilingualMatchCard extends StatelessWidget {
  const _TrilingualMatchCard({
    required this.vocabItem,
    required this.state,
    required this.notifier,
    required this.allVocab,
  });

  final VocabItem vocabItem;
  final LessonState state;
  final LessonNotifier notifier;
  final List<VocabItem> allVocab;

  @override
  Widget build(BuildContext context) {
    final answered = state.patternAnswers[vocabItem.stt];
    final isCorrect = state.patternCorrect[vocabItem.stt];
    final hasAnswered = state.patternAnswers.containsKey(vocabItem.stt);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSM),
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: hasAnswered
            ? (isCorrect == true
                ? AppTheme.secondary.withOpacity(0.06)
                : AppTheme.errorSoft.withOpacity(0.06))
            : AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: hasAnswered
              ? (isCorrect == true
                  ? AppTheme.secondary.withOpacity(0.5)
                  : AppTheme.errorSoft.withOpacity(0.3))
              : AppTheme.divider,
        ),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // English (fixed — the question)
          Row(
            children: [
              _LangBadge(label: 'EN', color: AppTheme.primary),
              const SizedBox(width: AppTheme.spaceSM),
              Expanded(
                child: Text(
                  vocabItem.english,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (hasAnswered)
                Icon(
                  isCorrect == true ? Icons.check_circle : Icons.cancel,
                  color: isCorrect == true
                      ? AppTheme.secondary
                      : AppTheme.errorSoft,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSM),

          // Vietnamese answer (dropdown)
          Row(
            children: [
              _LangBadge(
                label: 'VI',
                color: AppTheme.secondary,
              ),
              const SizedBox(width: AppTheme.spaceSM),
              Expanded(
                child: _AnswerDropdown(
                  hintText: 'Chọn nghĩa tiếng Việt...',
                  options: allVocab,
                  selected: answered,
                  getLabel: (v) => v.vietnamese,
                  onSelected: (v) =>
                      notifier.submitPatternAnswer(vocabItem.stt, v),
                ),
              ),
            ],
          ),

          // Pāḷi (shown after correct answer)
          if (isCorrect == true && vocabItem.pali != null) ...[
            const SizedBox(height: AppTheme.spaceSM),
            Row(
              children: [
                _LangBadge(label: 'PĀ', color: AppTheme.paliColor),
                const SizedBox(width: AppTheme.spaceSM),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vocabItem.pali!,
                      style: AppTheme.paliText,
                    ),
                    if (vocabItem.paliRomanized != null)
                      Text(
                        '[${vocabItem.paliRomanized}]',
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.paliColor.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSM),
            // Example sentence
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceSM),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Text(
                vocabItem.exampleEn,
                style: AppTheme.monasteryNote.copyWith(
                  fontStyle: FontStyle.normal,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LangBadge extends StatelessWidget {
  const _LangBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 20,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _AnswerDropdown extends StatelessWidget {
  const _AnswerDropdown({
    required this.hintText,
    required this.options,
    required this.selected,
    required this.getLabel,
    required this.onSelected,
  });

  final String hintText;
  final List<VocabItem> options;
  final VocabItem? selected;
  final String Function(VocabItem) getLabel;
  final void Function(VocabItem) onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceSM,
          vertical: AppTheme.spaceSM - 2,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected != null ? getLabel(selected!) : hintText,
                style: selected != null
                    ? AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimary,
                      )
                    : AppTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.unfold_more,
              size: 16,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLG),
        ),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppTheme.spaceSM),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            child: Text(
              'Chọn nghĩa tiếng Việt',
              style: AppTheme.headingMedium,
            ),
          ),
          const Divider(height: 1),
          ...options.map((opt) => ListTile(
                title: Text(
                  getLabel(opt),
                  style: AppTheme.bodyLarge,
                ),
                trailing: selected?.stt == opt.stt
                    ? const Icon(
                        Icons.check,
                        color: AppTheme.secondary,
                        size: 18,
                      )
                    : null,
                onTap: () {
                  onSelected(opt);
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: AppTheme.spaceMD),
        ],
      ),
    );
  }
}

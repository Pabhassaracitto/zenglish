import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenglish/core/theme/app_theme.dart';
import 'package:zenglish/data/models/vocab_item.dart';
import 'package:zenglish/l10n/app_localizations.dart';

import '../../../providers/lesson_provider.dart';

final _shakingCardProvider = StateProvider<int?>((ref) => null);

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
              Text(context.l10n.matchWords, style: AppTheme.headingMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  notifier.resetPatternAnswers();
                  ref.read(_shakingCardProvider.notifier).state = null;
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(context.l10n.retry),
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
          ...vocab.map((item) => _ShakableMatchCard(
                key: ValueKey('card_${item.stt}'),
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

class _ShakableMatchCard extends ConsumerStatefulWidget {
  const _ShakableMatchCard({
    super.key,
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
  ConsumerState<_ShakableMatchCard> createState() => _ShakableMatchCardState();
}

class _ShakableMatchCardState extends ConsumerState<_ShakableMatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (context, child) {
        final offset = math.sin(_shakeAnim.value * math.pi * 4) * 6;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: _TrilingualMatchCard(
        vocabItem: widget.vocabItem,
        state: widget.state,
        notifier: widget.notifier,
        allVocab: widget.allVocab,
        onWrongAnswer: _triggerShake,
      ),
    );
  }
}

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
    required this.onWrongAnswer,
  });

  final VocabItem vocabItem;
  final LessonState state;
  final LessonNotifier notifier;
  final List<VocabItem> allVocab;
  final VoidCallback onWrongAnswer;

  @override
  Widget build(BuildContext context) {
    final answered = state.patternAnswers[vocabItem.stt];
    final isCorrect = state.patternCorrect[vocabItem.stt];
    final hasAnswered = state.patternAnswers.containsKey(vocabItem.stt);

    // Mỗi nghĩa đúng chỉ nên được ghép một lần. Ẩn các lựa chọn đã ghép
    // đúng ở những dòng khác để danh sách ngắn dần theo tiến độ.
    final usedCorrectAnswers = state.patternCorrect.entries
        .where((entry) => entry.value && state.patternAnswers[entry.key] != null)
        .map((entry) => state.patternAnswers[entry.key]!.stt)
        .toSet();
    final availableOptions = allVocab.where((option) {
      return option.stt == vocabItem.stt ||
          option.stt == answered?.stt ||
          !usedCorrectAnswers.contains(option.stt);
    }).toList();

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
          if (vocabItem.englishIpa != null) ...[
            const SizedBox(height: AppTheme.spaceXS),
            Text(
              vocabItem.englishIpa!,
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
                  options: availableOptions,
                  selected: answered,
                  getLabel: (v) => v.vietnamese,
                  onSelected: (v) {
                    notifier.submitPatternAnswer(vocabItem.stt, v);
                    if (v.stt != vocabItem.stt) {
                      onWrongAnswer();
                    }
                  },
                ),
              ),
            ],
          ),

          // Details stay collapsed after answering; the learner sees only
          // the useful result first and can open the explanation when needed.
          if (isCorrect == true && (vocabItem.pali != null || vocabItem.exampleEn.isNotEmpty))
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: Text('Xem thêm: Pāḷi và ví dụ', style: AppTheme.labelSmall),
              children: [
                if (vocabItem.pali != null)
                  Row(
                    children: [
                      _LangBadge(label: 'PĀ', color: AppTheme.paliColor),
                      const SizedBox(width: AppTheme.spaceSM),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vocabItem.pali!, style: AppTheme.paliText),
                          if (vocabItem.paliRomanized != null)
                            Text('[${vocabItem.paliRomanized}]', style: AppTheme.labelSmall),
                        ],
                      ),
                    ],
                  ),
                if (vocabItem.exampleEn.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spaceSM),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spaceSM),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                    child: Text(vocabItem.exampleEn, style: AppTheme.monasteryNote.copyWith(
                      fontStyle: FontStyle.normal, color: AppTheme.textPrimary,
                    )),
                  ),
                ],
              ],
            ),

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
    // Keep the choices anchored to the question so learners do not have to
    // move their eyes to a separate full-width sheet.
    return DropdownButtonHideUnderline(
      child: DropdownButton<VocabItem>(
        value: selected,
        hint: Text(hintText, maxLines: 1, overflow: TextOverflow.ellipsis),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textMuted),
        dropdownColor: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        menuMaxHeight: 280,
        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
        items: options
            .map((option) => DropdownMenuItem<VocabItem>(
                  value: option,
                  child: Text(
                    getLabel(option),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) onSelected(value);
        },
      ),
    );
  }
}

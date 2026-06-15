import 'package:ewmapp/data/models/lesson_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/lesson_provider.dart';

class GuidedStage extends ConsumerWidget {
  const GuidedStage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonProvider);
    final notifier = ref.read(lessonProvider.notifier);
    final guided = state.lesson?.lessonFlow.guided;

    if (guided == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: AppTheme.spaceMD,
        right: AppTheme.spaceMD,
        bottom: AppTheme.spaceXXL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description card
          _GuidedDescription(description: guided.description),
          const SizedBox(height: AppTheme.spaceLG),

          // Interview steps
          ...guided.interviewSteps
              .asMap()
              .entries
              .map((entry) => _InterviewStepCard(
                    index: entry.key,
                    step: entry.value,
                    state: state,
                    notifier: notifier,
                  )),

          const SizedBox(height: AppTheme.spaceLG),

          // Monastery note for guided
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(
                color: AppTheme.accent.withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🕌', style: TextStyle(fontSize: 16)),
                const SizedBox(width: AppTheme.spaceSM),
                Expanded(
                  child: Text(
                    'Lưu ý: Bạn có thể trả lời dựa trên kinh nghiệm '
                    'thật hoặc luyện tập tình huống giả định. '
                    'Không cần tự tạo ra kinh nghiệm.',
                    style: AppTheme.monasteryNote,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceLG),

          SizedBox(
            width: double.infinity,
            child: AnimatedOpacity(
              opacity: state.canProceedFromGuided ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
                onPressed: state.canProceedFromGuided
                    ? () {
                        notifier.markCurrentStageComplete();
                        notifier.nextStage();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppTheme.spaceMD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Tiếp tục → Tự Nói',
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          if (!state.canProceedFromGuided)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.spaceSM),
              child: Center(
                child: Text(
                  'Cần trả lời ít nhất 60% câu hỏi để tiếp tục',
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

class _GuidedDescription extends StatelessWidget {
  const _GuidedDescription({required this.description});
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: AppTheme.secondary.withOpacity(0.2),
        ),
      ),
      child: Text(description, style: AppTheme.bodyMedium),
    );
  }
}

// ─────────────────────────────────────────────

class _InterviewStepCard extends ConsumerStatefulWidget {
  const _InterviewStepCard({
    required this.index,
    required this.step,
    required this.state,
    required this.notifier,
  });

  final int index;
  final InterviewStep step;
  final LessonState state;
  final LessonNotifier notifier;

  @override
  ConsumerState<_InterviewStepCard> createState() => _InterviewStepCardState();
}

class _InterviewStepCardState extends ConsumerState<_InterviewStepCard> {
  late final TextEditingController _ctrl;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.state.guidedAnswers[widget.index] ?? '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasAnswer =
        (widget.state.guidedAnswers[widget.index] ?? '').isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number + AI prompt
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondary.withOpacity(0.1),
                  border: Border.all(
                    color: AppTheme.secondary.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${widget.step.step}',
                    style: TextStyle(
                      color: AppTheme.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI question bubble
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceSM + 2,
                        vertical: AppTheme.spaceSM,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withOpacity(0.08),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(AppTheme.radiusMD),
                          bottomLeft: Radius.circular(AppTheme.radiusMD),
                          bottomRight: Radius.circular(AppTheme.radiusMD),
                        ),
                      ),
                      child: Text(
                        widget.step.aiPrompt,
                        style: AppTheme.bodyLarge.copyWith(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.step.purpose,
                      style: AppTheme.labelSmall.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSM),

          // User answer field
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Answer label
                Text(
                  'Câu trả lời của bạn:',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Focus(
                  onFocusChange: (f) => setState(() => _isFocused = f),
                  child: TextField(
                    controller: _ctrl,
                    maxLines: null,
                    minLines: 2,
                    onChanged: (v) =>
                        widget.notifier.updateGuidedAnswer(widget.index, v),
                    style: AppTheme.bodyLarge.copyWith(
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Bhante, ...',
                      hintStyle: AppTheme.bodyMedium.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      contentPadding: const EdgeInsets.all(
                        AppTheme.spaceSM + 2,
                      ),
                      filled: true,
                      fillColor: _isFocused
                          ? AppTheme.primary.withOpacity(0.04)
                          : AppTheme.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        borderSide: BorderSide(
                          color: AppTheme.divider,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        borderSide: BorderSide(
                          color: hasAnswer
                              ? AppTheme.secondary.withOpacity(0.4)
                              : AppTheme.divider,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        borderSide: BorderSide(
                          color: AppTheme.primary,
                          width: 1.5,
                        ),
                      ),
                      suffixIcon: hasAnswer
                          ? const Icon(
                              Icons.check_circle,
                              color: AppTheme.secondary,
                              size: 18,
                            )
                          : null,
                    ),
                  ),
                ),

                // Pattern hint (if available)
                if (widget.step.expectedPattern != null) ...[
                  const SizedBox(height: AppTheme.spaceXS),
                  Text(
                    'Mẫu câu: ${widget.step.expectedPattern}',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.paliColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/theme/app_theme.dart';
import '../../../providers/lesson_provider.dart';

class OutputStage extends ConsumerWidget {
  const OutputStage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonProvider);
    final notifier = ref.read(lessonProvider.notifier);
    final output = state.lesson?.lessonFlow.output;

    if (output == null) return const SizedBox();

    // Silent mode: stage fully hidden → shouldn't reach here
    // But guard anyway
    if (state.isSilentMode) {
      return _SilentModeFullBlock();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: AppTheme.spaceMD,
        right: AppTheme.spaceMD,
        bottom: AppTheme.spaceXXL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task card
          _OutputTaskCard(
            description: output.description,
            prompt: output.promptForUser,
          ),
          const SizedBox(height: AppTheme.spaceLG),

          // Sample output (reference)
          if (output.sampleOutputs?.isNotEmpty == true) ...[
            _SampleOutputCard(
              samples: output.sampleOutputs!,
            ),
            const SizedBox(height: AppTheme.spaceLG),
          ],

          // Evaluation criteria
          _EvaluationCriteriaCard(
            criteria: output.evaluationCriteria,
          ),
          const SizedBox(height: AppTheme.spaceLG),

          // Recording interface
          _VoiceRecordingCard(
            state: state,
            notifier: notifier,
          ),
          const SizedBox(height: AppTheme.spaceLG),

          // Finish lesson button
          if (state.outputRecordingState ==
              OutputRecordingState.recorded) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  notifier.markCurrentStageComplete();
                  _showCompletionDialog(context, state);
                },
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text('Hoàn Thành Bài Học'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppTheme.spaceMD),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMD),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCompletionDialog(
      BuildContext context, LessonState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LessonCompleteDialog(
        lessonTitle:
            state.lesson?.titleVi ?? 'Bài học đã hoàn thành',
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _SilentModeFullBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.volume_off,
              size: 48,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              'Chế Độ Im Lặng',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              'Giai đoạn ghi âm đã bị ẩn khi chế độ im lặng bật.',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceLG),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusMD),
                ),
              ),
              child: const Text('Tắt im lặng để ghi âm'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _OutputTaskCard extends StatelessWidget {
  const _OutputTaskCard({
    required this.description,
    required this.prompt,
  });
  final String description;
  final String prompt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_outlined,
                size: 18,
                color: AppTheme.primary,
              ),
              const SizedBox(width: AppTheme.spaceSM),
              Text(
                'Nhiệm Vụ',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSM),
          Text(description, style: AppTheme.bodyMedium),
          const SizedBox(height: AppTheme.spaceSM),
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceSM),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Text(
              prompt,
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _SampleOutputCard extends StatefulWidget {
  const _SampleOutputCard({required this.samples});
  final Map<String, String> samples;

  @override
  State<_SampleOutputCard> createState() =>
      _SampleOutputCardState();
}

class _SampleOutputCardState extends State<_SampleOutputCard> {
  bool _revealed = false;

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
          Row(
            children: [
              Text(
                'Câu Mẫu Tham Khảo',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    setState(() => _revealed = !_revealed),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceSM,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(
                        AppTheme.radiusSM),
                  ),
                  child: Text(
                    _revealed ? 'Ẩn đi' : 'Xem mẫu',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_revealed) ...[
            const SizedBox(height: AppTheme.spaceSM),
            const Divider(height: 1),
            const SizedBox(height: AppTheme.spaceSM),
            ...widget.samples.entries.map((entry) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceSM,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            AppTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.key,
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceSM),
                    Text(
                      entry.value,
                      style: AppTheme.bodyLarge.copyWith(
                        fontSize: 14,
                        height: 1.7,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                )),
          ] else ...[
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              'Hãy thử tự nói trước khi xem mẫu.',
              style: AppTheme.bodyMedium.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _EvaluationCriteriaCard extends StatelessWidget {
  const _EvaluationCriteriaCard({required this.criteria});
  final List<String> criteria;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiêu Chí Đánh Giá',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          ...criteria.map((c) => Padding(
                padding: const EdgeInsets.only(
                    bottom: AppTheme.spaceSM),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.radio_button_unchecked,
                      size: 14,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: AppTheme.spaceSM),
                    Expanded(
                      child: Text(
                        c,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _VoiceRecordingCard extends StatelessWidget {
  const _VoiceRecordingCard({
    required this.state,
    required this.notifier,
  });

  final LessonState state;
  final LessonNotifier notifier;

  String _formatTime(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final recState = state.outputRecordingState;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: recState == OutputRecordingState.recording
              ? AppTheme.errorSoft.withOpacity(0.3)
              : AppTheme.divider,
        ),
      ),
      child: Column(
        children: [
          // Status label
          Text(
            _statusLabel(recState),
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: _statusColor(recState),
            ),
          ),
          const SizedBox(height: AppTheme.spaceLG),

          // Main recording button
          if (recState == OutputRecordingState.idle ||
              recState == OutputRecordingState.recording)
            _HoldToRecordButton(
              isRecording:
                  recState == OutputRecordingState.recording,
              onStart: () {
                HapticFeedback.mediumImpact();
                notifier.startRecording();
              },
              onStop: () {
                HapticFeedback.lightImpact();
                notifier.stopRecording();
              },
            ),

          // Recorded state controls
          if (recState == OutputRecordingState.recorded ||
              recState == OutputRecordingState.playing) ...[
            _RecordedControls(
              state: state,
              notifier: notifier,
              formatTime: _formatTime,
            ),
          ],

          const SizedBox(height: AppTheme.spaceMD),

          // Timer
          if (recState == OutputRecordingState.recording ||
              recState == OutputRecordingState.recorded ||
              recState == OutputRecordingState.playing)
            Text(
              _formatTime(state.outputRecordingSeconds),
              style: AppTheme.headingLarge.copyWith(
                fontFamily: 'monospace',
                color: _statusColor(recState),
                letterSpacing: 2,
              ),
            ),

          // Hint text
          const SizedBox(height: AppTheme.spaceSM),
          Text(
            _hintText(recState),
            style: AppTheme.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _statusLabel(OutputRecordingState s) {
    switch (s) {
      case OutputRecordingState.idle:
        return 'Sẵn sàng ghi âm';
      case OutputRecordingState.recording:
        return '⏺ Đang ghi âm...';
      case OutputRecordingState.recorded:
        return '✓ Đã ghi âm xong';
      case OutputRecordingState.playing:
        return '▶ Đang phát lại...';
    }
  }

  Color _statusColor(OutputRecordingState s) {
    switch (s) {
      case OutputRecordingState.idle:
        return AppTheme.textSecondary;
      case OutputRecordingState.recording:
        return AppTheme.errorSoft;
      case OutputRecordingState.recorded:
        return AppTheme.secondary;
      case OutputRecordingState.playing:
        return AppTheme.primary;
    }
  }

  String _hintText(OutputRecordingState s) {
    switch (s) {
      case OutputRecordingState.idle:
        return 'Nhấn và giữ để bắt đầu nói';
      case OutputRecordingState.recording:
        return 'Thả ra để kết thúc';
      case OutputRecordingState.recorded:
        return 'Nghe lại hoặc ghi âm mới';
      case OutputRecordingState.playing:
        return 'Đang phát...';
    }
  }
}

// ─────────────────────────────────────────────

class _HoldToRecordButton extends StatelessWidget {
  const _HoldToRecordButton({
    required this.isRecording,
    required this.onStart,
    required this.onStop,
  });

  final bool isRecording;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => onStart(),
      onLongPressEnd: (_) => onStop(),
      onTap: isRecording ? onStop : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: isRecording ? 88 : 80,
        height: isRecording ? 88 : 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRecording
              ? AppTheme.errorSoft
              : AppTheme.primary,
          boxShadow: [
            BoxShadow(
              color: (isRecording
                      ? AppTheme.errorSoft
                      : AppTheme.primary)
                  .withOpacity(0.35),
              blurRadius: isRecording ? 24 : 16,
              spreadRadius: isRecording ? 4 : 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: isRecording ? 32 : 36,
            ),
            if (!isRecording) ...[
              const SizedBox(height: 2),
              const Text(
                'GIỮ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _RecordedControls extends StatelessWidget {
  const _RecordedControls({
    required this.state,
    required this.notifier,
    required this.formatTime,
  });

  final LessonState state;
  final LessonNotifier notifier;
  final String Function(int) formatTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Discard
        _RecordingActionButton(
          icon: Icons.delete_outline,
          label: 'Xoá',
          color: AppTheme.errorSoft,
          onTap: notifier.clearRecording,
        ),
        const SizedBox(width: AppTheme.spaceLG),

        // Play / Stop playback
        _RecordingActionButton(
          icon: state.outputRecordingState ==
                  OutputRecordingState.playing
              ? Icons.stop
              : Icons.play_arrow,
          label: state.outputRecordingState ==
                  OutputRecordingState.playing
              ? 'Dừng'
              : 'Nghe lại',
          color: AppTheme.primary,
          onTap: notifier.playRecording,
        ),
      ],
    );
  }
}

class _RecordingActionButton extends StatelessWidget {
  const _RecordingActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _LessonCompleteDialog extends StatelessWidget {
  const _LessonCompleteDialog({required this.lessonTitle});
  final String lessonTitle;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondary.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.spa_outlined,
                size: 32,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text('Bài Học Hoàn Thành',
                style: AppTheme.headingMedium),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              lessonTitle,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceLG),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil(
                      (route) => route.isFirst,
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppTheme.radiusMD),
                  ),
                  elevation: 0,
                ),
                child: const Text('Về trang chính'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

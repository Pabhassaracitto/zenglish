//lib\presentation\screens\lesson\stages\input_stage.dart
import 'package:zenglishapp/data/models/lesson_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zenglishapp/core/theme/app_theme.dart';
import '../../../providers/lesson_provider.dart';

class InputStage extends ConsumerWidget {
  const InputStage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonProvider);
    final notifier = ref.read(lessonProvider.notifier);
    final dialogues = state.lesson?.lessonFlow.input.sampleDialogues ?? [];

    if (dialogues.isEmpty) return const SizedBox();

    final currentDialogue = dialogues[state.currentDialogueIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: AppTheme.spaceMD,
        right: AppTheme.spaceMD,
        bottom: AppTheme.spaceXXL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            state.lesson?.lessonFlow.input.description ?? '',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.spaceLG),

          // Audio Player or Silent Notice
          if (state.isSilentMode)
            const _SilentModeNotice()
          else
            _AudioPlayerCard(
              state: state,
              notifier: notifier,
            ),
          const SizedBox(height: AppTheme.spaceLG),

          // Dialogue Navigator
          _DialogueNavigator(
            dialogues: dialogues,
            currentIndex: state.currentDialogueIndex,
            onPrevious: notifier.previousDialogue,
            onNext: notifier.nextDialogue,
          ),
          const SizedBox(height: AppTheme.spaceMD),

          // Transcript
          _TranscriptCard(dialogue: currentDialogue),
          const SizedBox(height: AppTheme.spaceLG),

          // Continue
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                notifier.markCurrentStageComplete();
                notifier.nextStage();
              },
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
                'Tiếp tục → Mẫu Câu',
                style: AppTheme.bodyLarge.copyWith(
                  color: Colors.white,
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

class _AudioPlayerCard extends StatelessWidget {
  const _AudioPlayerCard({
    required this.state,
    required this.notifier,
  });

  final LessonState state;
  final LessonNotifier notifier;

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final position = state.audioPositionSeconds;
    final duration =
        state.audioDurationSeconds == 0 ? 120 : state.audioDurationSeconds;
    final progress = duration > 0 ? position / duration : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.subtleShadow,
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.headphones,
                  size: 16,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: AppTheme.spaceSM),
              Text(
                'Audio — Monastery Dialogue',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMD),

          // Waveform visualization (static bars)
          _WaveformVisualizer(isPlaying: state.isAudioPlaying),
          const SizedBox(height: AppTheme.spaceMD),

          // Progress bar
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: AppTheme.divider,
              thumbColor: AppTheme.primary,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 6,
              ),
              overlayShape: SliderComponentShape.noOverlay,
              trackHeight: 3,
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (v) => notifier.seekAudio((v * duration).round()),
            ),
          ),

          // Time indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(position),
                  style: AppTheme.labelSmall,
                ),
                Text(
                  _formatTime(duration),
                  style: AppTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceSM),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rewind 10s
              _AudioControlButton(
                icon: Icons.replay_10,
                onTap: () => notifier.seekAudio(
                  (position - 10).clamp(0, duration),
                ),
              ),
              const SizedBox(width: AppTheme.spaceMD),

              // Play / Pause
              GestureDetector(
                onTap: notifier.toggleAudio,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    state.isAudioPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceMD),

              // Forward 10s
              _AudioControlButton(
                icon: Icons.forward_10,
                onTap: () => notifier.seekAudio(
                  (position + 10).clamp(0, duration),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AudioControlButton extends StatelessWidget {
  const _AudioControlButton({
    required this.icon,
    required this.onTap,
  });
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surfaceVariant,
          border: Border.all(color: AppTheme.divider),
        ),
        child: Icon(icon, size: 20, color: AppTheme.textSecondary),
      ),
    );
  }
}

class _WaveformVisualizer extends StatefulWidget {
  const _WaveformVisualizer({required this.isPlaying});
  final bool isPlaying;

  @override
  State<_WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<_WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  final List<double> _heights = [
    0.3,
    0.7,
    0.5,
    0.9,
    0.4,
    0.8,
    0.6,
    0.4,
    0.7,
    0.5,
    0.8,
    0.3,
    0.9,
    0.6,
    0.4,
    0.7,
    0.5,
    0.8,
    0.3,
    0.6,
    0.9,
    0.4,
    0.7,
    0.5,
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.isPlaying) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_WaveformVisualizer old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.isPlaying && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _heights.asMap().entries.map((entry) {
              final baseH = entry.value;
              final animH = widget.isPlaying
                  ? baseH * (0.5 + _ctrl.value * 0.5)
                  : baseH * 0.3;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 3,
                  height: 40 * animH,
                  decoration: BoxDecoration(
                    color: AppTheme.primary
                        .withOpacity(widget.isPlaying ? 0.7 : 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────

class _SilentModeNotice extends StatelessWidget {
  const _SilentModeNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.volume_off,
            size: 18,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: AppTheme.spaceSM),
          Expanded(
            child: Text(
              'Chế độ im lặng đang bật. Audio đã tắt.',
              style: AppTheme.bodyMedium.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _DialogueNavigator extends StatelessWidget {
  const _DialogueNavigator({
    required this.dialogues,
    required this.currentIndex,
    required this.onPrevious,
    required this.onNext,
  });

  final List<SampleDialogue> dialogues;
  final int currentIndex;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (dialogues.length <= 1) return const SizedBox();

    return Row(
      children: [
        Text(
          'Đoạn hội thoại',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: currentIndex > 0 ? onPrevious : null,
          icon: const Icon(Icons.chevron_left),
          iconSize: 20,
          color: AppTheme.textSecondary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceSM,
          ),
          child: Text(
            '${currentIndex + 1} / ${dialogues.length}',
            style: AppTheme.labelSmall,
          ),
        ),
        IconButton(
          onPressed: currentIndex < dialogues.length - 1 ? onNext : null,
          icon: const Icon(Icons.chevron_right),
          iconSize: 20,
          color: AppTheme.textSecondary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────

class _TranscriptCard extends StatelessWidget {
  const _TranscriptCard({required this.dialogue});
  final SampleDialogue dialogue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Context label
          Text(
            dialogue.context,
            style: AppTheme.monasteryNote,
          ),
          const Divider(height: AppTheme.spaceMD),

          // Dialogue lines
          ...dialogue.lines.asMap().entries.map((entry) {
            final line = entry.value;
            final isYogi =
                line.startsWith('Yogi:') || line.startsWith('Retreatant:');
            final isTeacher = line.startsWith('Teacher:');
            final isHelper = line.startsWith('Helper:');

            return Padding(
              padding: const EdgeInsets.only(
                bottom: AppTheme.spaceSM,
              ),
              child: _DialogueLine(
                line: line,
                isYogi: isYogi,
                isTeacher: isTeacher,
                isHelper: isHelper,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DialogueLine extends StatelessWidget {
  const _DialogueLine({
    required this.line,
    required this.isYogi,
    required this.isTeacher,
    required this.isHelper,
  });

  final String line;
  final bool isYogi;
  final bool isTeacher;
  final bool isHelper;

  @override
  Widget build(BuildContext context) {
    // Parse speaker and content
    final colonIndex = line.indexOf(':');
    final speaker = colonIndex > 0 ? line.substring(0, colonIndex) : '';
    final content =
        colonIndex > 0 ? line.substring(colonIndex + 1).trim() : line;

    Color speakerColor;
    Color bgColor;
    CrossAxisAlignment alignment;

    if (isTeacher) {
      speakerColor = AppTheme.secondary;
      bgColor = AppTheme.secondary.withOpacity(0.06);
      alignment = CrossAxisAlignment.start;
    } else if (isYogi) {
      speakerColor = AppTheme.primary;
      bgColor = AppTheme.primary.withOpacity(0.06);
      alignment = CrossAxisAlignment.end;
    } else {
      speakerColor = AppTheme.accent;
      bgColor = AppTheme.accent.withOpacity(0.06);
      alignment = CrossAxisAlignment.start;
    }

    return Column(
      crossAxisAlignment: alignment,
      children: [
        if (speaker.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              bottom: 2,
              left: 2,
              right: 2,
            ),
            child: Text(
              speaker,
              style: AppTheme.labelSmall.copyWith(
                color: speakerColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceSM + 2,
            vertical: AppTheme.spaceSM,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Text(
            content,
            style: AppTheme.bodyLarge.copyWith(fontSize: 15),
          ),
        ),
      ],
    );
  }
}

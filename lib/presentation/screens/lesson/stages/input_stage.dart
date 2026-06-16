import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenglish/core/theme/app_theme.dart';
import 'package:zenglish/presentation/providers/audio_provider.dart';
import 'package:zenglish/presentation/providers/lesson_provider.dart';
import 'package:zenglish/presentation/screens/lesson/lesson_screen.dart';

class _AudioPlayerCard extends ConsumerWidget {
  const _AudioPlayerCard({
    required this.state,
    required this.notifier,
  });

  final LessonState state;
  final LessonNotifier notifier;

  String _formatTime(Duration duration) {
    final seconds = duration.inSeconds;
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    final audioNotifier = ref.read(audioProvider.notifier);

    // Xử lý lỗi Silent Mode
    if (audioState.error == 'SILENT_MODE') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.volume_off, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please disable Silent Mode to hear audio',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.secondary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        audioNotifier.clearError();
      });
    }

    final position = audioState.position;
    final duration = audioState.duration.inSeconds == 0
        ? const Duration(seconds: 120)
        : audioState.duration;
    final progress = audioState.progress;

    // URL audio từ lesson
    final audioUrl = state.lesson?.lessonFlow.input.audioUrl;

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

          // Waveform visualization
          _WaveformVisualizer(
            isPlaying: audioState.isPlaying,
            isLoading: audioState.isLoading,
          ),
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
              onChanged: (v) {
                final newPosition = duration * v;
                audioNotifier.seek(newPosition);
              },
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
              // Rewind 10s
              IconButton(
                icon: const Icon(Icons.replay_10),
                onPressed: () {
                  final newPos = position - const Duration(seconds: 10);
                  audioNotifier.seek(
                    newPos < Duration.zero ? Duration.zero : newPos,
                  );
                },
              ),
              const SizedBox(width: AppTheme.spaceMD),

              // Play / Pause / Loading
              audioUrl != null
                  ? GestureDetector(
                      onTap: () async {
                        if (audioState.currentSource != audioUrl) {
                          await audioNotifier.play(audioUrl);
                        } else {
                          await audioNotifier.togglePlayPause();
                        }
                      },
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
                        child: _buildPlayPauseIcon(audioState),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.grey),
                      onPressed: null,
                    ),
              const SizedBox(width: AppTheme.spaceMD),

              // Forward 10s
              IconButton(
                icon: const Icon(Icons.forward_10),
                onPressed: () {
                  final newPos = position + const Duration(seconds: 10);
                  audioNotifier.seek(
                    newPos > duration ? duration : newPos,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseIcon(AudioState audioState) {
    if (audioState.isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Icon(
      audioState.isPlaying ? Icons.pause : Icons.play_arrow,
      color: Colors.white,
      size: 28,
    );
  }
}

class _WaveformVisualizer extends StatefulWidget {
  const _WaveformVisualizer({
    required this.isPlaying,
    this.isLoading = false,
  });

  final bool isPlaying;
  final bool isLoading;

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
    if (widget.isLoading) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ),
      );
    }

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
                    color: AppTheme.primary.withOpacity(
                      widget.isPlaying ? 0.7 : 0.3,
                    ),
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

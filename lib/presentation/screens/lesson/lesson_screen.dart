// lib/presentation/screens/lesson/lesson_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenglish/core/theme/app_theme.dart';
import 'package:zenglish/data/models/lesson.dart';
import 'package:zenglish/data/models/lesson_flow.dart';
import 'package:zenglish/data/services/audio_playback_service.dart';
import 'package:zenglish/presentation/providers/home_provider.dart';
import 'package:zenglish/presentation/providers/lesson_provider.dart';
import 'package:zenglish/presentation/screens/lesson/stages/pattern_stage.dart';
import 'package:zenglish/presentation/screens/lesson/stages/pattern_view_stage.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LESSON SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Sync silent mode from home profile into lesson state.
      final silentMode = ref.read(homeProvider.select((s) => s.silentMode));
      ref.read(lessonProvider.notifier).setSilentMode(silentMode);
      ref.read(lessonProvider.notifier).loadLesson(widget.lessonId);
    });
  }

  @override
  void dispose() {
    AudioPlaybackService.instance.stop();
    super.dispose();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  void _showSnackBar(String message, {IconData icon = Icons.info_outline}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  /// Called by every audio play button in the lesson.
  Future<void> _playAudio(String source) async {
    final isSilent = ref.read(lessonProvider.select((s) => s.isSilentMode));

    if (isSilent) {
      _showSnackBar(
        'Vui lòng tắt Chế độ Im lặng để nghe audio.',
        icon: Icons.volume_off,
      );
      return;
    }

    // Optimistically mark as playing in UI.
    ref.read(lessonProvider.notifier).setAudioPlaying(true);

    final result = await AudioPlaybackService.instance.play(
      source,
      isSilentMode: isSilent,
    );

    if (!mounted) return;

    switch (result) {
      case AudioLoadResult.success:
        // Player handles its own state stream; nothing extra needed.
        break;

      case AudioLoadResult.missingAsset:
        // ← CRITICAL: reset play button + inform user
        ref.read(lessonProvider.notifier).setAudioPlaying(false);
        _showSnackBar(
          'File audio chưa có trong MVP. Sẽ cập nhật sớm!',
          icon: Icons.audio_file,
        );
        break;

      case AudioLoadResult.networkError:
        ref.read(lessonProvider.notifier).setAudioPlaying(false);
        _showSnackBar(
          'Không thể tải audio. Vui lòng kiểm tra kết nối mạng.',
          icon: Icons.wifi_off,
        );
        break;

      case AudioLoadResult.silentMode:
        ref.read(lessonProvider.notifier).setAudioPlaying(false);
        _showSnackBar(
          'Vui lòng tắt Chế độ Im lặng để nghe audio.',
          icon: Icons.volume_off,
        );
        break;

      case AudioLoadResult.unknown:
        ref.read(lessonProvider.notifier).setAudioPlaying(false);
        _showSnackBar('Đã xảy ra lỗi. Vui lòng thử lại.');
        break;
    }
  }

  // ─── Continue / Next Stage ────────────────────────────────────────────────

  void _handleContinue(LessonState state) {
    if (state.currentStage.isLast) {
      // Lesson complete — pop back with result
      _showSnackBar('🎉 Hoàn thành bài học!', icon: Icons.celebration);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) context.pop(true); // true = completed
      });
      return;
    }

    final moved = ref.read(lessonProvider.notifier).nextStage();
    if (!moved && state.isSilentMode) {
      _showSnackBar(
        'Giai đoạn Tự Nói bị bỏ qua do Chế độ Im lặng.',
        icon: Icons.skip_next,
      );
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đang tải...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return _ErrorScaffold(
        message: state.error!,
        onBack: () => context.pop(),
      );
    }

    if (!state.hasLesson) {
      return _ErrorScaffold(
        message: 'Bài học không tồn tại hoặc chưa được tải.',
        onBack: () => context.pop(),
      );
    }

    final lesson = state.lesson!;

    return Scaffold(
      // ── AppBar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(lesson.titleEn),
        actions: [
          // Silent mode toggle in app bar
          IconButton(
            tooltip: state.isSilentMode ? 'Bật âm thanh' : 'Tắt âm thanh',
            icon: Icon(
              state.isSilentMode ? Icons.volume_off : Icons.volume_up,
            ),
            onPressed: () {
              ref.read(lessonProvider.notifier).toggleSilentMode();
            },
          ),
        ],
      ),

      // ── Body ────────────────────────────────────────────────────────────
      body: Column(
        children: [
          // Stage progress indicator
          _StageProgressBar(state: state),

          // Stage content — AnimatedSwitcher gives smooth transitions
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                // Slide in from right, slide out to left
                final slideIn = Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ));
                return SlideTransition(
                  position: slideIn,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              // key changes trigger the animation
              child: KeyedSubtree(
                key: ValueKey(state.currentStage),
                child: _buildStageContent(state, lesson),
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Continue Bar ─────────────────────────────────────────────
      bottomNavigationBar: _ContinueBar(
        label: state.continueLabel,
        enabled: state.canContinue && !state.isTransitioning,
        onContinue: () => _handleContinue(state),
        onBack: state.currentStage.previous != null
            ? () => ref.read(lessonProvider.notifier).previousStage()
            : null,
      ),
    );
  }

  // ─── Stage Content Router ────────────────────────────────────────────────

  Widget _buildStageContent(LessonState state, Lesson lesson) {
    switch (state.currentStage) {
      case LessonStage.input:
        return _InputStageView(
          lesson: lesson,
          state: state,
          onPlayAudio: _playAudio,
          notifier: ref.read(lessonProvider.notifier),
        );
      case LessonStage.pattern:
        return const PatternViewStage();
      case LessonStage.vocab:
        return const PatternStage();
      case LessonStage.guided:
        return _GuidedStageView(lesson: lesson, state: state);
      case LessonStage.output:
        return _OutputStageView(
          state: state,
          notifier: ref.read(lessonProvider.notifier),
          isSilentMode: state.isSilentMode,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAGE PROGRESS BAR
// ─────────────────────────────────────────────────────────────────────────────

class _StageProgressBar extends StatelessWidget {
  const _StageProgressBar({required this.state});

  final LessonState state;

  @override
  Widget build(BuildContext context) {
    final stages = LessonStage.values;
    final currentIdx = stages.indexOf(state.currentStage);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step labels
          Row(
            children: stages.map((stage) {
              final idx = stages.indexOf(stage);
              final isActive = stage == state.currentStage;
              final isDone = state.isStageCompleted(stage);

              return Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppTheme.primary
                            : isActive
                                ? AppTheme.primary.withOpacity(0.85)
                                : Colors.grey.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : Text(
                                '${idx + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? Colors.white : Colors.grey,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stage.displayName,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? AppTheme.primary : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Overall progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentIdx + 1) / stages.length,
              minHeight: 4,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTINUE BAR
// ─────────────────────────────────────────────────────────────────────────────

class _ContinueBar extends StatelessWidget {
  const _ContinueBar({
    required this.label,
    required this.enabled,
    required this.onContinue,
    this.onBack,
  });

  final String label;
  final bool enabled;
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Back button — shown only when not on first stage
            if (onBack != null) ...[
              OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Quay lại'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Continue button
            Expanded(
              child: FilledButton.icon(
                onPressed: enabled ? onContinue : null,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(label),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAGE VIEWS
// ─────────────────────────────────────────────────────────────────────────────

// ── Input Stage ──────────────────────────────────────────────────────────────

class _InputStageView extends StatelessWidget {
  const _InputStageView({
    required this.lesson,
    required this.state,
    required this.onPlayAudio,
    required this.notifier,
  });

  final Lesson lesson;
  final LessonState state;
  final Future<void> Function(String) onPlayAudio;
  final LessonNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final inputPhase = lesson.lessonFlow.input;
    final dialogues = inputPhase.sampleDialogues;
    final idx = state.currentDialogueIndex;
    final hasDialogues = dialogues.isNotEmpty;

    // ✅ Audio URL lấy từ InputPhase, không phải từ SampleDialogue
    final audioUrl = inputPhase.audioUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stage header
          _StageTitleCard(
            icon: Icons.hearing_rounded,
            title: 'Nghe & Hiểu',
            subtitle: 'Nghe đoạn hội thoại và hiểu ngữ cảnh.',
          ),
          const SizedBox(height: 16),

          // ── Audio Player toàn bài ──────────────────────────────────────
          if (audioUrl != null) ...[
            _AudioPlayerBar(
              isPlaying: state.isAudioPlaying,
              isSilentMode: state.isSilentMode,
              onPlay: () => onPlayAudio(audioUrl),
            ),
            const SizedBox(height: 16),
          ] else ...[
            // MVP: chưa có audio file
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Audio chưa có trong MVP. Sẽ cập nhật sớm!',
                      style: TextStyle(fontSize: 12, color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Dialogues ──────────────────────────────────────────────────
          if (hasDialogues) ...[
            Text(
              'Hội thoại ${idx + 1} / ${dialogues.length}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // ✅ Truyền đúng kiểu SampleDialogue
            _DialogueCard(dialogue: dialogues[idx]),

            const SizedBox(height: 12),

            // Navigation giữa các dialogue
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.outlined(
                  onPressed: idx > 0 ? notifier.previousDialogue : null,
                  icon: const Icon(Icons.navigate_before),
                  tooltip: 'Hội thoại trước',
                ),
                const SizedBox(width: 16),
                IconButton.outlined(
                  onPressed:
                      idx < dialogues.length - 1 ? notifier.nextDialogue : null,
                  icon: const Icon(Icons.navigate_next),
                  tooltip: 'Hội thoại tiếp theo',
                ),
              ],
            ),
          ] else
            const Center(child: Text('Chưa có hội thoại cho bài học này.')),

          const SizedBox(height: 24),

          // ── Vocabulary Preview ──────────────────────────────────────────
          Text(
            'Từ vựng (${lesson.vocabulary.length} từ)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...lesson.vocabulary.take(3).map(
                (v) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    tileColor: AppTheme.primary.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary.withOpacity(0.15),
                      child: Text(
                        '${v.stt}',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      v.english,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(v.vietnamese),
                    trailing: v.isHighPriority
                        ? const Icon(Icons.star, color: Colors.amber, size: 16)
                        : null,
                  ),
                ),
              ),
          if (lesson.vocabulary.length > 3)
            Center(
              child: Text(
                '+ ${lesson.vocabulary.length - 3} từ khác trong giai đoạn Pattern',
                style: TextStyle(color: AppTheme.primary, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Pattern Stage ─────────────────────────────────────────────────────────────

class _PatternStageView extends StatelessWidget {
  const _PatternStageView({required this.lesson, required this.state});

  final Lesson lesson;
  final LessonState state;

  @override
  Widget build(BuildContext context) {
    final patterns = lesson.lessonFlow.pattern.corePatterns;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageTitleCard(
            icon: Icons.abc_rounded,
            title: 'Mẫu Câu',
            subtitle: 'Học các cấu trúc câu cốt lõi trong bài.',
          ),
          const SizedBox(height: 16),

          if (patterns.isEmpty)
            const Center(child: Text('Chưa có mẫu câu.'))
          else
            ...patterns.map((pattern) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ pattern.function = chức năng/ý nghĩa
                        Text(
                          pattern.function,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // ✅ pattern.template = cấu trúc câu
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            pattern.template,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'monospace',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        // ✅ pattern.monasteryEnglishNote (optional)
                        if (pattern.monasteryEnglishNote != null &&
                            pattern.monasteryEnglishNote!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  pattern.monasteryEnglishNote!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (pattern.examples.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          const Text(
                            'Ví dụ:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...pattern.examples.take(3).map(
                                (ex) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('• ',
                                          style: TextStyle(color: Colors.grey)),
                                      Expanded(
                                        child: Text(
                                          ex,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),

          // ── Vocab review ────────────────────────────────────────────────
          const SizedBox(height: 8),
          Text(
            'Ôn từ vựng (${lesson.vocabulary.length} từ)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...lesson.vocabulary.map(
            (v) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: state.patternCorrect[v.stt] == true
                        ? Colors.green
                        : state.patternCorrect[v.stt] == false
                            ? Colors.red
                            : Colors.grey.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.english,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(v.vietnamese,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    if (state.patternCorrect[v.stt] == true)
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20)
                    else if (state.patternCorrect[v.stt] == false)
                      const Icon(Icons.cancel, color: Colors.red, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Guided Stage ──────────────────────────────────────────────────────────────

class _GuidedStageView extends ConsumerWidget {
  const _GuidedStageView({required this.lesson, required this.state});

  final Lesson lesson;
  final LessonState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = lesson.lessonFlow.guided.interviewSteps;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageTitleCard(
            icon: Icons.people_rounded,
            title: 'Luyện Tập Có Hướng Dẫn',
            subtitle: 'Trả lời các câu hỏi theo hướng dẫn.',
          ),
          const SizedBox(height: 16),
          if (steps.isEmpty)
            const Center(child: Text('Chưa có bước luyện tập.'))
          else
            ...steps.asMap().entries.map((entry) {
              final idx = entry.key;
              final step = entry.value;

              // ✅ Hint: ưu tiên expectedPattern, fallback về purpose
              final hint = (step.expectedPattern?.isNotEmpty ?? false)
                  ? step.expectedPattern!
                  : (step.purpose.isNotEmpty ? step.purpose : null);

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ step.aiPrompt = câu hỏi của AI
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.primary,
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              step.aiPrompt,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // purpose tag (nhỏ, màu xám)
                    if (step.purpose.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          '🎯 ${step.purpose}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Answer input
                    TextField(
                      onChanged: (v) => ref
                          .read(lessonProvider.notifier)
                          .updateGuidedAnswer(idx, v),
                      decoration: InputDecoration(
                        // ✅ step.expectedPattern = gợi ý cấu trúc câu trả lời
                        hintText: hint != null
                            ? 'Gợi ý: $hint'
                            : 'Nhập câu trả lời của bạn...',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixIcon:
                            (state.guidedAnswers[idx]?.isNotEmpty ?? false)
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                      ),
                      maxLines: 2,
                    ),

                    // ifIncorrect note (nếu có)
                    if (step.ifIncorrect != null &&
                        step.ifIncorrect!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          '💡 ${step.ifIncorrect}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ── Output Stage ──────────────────────────────────────────────────────────────

class _OutputStageView extends StatelessWidget {
  const _OutputStageView({
    required this.state,
    required this.notifier,
    required this.isSilentMode,
  });

  final LessonState state;
  final LessonNotifier notifier;
  final bool isSilentMode;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _StageTitleCard(
            icon: Icons.mic_rounded,
            title: 'Tự Nói',
            subtitle: 'Ghi âm bài nói của bạn theo chủ đề bài học.',
          ),
          const SizedBox(height: 24),

          if (isSilentMode) ...[
            // Silent mode warning
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.volume_off, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vui lòng tắt Chế độ Im lặng để sử dụng tính năng ghi âm.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Recording UI
            _RecordingButton(
              recordingState: state.outputRecordingState,
              seconds: state.outputRecordingSeconds,
              onStart: notifier.startRecording,
              onStop: notifier.stopRecording,
              onPlay: notifier.playRecording,
              onClear: notifier.clearRecording,
            ),
          ],

          const SizedBox(height: 32),

          // Criteria display
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tiêu chí đánh giá',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const SizedBox(height: 8),
          ...state.lesson!.lessonFlow.output.evaluationCriteria.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(c, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _StageTitleCard extends StatelessWidget {
  const _StageTitleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.12),
            AppTheme.primary.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ SampleDialogue.lines là List<String> (mỗi string = 1 dòng thoại)
// ✅ SampleDialogue.context = mô tả ngữ cảnh
class _DialogueCard extends StatelessWidget {
  const _DialogueCard({required this.dialogue});

  // ✅ Type đúng: SampleDialogue từ lesson_flow.dart
  final SampleDialogue dialogue;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ dialogue.context = mô tả bối cảnh — GIỮ từ HEAD
            if (dialogue.context.isNotEmpty) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.place, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        dialogue.context,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ✅ dialogue.lines là List<String>
            // Mỗi string có thể có format "Speaker: text" hoặc chỉ là text
            ...dialogue.lines.asMap().entries.map((entry) {
              final lineIndex = entry.key;
              final line = entry.value;

              // Thử tách "Speaker: text" nếu có dấu ":"
              final colonIdx = line.indexOf(':');
              final hasSpeaker = colonIdx > 0 && colonIdx < 20;
              final speaker =
                  hasSpeaker ? line.substring(0, colonIdx).trim() : null;
              final text =
                  hasSpeaker ? line.substring(colonIdx + 1).trim() : line;

              // Xen kẽ màu trái/phải để dễ đọc
              final isEven = lineIndex % 2 == 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      isEven ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    if (isEven) ...[
                      _SpeakerBubble(
                        speaker: speaker ?? 'A',
                        text: text,
                        isLeft: true,
                      ),
                    ] else ...[
                      _SpeakerBubble(
                        speaker: speaker ?? 'B',
                        text: text,
                        isLeft: false,
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Bubble chat style cho từng dòng hội thoại
class _SpeakerBubble extends StatelessWidget {
  const _SpeakerBubble({
    required this.speaker,
    required this.text,
    required this.isLeft,
  });

  final String speaker;
  final String text;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      child: Column(
        crossAxisAlignment:
            isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            speaker,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isLeft ? AppTheme.primary : Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isLeft
                  ? AppTheme.primary.withOpacity(0.1)
                  : Colors.deepOrange.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isLeft ? 2 : 12),
                bottomRight: Radius.circular(isLeft ? 12 : 2),
              ),
            ),
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

/// Thanh phát audio đơn giản cho toàn bài (Input Stage)
class _AudioPlayerBar extends StatelessWidget {
  const _AudioPlayerBar({
    required this.isPlaying,
    required this.isSilentMode,
    required this.onPlay,
  });

  final bool isPlaying;
  final bool isSilentMode;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.music_note, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Audio bài học',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: isSilentMode ? null : onPlay,
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 18,
            ),
            label: Text(isPlaying ? 'Dừng' : 'Nghe'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingButton extends StatelessWidget {
  const _RecordingButton({
    required this.recordingState,
    required this.seconds,
    required this.onStart,
    required this.onStop,
    required this.onPlay,
    required this.onClear,
  });

  final OutputRecordingState recordingState;
  final int seconds;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onPlay;
  final VoidCallback onClear;

  String get _timeLabel {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Big record button
        GestureDetector(
          onTap: () {
            switch (recordingState) {
              case OutputRecordingState.idle:
                onStart();
                break;
              case OutputRecordingState.recording:
                onStop();
                break;
              case OutputRecordingState.recorded:
                onPlay();
                break;
              case OutputRecordingState.playing:
                onStop();
                break;
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: recordingState == OutputRecordingState.recording
                  ? Colors.red
                  : AppTheme.primary,
              boxShadow: [
                BoxShadow(
                  color: (recordingState == OutputRecordingState.recording
                          ? Colors.red
                          : AppTheme.primary)
                      .withOpacity(0.4),
                  blurRadius:
                      recordingState == OutputRecordingState.recording ? 24 : 8,
                  spreadRadius:
                      recordingState == OutputRecordingState.recording ? 4 : 0,
                ),
              ],
            ),
            child: Icon(
              recordingState == OutputRecordingState.recording
                  ? Icons.stop
                  : recordingState == OutputRecordingState.recorded ||
                          recordingState == OutputRecordingState.playing
                      ? Icons.play_arrow
                      : Icons.mic,
              color: Colors.white,
              size: 42,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Timer / status
        Text(
          recordingState == OutputRecordingState.idle
              ? 'Chạm để ghi âm'
              : recordingState == OutputRecordingState.recording
                  ? '⏺ $_timeLabel — Đang ghi...'
                  : recordingState == OutputRecordingState.playing
                      ? '▶ Đang phát...'
                      : '✓ Đã ghi — Chạm để nghe lại',
          style: TextStyle(
            fontSize: 14,
            color: recordingState == OutputRecordingState.recording
                ? Colors.red
                : Colors.grey[700],
          ),
        ),

        // Clear button
        if (recordingState == OutputRecordingState.recorded ||
            recordingState == OutputRecordingState.playing) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Ghi lại'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR SCAFFOLD
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lỗi tải bài học'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    size: 40, color: Colors.red),
              ),
              const SizedBox(height: 16),
              const Text(
                'Không thể tải bài học',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/presentation/providers/lesson_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/lesson.dart';
import '../../data/models/vocab_item.dart';
import '../../data/di/repository_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────────────────────

enum LessonStage {
  input,
  pattern,
  guided,
  output;

  String get displayName {
    switch (this) {
      case LessonStage.input:   return 'Nghe & Hiểu';
      case LessonStage.pattern: return 'Mẫu Câu';
      case LessonStage.guided:  return 'Luyện Tập';
      case LessonStage.output:  return 'Tự Nói';
    }
  }


  LessonStage? get next {
    final i = LessonStage.values.indexOf(this);
    if (i < LessonStage.values.length - 1) return LessonStage.values[i + 1];
    return null;
  }

  LessonStage? get previous {
    final i = LessonStage.values.indexOf(this);
    if (i > 0) return LessonStage.values[i - 1];
    return null;
  }

  bool get isLast => next == null;
}

enum OutputRecordingState { idle, recording, recorded, playing }

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────

class LessonState {
  const LessonState({
    this.lesson,
    this.currentStage = LessonStage.input,
    this.isLoading = true,
    this.error,
    this.isSilentMode = false,
    this.isAudioPlaying = false,
    this.audioPositionSeconds = 0,
    this.audioDurationSeconds = 0,
    this.currentDialogueIndex = 0,
    this.patternAnswers = const {},
    this.patternCorrect = const {},
    this.guidedAnswers = const {},
    this.outputRecordingState = OutputRecordingState.idle,
    this.outputRecordingSeconds = 0,
    this.completedStages = const {},
    this.isTransitioning = false,
  });

  final Lesson? lesson;
  final LessonStage currentStage;
  final bool isLoading;
  final String? error;

  // ─── Silent Mode ────────────────────────────────────────────────────────
  final bool isSilentMode;

  // ─── Audio ──────────────────────────────────────────────────────────────
  final bool isAudioPlaying;
  final int audioPositionSeconds;
  final int audioDurationSeconds;
  final int currentDialogueIndex;

  // ─── Pattern Stage ──────────────────────────────────────────────────────
  final Map<int, VocabItem?> patternAnswers;
  final Map<int, bool> patternCorrect;

  // ─── Guided Stage ───────────────────────────────────────────────────────
  final Map<int, String> guidedAnswers;

  // ─── Output Stage ───────────────────────────────────────────────────────
  final OutputRecordingState outputRecordingState;
  final int outputRecordingSeconds;

  // ─── Progress ───────────────────────────────────────────────────────────
  final Set<LessonStage> completedStages;

  /// True while AnimatedSwitcher is mid-transition — prevents double-taps.
  final bool isTransitioning;

  // ─── Computed ───────────────────────────────────────────────────────────
  bool get hasLesson => lesson != null;

  double get overallProgress =>
      completedStages.length / LessonStage.values.length;

  bool isStageCompleted(LessonStage stage) => completedStages.contains(stage);

  /// Label for the "Continue" button depending on current stage.
  String get continueLabel {
    if (currentStage.isLast) return 'Hoàn thành bài học ✓';
    return 'Tiếp theo: ${currentStage.next!.displayName} →';
  }

  bool get canProceedFromPattern {
    if (lesson == null) return true;
    final total = lesson!.vocabulary.length;
    if (total == 0) return true;
    final correct = patternCorrect.values.where((v) => v).length;
    return correct >= (total * 0.7).ceil();
  }

  bool get canProceedFromGuided {
    if (lesson == null) return true;
    final steps = lesson!.lessonFlow.guided.interviewSteps.length;
    if (steps == 0) return true;
    final answered =
        guidedAnswers.values.where((v) => v.trim().isNotEmpty).length;
    return answered >= (steps * 0.6).ceil();
  }

  /// Whether the "Continue" button is enabled for the current stage.
  bool get canContinue {
    switch (currentStage) {
      case LessonStage.input:   return true; // always allow
      case LessonStage.pattern: return canProceedFromPattern;
      case LessonStage.guided:  return canProceedFromGuided;
      case LessonStage.output:  return true;
    }
  }

  LessonState copyWith({
    Lesson? lesson,
    LessonStage? currentStage,
    bool? isLoading,
    String? error,
    bool? isSilentMode,
    bool? isAudioPlaying,
    int? audioPositionSeconds,
    int? audioDurationSeconds,
    int? currentDialogueIndex,
    Map<int, VocabItem?>? patternAnswers,
    Map<int, bool>? patternCorrect,
    Map<int, String>? guidedAnswers,
    OutputRecordingState? outputRecordingState,
    int? outputRecordingSeconds,
    Set<LessonStage>? completedStages,
    bool? isTransitioning,
    bool clearError = false,
  }) {
    return LessonState(
      lesson: lesson ?? this.lesson,
      currentStage: currentStage ?? this.currentStage,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSilentMode: isSilentMode ?? this.isSilentMode,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
      audioPositionSeconds: audioPositionSeconds ?? this.audioPositionSeconds,
      audioDurationSeconds: audioDurationSeconds ?? this.audioDurationSeconds,
      currentDialogueIndex: currentDialogueIndex ?? this.currentDialogueIndex,
      patternAnswers: patternAnswers ?? this.patternAnswers,
      patternCorrect: patternCorrect ?? this.patternCorrect,
      guidedAnswers: guidedAnswers ?? this.guidedAnswers,
      outputRecordingState: outputRecordingState ?? this.outputRecordingState,
      outputRecordingSeconds:
          outputRecordingSeconds ?? this.outputRecordingSeconds,
      completedStages: completedStages ?? this.completedStages,
      isTransitioning: isTransitioning ?? this.isTransitioning,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class LessonNotifier extends StateNotifier<LessonState> {
  LessonNotifier() : super(const LessonState());

  final _repo = RepositoryProvider.instance;

  // ─── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadLesson(String lessonId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final lesson = await _repo.getLessonById(lessonId);
      if (lesson == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Bài học không tìm thấy: $lessonId',
        );
        return;
      }
      state = state.copyWith(
        lesson: lesson,
        isLoading: false,
        currentStage: LessonStage.input,
        completedStages: {},
        patternAnswers: {},
        patternCorrect: {},
        guidedAnswers: {},
        outputRecordingState: OutputRecordingState.idle,
        outputRecordingSeconds: 0,
        currentDialogueIndex: 0,
        audioPositionSeconds: 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ─── Navigation ────────────────────────────────────────────────────────────

  void goToStage(LessonStage stage) {
    if (state.isTransitioning) return;
    _beginTransition(stage);
  }

  /// Advance to the next stage (called by the Continue button).
  /// Returns true if navigation happened, false if already at last stage.
  bool nextStage() {
    if (state.isTransitioning) return false;
    final completed = {...state.completedStages, state.currentStage};
    final next = state.currentStage.next;
    if (next == null) return false; // already at output

    // Skip output stage if silent mode — just mark complete
    if (next == LessonStage.output && state.isSilentMode) {
      state = state.copyWith(completedStages: completed);
      return false; // lesson is "done" without output
    }

    _beginTransition(next, completedStages: completed);
    return true;
  }

  void previousStage() {
    if (state.isTransitioning) return;
    final prev = state.currentStage.previous;
    if (prev == null) return;
    _beginTransition(prev);
  }

  /// Internal: starts transition + schedules isTransitioning = false.
  void _beginTransition(
    LessonStage target, {
    Set<LessonStage>? completedStages,
  }) {
    state = state.copyWith(
      currentStage: target,
      completedStages: completedStages,
      isTransitioning: true,
      // Reset audio state when changing stages
      isAudioPlaying: false,
      audioPositionSeconds: 0,
    );
    // AnimatedSwitcher default duration is 300 ms; clear lock after that.
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        state = state.copyWith(isTransitioning: false);
      }
    });
  }

  // ─── Silent Mode ───────────────────────────────────────────────────────────

  void setSilentMode(bool value) {
    state = state.copyWith(
      isSilentMode: value,
      isAudioPlaying: value ? false : state.isAudioPlaying,
    );
  }

  void toggleSilentMode() => setSilentMode(!state.isSilentMode);

  // ─── Audio Controls ────────────────────────────────────────────────────────

  void setAudioPlaying(bool playing) {
    state = state.copyWith(isAudioPlaying: playing);
  }

  void seekAudio(int seconds) {
    state = state.copyWith(audioPositionSeconds: seconds);
  }

  void updateAudioProgress(int positionSeconds, int durationSeconds) {
    state = state.copyWith(
      audioPositionSeconds: positionSeconds,
      audioDurationSeconds: durationSeconds,
    );
  }

  void nextDialogue() {
    final max =
        (state.lesson?.lessonFlow.input.sampleDialogues.length ?? 1) - 1;
    if (state.currentDialogueIndex < max) {
      state = state.copyWith(
        currentDialogueIndex: state.currentDialogueIndex + 1,
        isAudioPlaying: false,
        audioPositionSeconds: 0,
      );
    }
  }

  void previousDialogue() {
    if (state.currentDialogueIndex > 0) {
      state = state.copyWith(
        currentDialogueIndex: state.currentDialogueIndex - 1,
        isAudioPlaying: false,
        audioPositionSeconds: 0,
      );
    }
  }

  // ─── Pattern Stage ─────────────────────────────────────────────────────────

  void submitPatternAnswer(int vocabStt, VocabItem? answer) {
    final lesson = state.lesson;
    if (lesson == null) return;

    final vocab = lesson.vocabulary.firstWhere(
      (v) => v.stt == vocabStt,
      orElse: () => lesson.vocabulary.first,
    );
    final isCorrect = answer?.stt == vocab.stt;

    state = state.copyWith(
      patternAnswers: {...state.patternAnswers, vocabStt: answer},
      patternCorrect: {...state.patternCorrect, vocabStt: isCorrect},
    );
  }

  void resetPatternAnswers() {
    state = state.copyWith(patternAnswers: {}, patternCorrect: {});
  }

  // ─── Guided Stage ──────────────────────────────────────────────────────────

  void updateGuidedAnswer(int stepIndex, String answer) {
    state = state.copyWith(
      guidedAnswers: {...state.guidedAnswers, stepIndex: answer},
    );
  }

  // ─── Output Stage ──────────────────────────────────────────────────────────

  void startRecording() {
    if (state.isSilentMode) return;
    state = state.copyWith(
      outputRecordingState: OutputRecordingState.recording,
      outputRecordingSeconds: 0,
    );
    _simulateRecording();
  }

  void stopRecording() {
    state = state.copyWith(outputRecordingState: OutputRecordingState.recorded);
  }

  void playRecording() {
    state = state.copyWith(outputRecordingState: OutputRecordingState.playing);
  }

  void clearRecording() {
    state = state.copyWith(
      outputRecordingState: OutputRecordingState.idle,
      outputRecordingSeconds: 0,
    );
  }

  void markCurrentStageComplete() {
    state = state.copyWith(
      completedStages: {...state.completedStages, state.currentStage},
    );
  }

  // ─── Simulations ───────────────────────────────────────────────────────────

  Future<void> _simulateRecording() async {
    for (int i = 0; i < 120; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      if (state.outputRecordingState != OutputRecordingState.recording) break;
      state = state.copyWith(outputRecordingSeconds: i + 1);
    }
    if (mounted &&
        state.outputRecordingState == OutputRecordingState.recording) {
      stopRecording();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

final lessonProvider =
    StateNotifierProvider<LessonNotifier, LessonState>(
  (ref) => LessonNotifier(),
);

final shuffledVocabProvider = Provider<List<VocabItem>>((ref) {
  final lesson = ref.watch(lessonProvider.select((s) => s.lesson));
  if (lesson == null) return [];
  final vocab = [...lesson.vocabulary];
  vocab.shuffle();
  return vocab;
});
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/lesson.dart';
import '../../data/models/lesson_flow.dart';
import '../../data/models/vocab_item.dart';
import '../../data/di/repository_provider.dart';

// ─────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────

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

  int get index2 {
    // Dùng index2 để tránh xung đột với enum.index
    return LessonStage.values.indexOf(this);
  }

  LessonStage? get next {
    final i = LessonStage.values.indexOf(this);
    if (i < LessonStage.values.length - 1) {
      return LessonStage.values[i + 1];
    }
    return null;
  }

  LessonStage? get previous {
    final i = LessonStage.values.indexOf(this);
    if (i > 0) return LessonStage.values[i - 1];
    return null;
  }
}

// ─────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────

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
  });

  final Lesson? lesson;
  final LessonStage currentStage;
  final bool isLoading;
  final String? error;

  // ─── Silent Mode ────────────────────────────
  final bool isSilentMode;

  // ─── Audio (Input Stage) ────────────────────
  final bool isAudioPlaying;
  final int audioPositionSeconds;
  final int audioDurationSeconds;
  final int currentDialogueIndex;

  // ─── Pattern Stage ──────────────────────────
  /// Key = vocab stt, Value = user's answer (VocabItem selected)
  final Map<int, VocabItem?> patternAnswers;
  final Map<int, bool> patternCorrect;

  // ─── Guided Stage ───────────────────────────
  /// Key = step index, Value = user's text answer
  final Map<int, String> guidedAnswers;

  // ─── Output Stage ───────────────────────────
  final OutputRecordingState outputRecordingState;
  final int outputRecordingSeconds;

  // ─── Progress ───────────────────────────────
  final Set<LessonStage> completedStages;

  bool get hasLesson => lesson != null;

  double get overallProgress {
    if (lesson == null) return 0;
    return completedStages.length / LessonStage.values.length;
  }

  bool isStageCompleted(LessonStage stage) =>
      completedStages.contains(stage);

  bool get canProceedFromPattern {
    if (lesson == null) return false;
    final total = lesson!.vocabulary.length;
    if (total == 0) return true;
    final correct = patternCorrect.values.where((v) => v).length;
    return correct >= (total * 0.7).ceil(); // 70% correct
  }

  bool get canProceedFromGuided {
    if (lesson == null) return false;
    final steps =
        lesson!.lessonFlow.guided.interviewSteps.length;
    if (steps == 0) return true;
    final answered =
        guidedAnswers.values.where((v) => v.trim().isNotEmpty).length;
    return answered >= (steps * 0.6).ceil(); // 60% answered
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
    bool clearError = false,
  }) {
    return LessonState(
      lesson: lesson ?? this.lesson,
      currentStage: currentStage ?? this.currentStage,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSilentMode: isSilentMode ?? this.isSilentMode,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
      audioPositionSeconds:
          audioPositionSeconds ?? this.audioPositionSeconds,
      audioDurationSeconds:
          audioDurationSeconds ?? this.audioDurationSeconds,
      currentDialogueIndex:
          currentDialogueIndex ?? this.currentDialogueIndex,
      patternAnswers: patternAnswers ?? this.patternAnswers,
      patternCorrect: patternCorrect ?? this.patternCorrect,
      guidedAnswers: guidedAnswers ?? this.guidedAnswers,
      outputRecordingState:
          outputRecordingState ?? this.outputRecordingState,
      outputRecordingSeconds:
          outputRecordingSeconds ?? this.outputRecordingSeconds,
      completedStages: completedStages ?? this.completedStages,
    );
  }
}

enum OutputRecordingState { idle, recording, recorded, playing }

// ─────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────

class LessonNotifier extends StateNotifier<LessonState> {
  LessonNotifier() : super(const LessonState());

  final _repo = RepositoryProvider.instance;

  // ─── Load ────────────────────────────────────

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
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ─── Navigation ──────────────────────────────

  void goToStage(LessonStage stage) {
    state = state.copyWith(currentStage: stage);
  }

  void nextStage() {
    // Mark current stage complete
    final completed = {...state.completedStages, state.currentStage};
    final next = state.currentStage.next;
    if (next == null) return; // Already at last stage

    // Skip output stage if silent mode
    final target = (next == LessonStage.output && state.isSilentMode)
        ? null
        : next;

    state = state.copyWith(
      completedStages: completed,
      currentStage: target ?? state.currentStage,
    );
  }

  void previousStage() {
    final prev = state.currentStage.previous;
    if (prev == null) return;
    state = state.copyWith(currentStage: prev);
  }

  // ─── Silent Mode ─────────────────────────────

  void toggleSilentMode() {
    final newMode = !state.isSilentMode;
    state = state.copyWith(
      isSilentMode: newMode,
      isAudioPlaying: newMode ? false : state.isAudioPlaying,
    );
  }

  // ─── Audio Controls (Input Stage) ────────────

  void toggleAudio() {
    if (state.isSilentMode) return;
    state = state.copyWith(
      isAudioPlaying: !state.isAudioPlaying,
    );
    // TODO: Integrate real audio player (just_audio package)
    _simulateAudioProgress();
  }

  void seekAudio(int seconds) {
    state = state.copyWith(audioPositionSeconds: seconds);
  }

  void nextDialogue() {
    final max = (state.lesson?.lessonFlow.input.sampleDialogues.length ?? 1) - 1;
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

  // ─── Pattern Stage ───────────────────────────

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
    state = state.copyWith(
      patternAnswers: {},
      patternCorrect: {},
    );
  }

  // ─── Guided Stage ────────────────────────────

  void updateGuidedAnswer(int stepIndex, String answer) {
    state = state.copyWith(
      guidedAnswers: {...state.guidedAnswers, stepIndex: answer},
    );
  }

  // ─── Output Stage (Recording simulation) ─────

  void startRecording() {
    if (state.isSilentMode) return;
    state = state.copyWith(
      outputRecordingState: OutputRecordingState.recording,
      outputRecordingSeconds: 0,
    );
    _simulateRecording();
  }

  void stopRecording() {
    state = state.copyWith(
      outputRecordingState: OutputRecordingState.recorded,
    );
  }

  void playRecording() {
    state = state.copyWith(
      outputRecordingState: OutputRecordingState.playing,
    );
  }

  void clearRecording() {
    state = state.copyWith(
      outputRecordingState: OutputRecordingState.idle,
      outputRecordingSeconds: 0,
    );
  }

  // ─── Mark complete ───────────────────────────

  void markCurrentStageComplete() {
    state = state.copyWith(
      completedStages: {...state.completedStages, state.currentStage},
    );
  }

  // ─── Simulations (replace with real impl) ────

  Future<void> _simulateAudioProgress() async {
    // Placeholder: simulate audio playing
    for (int i = state.audioPositionSeconds;
        i <= 120 && state.isAudioPlaying;
        i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      state = state.copyWith(
        audioPositionSeconds: i,
        audioDurationSeconds: 120,
      );
    }
  }

  Future<void> _simulateRecording() async {
    for (int i = 0; i < 120; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      if (state.outputRecordingState != OutputRecordingState.recording) {
        break;
      }
      state = state.copyWith(outputRecordingSeconds: i + 1);
    }
    if (state.outputRecordingState == OutputRecordingState.recording) {
      stopRecording();
    }
  }
}

// ─────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────

final lessonProvider =
    StateNotifierProvider<LessonNotifier, LessonState>(
  (ref) => LessonNotifier(),
);

/// Computed: vocabulary shuffled for pattern matching
final shuffledVocabProvider = Provider<List<VocabItem>>((ref) {
  final state = ref.watch(lessonProvider);
  if (state.lesson == null) return [];
  final vocab = [...state.lesson!.vocabulary];
  vocab.shuffle();
  return vocab;
});

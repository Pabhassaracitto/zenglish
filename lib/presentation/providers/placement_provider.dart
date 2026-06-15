import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/placement_result.dart';
import '../../logic/placement_logic.dart';

class PlacementState {
  const PlacementState({
    this.currentStep = 0,
    this.selectedMeditation,
    this.selectedPali,
    this.vocabAnswers = const {},
    this.isCalculating = false,
    this.result,
  });

  final int currentStep;
  final MeditationExperience? selectedMeditation;
  final PaliKnowledgeTier? selectedPali;
  final Map<String, int> vocabAnswers;
  final bool isCalculating;
  final PlacementResult? result;

  static const int totalSteps = 3;

  bool get isComplete => result != null;

  bool get canProceedCurrentStep {
    switch (currentStep) {
      case 0:
        return selectedMeditation != null;
      case 1:
        return selectedPali != null;
      case 2:
        return vocabAnswers.length == PlacementLogic.vocabQuestions.length;
      default:
        return false;
    }
  }

  PlacementState copyWith({
    int? currentStep,
    MeditationExperience? selectedMeditation,
    PaliKnowledgeTier? selectedPali,
    Map<String, int>? vocabAnswers,
    bool? isCalculating,
    PlacementResult? result,
  }) {
    return PlacementState(
      currentStep: currentStep ?? this.currentStep,
      selectedMeditation: selectedMeditation ?? this.selectedMeditation,
      selectedPali: selectedPali ?? this.selectedPali,
      vocabAnswers: vocabAnswers ?? this.vocabAnswers,
      isCalculating: isCalculating ?? this.isCalculating,
      result: result ?? this.result,
    );
  }
}

class PlacementNotifier extends StateNotifier<PlacementState> {
  PlacementNotifier() : super(const PlacementState());

  void selectMeditation(MeditationExperience experience) {
    state = state.copyWith(selectedMeditation: experience);
  }

  void selectPali(PaliKnowledgeTier tier) {
    state = state.copyWith(selectedPali: tier);
  }

  void answerVocabQuestion(String questionId, int selectedIndex) {
    state = state.copyWith(
      vocabAnswers: {...state.vocabAnswers, questionId: selectedIndex},
    );
  }

  void nextStep() {
    if (!state.canProceedCurrentStep) return;
    if (state.currentStep < PlacementState.totalSteps - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < PlacementState.totalSteps) {
      state = state.copyWith(currentStep: step);
    }
  }

  Future<void> calculate() async {
    if (state.selectedMeditation == null || state.selectedPali == null) return;
    state = state.copyWith(isCalculating: true);
    // Simulate brief calculation delay for UX
    await Future.delayed(const Duration(milliseconds: 800));
    final result = PlacementLogic.calculate(
      meditation: state.selectedMeditation!,
      pali: state.selectedPali!,
      vocabAnswers: state.vocabAnswers,
    );
    state = state.copyWith(
      result: result,
      isCalculating: false,
    );
  }

  void reset() {
    state = const PlacementState();
  }
}

// ─────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────

final placementProvider = StateNotifierProvider<PlacementNotifier, PlacementState>(
  (ref) => PlacementNotifier(),
);

/// Computed: số câu đúng trong vocab test
final vocabScoreProvider = Provider<int>((ref) {
  final answers = ref.watch(
    placementProvider.select((s) => s.vocabAnswers),
  );
  return PlacementLogic.vocabQuestions.where((q) {
    final a = answers[q.id];
    return a != null && q.isCorrect(a);
  }).length;
});

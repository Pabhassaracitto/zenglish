import '../core/enums/cefr_level.dart';
import '../core/enums/meditation_stage.dart';
import '../data/models/placement_result.dart';
import 'content_router.dart';

/// PlacementLogic — thuần logic, không phụ thuộc Flutter
/// Nhận 3 input → tính toán UserProfile coordinates
class PlacementLogic {
  PlacementLogic._();

  // ─────────────────────────────────────────────
  // VOCAB QUESTIONS BANK
  // ─────────────────────────────────────────────
  static const List<VocabQuestion> vocabQuestions = [
    VocabQuestion(
      id: 'q1',
      wordEn: 'monastery',
      contextHint:
          '"I am staying at a ___ for one month to practice meditation."',
      options: [
        'Nhà hàng',
        'Thiền viện / Tu viện',
        'Thư viện',
        'Bệnh viện',
      ],
      correctIndex: 1,
    ),
    VocabQuestion(
      id: 'q2',
      wordEn: 'schedule',
      contextHint:
          '"Can I see the ___ for the day? I want to know when to sit."',
      options: [
        'Chìa khóa',
        'Đồ ăn',
        'Lịch trình',
        'Hóa đơn',
      ],
      correctIndex: 2,
    ),
    VocabQuestion(
      id: 'q3',
      wordEn: 'report',
      contextHint:
          '"Bhante, may I ___ my practice to you?"',
      options: [
        'Hủy bỏ',
        'Trình bày / Báo cáo',
        'Mua sắm',
        'Nghỉ ngơi',
      ],
      correctIndex: 1,
    ),
  ];

  // ─────────────────────────────────────────────
  // CORE CALCULATION
  // ─────────────────────────────────────────────

  /// Điểm vào duy nhất — tính toán PlacementResult
  static PlacementResult calculate({
    required MeditationExperience meditation,
    required PaliKnowledgeTier pali,
    required Map<String, int> vocabAnswers,
  }) {
    final vocabScore = calculateVocabScore(vocabAnswers);
    final langLevel = deriveLanguageLevel(vocabScore, pali);
    final stage = meditation.toMeditationStage();
    final paliLevel = derivePaliLevel(pali, meditation);
    final lessonId = ContentRouter.getStartLesson(
      languageLevel: langLevel,
      meditationStage: stage,
      paliLevel: paliLevel,
      meditationExperience: meditation,
    );
    final fastTracked = isFastTracked(
      meditation: meditation,
      langLevel: langLevel,
    );

    return PlacementResult(
      meditationExperience: meditation,
      paliTier: pali,
      vocabScore: vocabScore,
      vocabAnswers: vocabAnswers,
      derivedLanguageLevel: langLevel,
      derivedMeditationStage: stage,
      derivedPaliLevel: paliLevel,
      recommendedStartLessonId: lessonId,
      fastTracked: fastTracked,
    );
  }

  // ─────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────

  static int calculateVocabScore(Map<String, int> answers) {
    int correct = 0;
    for (final q in vocabQuestions) {
      final answer = answers[q.id];
      if (answer != null && q.isCorrect(answer)) correct++;
    }
    return correct;
  }

  /// Trục 1: Language Level
  /// Kết hợp vocab score + pali knowledge
  /// (Pāḷi knowledge là proxy tốt cho reading comprehension
  /// trong ngữ cảnh thiền viện)
  static CEFRLevel deriveLanguageLevel(
    int vocabScore,
    PaliKnowledgeTier pali,
  ) {
    // Vocab 0/3 = A1 baseline
    // Vocab 1/3 = A1
    // Vocab 2/3 = A2
    // Vocab 3/3 = B1
    // Pali bonus:
    // semantic + vocab 2+ → B1
    // phonetic + vocab 2+ → A2
    // none → no bonus
    if (vocabScore == 3) {
      return CEFRLevel.b1;
    }
    if (vocabScore == 2) {
      switch (pali) {
        case PaliKnowledgeTier.semantic:
          return CEFRLevel.b1;
        case PaliKnowledgeTier.phonetic:
          return CEFRLevel.a2;
        case PaliKnowledgeTier.none:
          return CEFRLevel.a2;
      }
    }
    if (vocabScore == 1) {
      return pali == PaliKnowledgeTier.semantic
          ? CEFRLevel.a2
          : CEFRLevel.a1;
    }
    // vocabScore == 0
    return CEFRLevel.a1;
  }

  /// Trục 3: Pāḷi Level (0–5)
  /// Pali tier + meditation experience kết hợp
  static int derivePaliLevel(
    PaliKnowledgeTier pali,
    MeditationExperience meditation,
  ) {
    int base = pali.toKnowledgeLevel();
    // Meditation bonus: người tu lâu thường biết Pāḷi hơn họ nghĩ
    switch (meditation) {
      case MeditationExperience.samathaAdvanced:
      case MeditationExperience.vipassanaActive:
      case MeditationExperience.longTermPractitioner:
        base = (base + 1).clamp(0, 5);
        break;
      default:
        break;
    }
    return base;
  }

  /// Fast-track: người tu lâu nhưng tiếng Anh kém
  /// → vẫn được đề xuất bài nâng cao về thiền
  /// nhưng ở cấp ngôn ngữ thấp hơn
  static bool isFastTracked({
    required MeditationExperience meditation,
    required CEFRLevel langLevel,
  }) {
    final isAdvancedMeditator = [
      MeditationExperience.samathaAdvanced,
      MeditationExperience.vipassanaActive,
      MeditationExperience.longTermPractitioner,
    ].contains(meditation);
    final isLowEnglish = [
      CEFRLevel.a1,
      CEFRLevel.a2,
    ].contains(langLevel);
    return isAdvancedMeditator && isLowEnglish;
  }
}

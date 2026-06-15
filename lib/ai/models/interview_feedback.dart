/// Kết quả phân tích từ AIInterviewEngine
/// Đủ thông tin để hiển thị feedback có nghĩa
/// mà không phán xét kinh nghiệm thiền của người dùng
class InterviewFeedback {
  const InterviewFeedback({
    required this.isAuthentic,
    required this.overallScore,
    required this.checkResults,
    required this.missingPoints,
    required this.presentPoints,
    required this.languageFeedback,
    required this.semanticHint,
    required this.encouragement,
    required this.suggestedNextStep,
    this.detectedKeywords = const [],
    this.rawTranscript = '',
  });

  /// true nếu transcript có đủ dấu hiệu trình pháp thật
  final bool isAuthentic;

  /// Điểm tổng thể (0–100)
  final int overallScore;

  /// Kết quả từng điểm trong 5-Point Check
  final List<CheckResult> checkResults;

  /// Điểm còn thiếu
  final List<String> missingPoints;

  /// Điểm đã có
  final List<String> presentPoints;

  /// Nhận xét về ngôn ngữ (cách diễn đạt)
  final String languageFeedback;

  /// Gợi ý về trạng thái thiền (không phán xét)
  final SemanticHint semanticHint;

  /// Lời khuyến khích ngắn
  final String encouragement;

  /// Gợi ý bước tiếp theo
  final String suggestedNextStep;

  /// Từ khoá được nhận diện trong transcript
  final List<String> detectedKeywords;

  /// Transcript gốc (để hiển thị)
  final String rawTranscript;

  /// Phần trăm điểm check pass
  double get passRate =>
      checkResults.isEmpty
          ? 0
          : checkResults.where((c) => c.passed).length /
              checkResults.length;

  bool get needsImprovement => overallScore < 60;
  bool get isGoodReport => overallScore >= 75;

  /// Factory: empty (trước khi phân tích)
  factory InterviewFeedback.empty() => const InterviewFeedback(
        isAuthentic: false,
        overallScore: 0,
        checkResults: [],
        missingPoints: [],
        presentPoints: [],
        languageFeedback: '',
        semanticHint: SemanticHint.none(),
        encouragement: '',
        suggestedNextStep: '',
      );

  /// Factory: loading state
  factory InterviewFeedback.analyzing() => const InterviewFeedback(
        isAuthentic: false,
        overallScore: 0,
        checkResults: [],
        missingPoints: [],
        presentPoints: [],
        languageFeedback: 'Đang phân tích...',
        semanticHint: SemanticHint.none(),
        encouragement: '',
        suggestedNextStep: '',
      );
}

// ─────────────────────────────────────────────
// CHECK RESULT
// ─────────────────────────────────────────────

class CheckResult {
  const CheckResult({
    required this.checkName,
    required this.checkNameVi,
    required this.passed,
    required this.description,
    required this.tip,
    this.detectedValue,
  });

  /// Tên điểm check (ngắn)
  final String checkName;
  final String checkNameVi;

  /// Pass hay không
  final bool passed;

  /// Mô tả kết quả
  final String description;

  /// Gợi ý cải thiện
  final String tip;

  /// Giá trị nhận diện được (nếu có)
  final String? detectedValue;
}

// ─────────────────────────────────────────────
// SEMANTIC HINT
// ─────────────────────────────────────────────

enum SemanticHintLevel {
  none,
  suggestion,   // Có thể...
  possible,     // Có dấu hiệu của...
  noteworthy,   // Đáng chú ý
}

class SemanticHint {
  const SemanticHint({
    required this.level,
    required this.titleEn,
    required this.titleVi,
    required this.body,
    required this.paliTerm,
    required this.paliRomanized,
    this.teacherNote,
  });

  final SemanticHintLevel level;
  final String titleEn;
  final String titleVi;
  final String body;
  final String paliTerm;
  final String paliRomanized;

  /// Ghi chú dành cho thiền sư (nếu cần review)
  final String? teacherNote;

  bool get hasContent => level != SemanticHintLevel.none;

  const factory SemanticHint.none() = _NoSemanticHint;
}

class _NoSemanticHint extends SemanticHint {
  const _NoSemanticHint()
      : super(
          level: SemanticHintLevel.none,
          titleEn: '',
          titleVi: '',
          body: '',
          paliTerm: '',
          paliRomanized: '',
        );
}

// ─────────────────────────────────────────────
// PREDEFINED SEMANTIC HINTS
// ─────────────────────────────────────────────

abstract class SemanticHints {
  static const stillnessSign = SemanticHint(
    level: SemanticHintLevel.suggestion,
    titleEn: 'Stillness observed',
    titleVi: 'Có dấu hiệu tĩnh lặng',
    body:
        'You used words like "quiet", "still", or "calm". '
        'This may indicate the mind is beginning to settle. '
        'Continue watching the breath without forcing anything.',
    paliTerm: 'samādhi',
    paliRomanized: 'sa-maa-di',
    teacherNote:
        'User reports stillness — verify if samādhi is stable.',
  );

  static const uggahaNimitta = SemanticHint(
    level: SemanticHintLevel.possible,
    titleEn: 'Possible uggaha nimitta',
    titleVi: 'Có thể là uggaha nimitta',
    body:
        'You described something like white, gray, or smoke-like. '
        'This may be the uggaha nimitta (learning sign). '
        'Report this carefully to your teacher. '
        'Do not grasp it or try to make it stay.',
    paliTerm: 'uggaha nimitta',
    paliRomanized: 'ug-ga-ha ni-mit-ta',
    teacherNote:
        '[NEEDS REVIEW] User reports early nimitta signs — '
        'confirm with teacher.',
  );

  static const patibhagaNimitta = SemanticHint(
    level: SemanticHintLevel.noteworthy,
    titleEn: 'Possible paṭibhāga nimitta',
    titleVi: 'Có thể là paṭibhāga nimitta',
    body:
        'You described a bright, clear, and stable sign. '
        'This may be the paṭibhāga nimitta (counterpart sign). '
        'This is a significant moment — report it precisely to your teacher. '
        'Stay with it. Do not move the mind away.',
    paliTerm: 'paṭibhāga nimitta',
    paliRomanized: 'pa-ti-bhaa-ga ni-mit-ta',
    teacherNote:
        '[NEEDS REVIEW] User reports bright stable nimitta — '
        'teacher should verify upacāra samādhi.',
  );

  static const accessConcentration = SemanticHint(
    level: SemanticHintLevel.possible,
    titleEn: 'Possible access concentration',
    titleVi: 'Có thể là cận định',
    body:
        'Your report suggests the mind may be approaching '
        'upacāra samādhi (access concentration). '
        'The mind becomes very quiet and the object is clear. '
        'Keep your attention steady — do not force entry.',
    paliTerm: 'upacāra samādhi',
    paliRomanized: 'u-pa-chaa-ra sa-maa-di',
    teacherNote:
        '[NEEDS REVIEW] User may be approaching access concentration.',
  );

  static const jhanaSign = SemanticHint(
    level: SemanticHintLevel.noteworthy,
    titleEn: 'Possible jhāna experience',
    titleVi: 'Có thể là kinh nghiệm jhāna',
    body:
        'You described absorption, floating, or very deep stillness. '
        'This may be related to jhāna. '
        'Report this very carefully to your teacher '
        'with exact details: how long, what you felt, '
        'whether thinking stopped.',
    paliTerm: 'jhāna',
    paliRomanized: 'jhaa-na',
    teacherNote:
        '[NEEDS REVIEW] User reports possible jhāna — '
        'teacher must verify carefully.',
  );

  static const vipassanaProgress = SemanticHint(
    level: SemanticHintLevel.suggestion,
    titleEn: 'Vipassanā observation noted',
    titleVi: 'Ghi nhận quan sát vipassanā',
    body:
        'You described arising and passing, impermanence, '
        'or no-self. This shows vipassanā practice is active. '
        'Continue observing clearly — '
        'report each specific observation to your teacher.',
    paliTerm: 'vipassanā',
    paliRomanized: 'vi-pas-sa-naa',
    teacherNote: null,
  );

  static const physicalDifficulty = SemanticHint(
    level: SemanticHintLevel.suggestion,
    titleEn: 'Physical difficulty noted',
    titleVi: 'Ghi nhận khó khăn thể chất',
    body:
        'You mentioned physical discomfort (pain, numbness, or fatigue). '
        'Make sure to report this to the teacher at the start of the interview, '
        'before reporting your meditation object.',
    paliTerm: 'dukkha-vedanā',
    paliRomanized: 'duk-kha ve-da-naa',
    teacherNote: null,
  );
}

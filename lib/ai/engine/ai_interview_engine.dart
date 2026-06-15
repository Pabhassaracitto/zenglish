import '../../core/constants/dhamma_keywords.dart';
import '../../data/models/lesson.dart';
import '../models/interview_feedback.dart';
import 'analyzers/opening_analyzer.dart';
import 'analyzers/object_analyzer.dart';
import 'analyzers/location_analyzer.dart';
import 'analyzers/difficulty_analyzer.dart';
import 'analyzers/semantic_hint_analyzer.dart';
import 'mock/mock_response_builder.dart';

/// AIInterviewEngine — Mock Version
/// 
/// Architecture:
/// [Transcript] → [5 Analyzers] → [ScoreEngine] → [InterviewFeedback]
/// 
/// Mỗi Analyzer độc lập → dễ swap sang LLM API sau này
/// 
/// Nguyên tắc an toàn Pháp học:
/// - Engine CHỈ mô tả — không kết luận kinh nghiệm
/// - SemanticHint dùng "possible" không phải "you have"
/// - Mọi insight đều nhắc "report to teacher"
class AIInterviewEngine {

  // ─── Singleton (stateless) ───────────────────

  AIInterviewEngine._();
  static final AIInterviewEngine instance = AIInterviewEngine._();

  // ─────────────────────────────────────────────
  // MAIN ENTRY POINT
  // ─────────────────────────────────────────────

  /// Phân tích transcript và trả về InterviewFeedback
  /// 
  /// [userTranscript] — văn bản người dùng nói/nhập
  /// [currentLesson] — bài học hiện tại (để context-aware analysis)
  Future<InterviewFeedback> analyzeReport({
    required String userTranscript,
    required Lesson currentLesson,
  }) async {
    // Simulate processing time (replace with real API call)
    await Future.delayed(const Duration(milliseconds: 600));

    if (userTranscript.trim().isEmpty) {
      return _emptyTranscriptFeedback();
    }

    final transcript = userTranscript.trim();
    final lower = transcript.toLowerCase();

    // ─── Run all 5 analyzers ──────────────────

    final openingResult  = OpeningAnalyzer.analyze(transcript);
    final objectResult   = ObjectAnalyzer.analyze(transcript);
    final locationResult = LocationAnalyzer.analyze(transcript);
    final difficultyResult = DifficultyAnalyzer.analyze(transcript);
    final questionResult = _analyzeQuestion(transcript);

    final checkResults = [
      openingResult,
      objectResult,
      locationResult,
      difficultyResult,
      questionResult,
    ];

    // ─── Semantic hint ────────────────────────

    final semanticHint = SemanticHintAnalyzer.analyze(transcript);

    // ─── Detect keywords ─────────────────────

    final detectedKeywords = _detectKeywords(lower);

    // ─── Check Pāḷi terms ─────────────────────

    final hasPaliTerms = _hasPaliTerms(lower);

    // ─── Check question ───────────────────────

    final hasQuestion = questionResult.passed;

    // ─── Word count ───────────────────────────

    final wordCount = transcript
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;

    // ─── Score ────────────────────────────────

    final score = MockResponseBuilder.calculateScore(
      results: checkResults,
      hasPaliTerms: hasPaliTerms,
      wordCount: wordCount,
      hasQuestion: hasQuestion,
    );

    // ─── Missing / present points ─────────────

    final missing = checkResults
        .where((r) => !r.passed)
        .map((r) => r.checkNameVi)
        .toList();

    final present = checkResults
        .where((r) => r.passed)
        .map((r) => r.checkNameVi)
        .toList();

    // ─── Language feedback ────────────────────

    final langFeedback = MockResponseBuilder.buildLanguageFeedback(
      results: checkResults,
      hasOpeningWithBhante: openingResult.passed,
      hasClearObject: objectResult.passed,
      hasPaliTerms: hasPaliTerms,
      wordCount: wordCount,
    );

    // ─── Encouragement ────────────────────────

    final encouragement = MockResponseBuilder.buildEncouragement(
      overallScore: score,
      isFirstTime: currentLesson.lessonNumber <= 1,
      hasDifficulty: difficultyResult.passed,
    );

    // ─── Next step ────────────────────────────

    final nextStep = MockResponseBuilder.buildNextStep(
      missingPoints: missing,
      hint: semanticHint,
      hasQuestion: hasQuestion,
    );

    // ─── Authenticity check ───────────────────

    final isAuthentic = _checkAuthenticity(
      checkResults: checkResults,
      wordCount: wordCount,
      hasPaliTerms: hasPaliTerms,
    );

    return InterviewFeedback(
      isAuthentic: isAuthentic,
      overallScore: score,
      checkResults: checkResults,
      missingPoints: missing,
      presentPoints: present,
      languageFeedback: langFeedback,
      semanticHint: semanticHint,
      encouragement: encouragement,
      suggestedNextStep: nextStep,
      detectedKeywords: detectedKeywords,
      rawTranscript: transcript,
    );
  }

  // ─────────────────────────────────────────────
  // PRIVATE ANALYZERS
  // ─────────────────────────────────────────────

  CheckResult _analyzeQuestion(String transcript) {
    final lower = transcript.toLowerCase();
    bool hasQuestion = false;
    String? detected;

    for (final indicator in DhammaKeywords.questionIndicators) {
      if (lower.contains(indicator)) {
        hasQuestion = true;
        detected = indicator == '?' ? 'Câu hỏi kết thúc bằng "?"' : indicator;
        break;
      }
    }

    return CheckResult(
      checkName: 'Question',
      checkNameVi: 'Câu Hỏi / Xin Chỉ Dạy',
      passed: hasQuestion,
      detectedValue: detected,
      description: hasQuestion
          ? 'Tốt — có câu hỏi hoặc xin xác nhận.'
          : 'Chưa có câu hỏi — tùy chọn nhưng hữu ích.',
      tip: hasQuestion
          ? 'Câu hỏi tốt — rõ ràng, cụ thể, liên quan '
            'đến thực hành hiện tại.'
          : 'Có thể kết thúc bằng: '
            '"Bhante, when the breath becomes subtle, '
            'what should I do?" '
            'Một câu hỏi cụ thể giúp thiền sư hướng dẫn hiệu quả hơn.',
    );
  }

  List<String> _detectKeywords(String lower) {
    final keywords = <String>[];

    // Samatha objects
    for (final kw in DhammaKeywords.samathaObjects) {
      if (lower.contains(kw) && !keywords.contains(kw)) {
        keywords.add(kw);
      }
    }

    // Locations
    for (final kw in DhammaKeywords.paAukLocations) {
      if (lower.contains(kw) && !keywords.contains(kw)) {
        keywords.add(kw);
      }
    }

    // Semantic indicators (sample)
    for (final kw in [
      ...DhammaKeywords.stillnessIndicators,
      ...DhammaKeywords.jhanaIndicators,
    ]) {
      if (lower.contains(kw) && !keywords.contains(kw)) {
        keywords.add(kw);
      }
    }

    return keywords.take(10).toList(); // Cap at 10
  }

  bool _hasPaliTerms(String lower) {
    const paliMarkers = [
      'ānāpāna', 'anapana', 'nimitta', 'samādhi', 'samadhi',
      'jhāna', 'jhana', 'pīti', 'piti', 'sukha', 'upekkhā',
      'upekkha', 'vitakka', 'vicāra', 'vicara', 'sīla', 'sila',
      'vipassanā', 'vipassana', 'nīvaraṇa', 'nivarana',
      'bhante', 'kammaṭṭhāna', 'kammatthana', 'phassa',
    ];
    return paliMarkers.any((p) => lower.contains(p));
  }

  bool _checkAuthenticity({
    required List<CheckResult> checkResults,
    required int wordCount,
    required bool hasPaliTerms,
  }) {
    // Cần ít nhất 3/5 checks pass + > 15 từ
    final passCount = checkResults.where((r) => r.passed).length;
    return passCount >= 3 && wordCount >= 15;
  }

  InterviewFeedback _emptyTranscriptFeedback() {
    return const InterviewFeedback(
      isAuthentic: false,
      overallScore: 0,
      checkResults: [],
      missingPoints: ['Nội dung trống'],
      presentPoints: [],
      languageFeedback: 'Không có nội dung để phân tích.',
      semanticHint: SemanticHint.none(),
      encouragement: 'Hãy thử nói hoặc nhập báo cáo của bạn.',
      suggestedNextStep:
          'Bắt đầu bằng: "Bhante, may I report my sitting?"',
      rawTranscript: '',
    );
  }
}

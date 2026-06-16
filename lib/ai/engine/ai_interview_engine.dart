/// lib/ai/engine/ai_interview_engine.dart
///
/// AIInterviewEngine — Production Version with Mock Fallback
///
/// Strategy:
///   PRIMARY   → OpenAIService (nếu API Key hợp lệ)
///   FALLBACK  → 5 Analyzers + MockResponseBuilder (nếu key trống hoặc lỗi)
///
/// UI layer KHÔNG biết đang chạy nhánh nào.
/// LessonNotifier.analyzeInterview() chỉ cần await kết quả.
///
/// Dhamma Safety (áp dụng cho cả 2 nhánh):
///   - Không kết luận trạng thái thiền
///   - SemanticHint luôn dùng ngôn ngữ "possible / may indicate"
///   - Mọi insight đều nhắc "report to teacher"
library;

import '../../core/constants/dhamma_keywords.dart';
import '../../core/env/env.dart';
import '../../data/models/lesson.dart';
import '../models/interview_feedback.dart';
import '../services/openai_service.dart';
import '../parsers/openai_response_parser.dart';

// Analyzers (Mock fallback path)
import 'analyzers/opening_analyzer.dart';
import 'analyzers/object_analyzer.dart';
import 'analyzers/location_analyzer.dart';
import 'analyzers/difficulty_analyzer.dart';
import 'analyzers/semantic_hint_analyzer.dart';
import 'mock/mock_response_builder.dart';

class AIInterviewEngine {
  // ─────────────────────────────────────────────
  // CONSTRUCTOR & SINGLETON
  // ─────────────────────────────────────────────

  /// Cho phép inject dependencies để viết unit test dễ dàng.
  /// Production dùng singleton [instance].
  AIInterviewEngine({OpenAIService? openAIService})
      : _openAIService = openAIService ?? OpenAIService();

  static final AIInterviewEngine instance = AIInterviewEngine();

  final OpenAIService _openAIService;

  // ─────────────────────────────────────────────
  // MAIN ENTRY POINT
  // ─────────────────────────────────────────────

  /// Phân tích transcript → InterviewFeedback.
  ///
  /// Tự động chọn nhánh:
  ///   • API Key hợp lệ → OpenAI
  ///   • API Key trống  → Mock (không cần log warning, đây là expected)
  ///   • OpenAI lỗi    → Mock (fallback tự động, UI không bị crash)
  ///
  /// KHÔNG bao giờ throw exception ra ngoài.
  Future<InterviewFeedback> analyzeReport({
    required String userTranscript,
    required Lesson currentLesson,
  }) async {
    if (userTranscript.trim().isEmpty) {
      return _emptyTranscriptFeedback();
    }

    final transcript = userTranscript.trim();

    // ─── Chọn nhánh ──────────────────────────

    if (Env.isConfigured) {
      return _analyzeWithOpenAI(
        transcript: transcript,
        currentLesson: currentLesson,
      );
    }

    // Key trống → chạy Mock ngay, không cần thử OpenAI
    _log('API Key not configured → running Mock analyzers');
    return _analyzeWithMock(
      transcript: transcript,
      currentLesson: currentLesson,
    );
  }

  // ─────────────────────────────────────────────
  // NHÁNH 1: OPENAI
  // ─────────────────────────────────────────────

  Future<InterviewFeedback> _analyzeWithOpenAI({
    required String transcript,
    required Lesson currentLesson,
  }) async {
    try {
      _log('Calling OpenAI API...');

      final jsonString = await _openAIService.analyzeReport(
        userTranscript: transcript,
        currentLesson: currentLesson,
      );

      final parseResult = OpenAIResponseParser.parse(jsonString);

      if (parseResult.hasError) {
        // JSON từ OpenAI không parse được → fallback
        _log(
          'Parse error: ${parseResult.errorMessage} → falling back to Mock',
        );
        return _analyzeWithMock(
          transcript: transcript,
          currentLesson: currentLesson,
        );
      }

      _log('OpenAI analysis successful (score: ${parseResult.feedback.overallScore})');

      // Inject rawTranscript — field này không có trong AI response
      return _injectTranscript(parseResult.feedback, transcript);

    } on OpenAITimeoutError {
      _log('OpenAI timeout → falling back to Mock');
      return _analyzeWithMock(
        transcript: transcript,
        currentLesson: currentLesson,
        fallbackNote: 'Phân tích nhanh (AI timeout — dùng phân tích cục bộ)',
      );

    } on OpenAINetworkError catch (e) {
      _log('Network error: ${e.message} → falling back to Mock');
      return _analyzeWithMock(
        transcript: transcript,
        currentLesson: currentLesson,
        fallbackNote: 'Phân tích nhanh (không có mạng — dùng phân tích cục bộ)',
      );

    } on OpenAIHttpError catch (e) {
      _log('HTTP ${e.statusCode} → falling back to Mock');
      return _analyzeWithMock(
        transcript: transcript,
        currentLesson: currentLesson,
        // Rate limit và quota cần thông báo riêng, các lỗi khác fallback im lặng
        fallbackNote: e.isRateLimit || e.isQuotaExceeded
            ? 'Phân tích nhanh (AI đang bận — dùng phân tích cục bộ)'
            : null,
      );

    } on OpenAIConfigError catch (e) {
      _log('Config error: ${e.message} → falling back to Mock');
      return _analyzeWithMock(
        transcript: transcript,
        currentLesson: currentLesson,
      );

    } catch (e) {
      _log('Unexpected error: $e → falling back to Mock');
      return _analyzeWithMock(
        transcript: transcript,
        currentLesson: currentLesson,
      );
    }
  }

  // ─────────────────────────────────────────────
  // NHÁNH 2: MOCK (5 ANALYZERS)
  // ─────────────────────────────────────────────

  /// Chạy toàn bộ 5 Analyzer cũ và build InterviewFeedback.
  ///
  /// [fallbackNote]: Nếu không null, append vào languageFeedback
  /// để UI có thể hiển thị "đang dùng phân tích cục bộ" nếu muốn.
  /// UI hiện tại KHÔNG cần xử lý gì thêm — field này chỉ là text.
  Future<InterviewFeedback> _analyzeWithMock({
    required String transcript,
    required Lesson currentLesson,
    String? fallbackNote,
  }) async {
    // Simulate processing time — giữ UX nhất quán với OpenAI path
    await Future.delayed(const Duration(milliseconds: 600));

    final lower = transcript.toLowerCase();

    // ─── Run 5 Analyzers ──────────────────────

    final openingResult    = OpeningAnalyzer.analyze(transcript);
    final objectResult     = ObjectAnalyzer.analyze(transcript);
    final locationResult   = LocationAnalyzer.analyze(transcript);
    final difficultyResult = DifficultyAnalyzer.analyze(transcript);
    final questionResult   = _analyzeQuestion(transcript);

    final checkResults = [
      openingResult,
      objectResult,
      locationResult,
      difficultyResult,
      questionResult,
    ];

    // ─── Semantic hint ────────────────────────

    final semanticHint = SemanticHintAnalyzer.analyze(transcript);

    // ─── Keyword detection ────────────────────

    final detectedKeywords = _detectKeywords(lower);

    // ─── Computed flags ───────────────────────

    final hasPaliTerms = _hasPaliTerms(lower);
    final hasQuestion  = questionResult.passed;
    final wordCount    = _wordCount(transcript);

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

    var langFeedback = MockResponseBuilder.buildLanguageFeedback(
      results: checkResults,
      hasOpeningWithBhante: openingResult.passed,
      hasClearObject: objectResult.passed,
      hasPaliTerms: hasPaliTerms,
      wordCount: wordCount,
    );

    // Append fallback note nếu có (do lỗi OpenAI)
    if (fallbackNote != null) {
      langFeedback = '$langFeedback\n\n⚠ $fallbackNote.';
    }

    // ─── Encouragement & Next step ────────────

    final encouragement = MockResponseBuilder.buildEncouragement(
      overallScore: score,
      isFirstTime: currentLesson.lessonNumber <= 1,
      hasDifficulty: difficultyResult.passed,
    );

    final nextStep = MockResponseBuilder.buildNextStep(
      missingPoints: missing,
      hint: semanticHint,
      hasQuestion: hasQuestion,
    );

    // ─── Authenticity ─────────────────────────

    final isAuthentic = _checkAuthenticity(
      checkResults: checkResults,
      wordCount: wordCount,
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
  // SHARED PRIVATE HELPERS
  // ─────────────────────────────────────────────

  /// Inject rawTranscript vào feedback đến từ OpenAI.
  /// AI response không chứa transcript gốc.
  InterviewFeedback _injectTranscript(
    InterviewFeedback feedback,
    String transcript,
  ) {
    return InterviewFeedback(
      isAuthentic: feedback.isAuthentic,
      overallScore: feedback.overallScore,
      checkResults: feedback.checkResults,
      missingPoints: feedback.missingPoints,
      presentPoints: feedback.presentPoints,
      languageFeedback: feedback.languageFeedback,
      semanticHint: feedback.semanticHint,
      encouragement: feedback.encouragement,
      suggestedNextStep: feedback.suggestedNextStep,
      detectedKeywords: feedback.detectedKeywords,
      rawTranscript: transcript,
    );
  }

  // ─── Question Analyzer (dùng trong Mock path) ─

  CheckResult _analyzeQuestion(String transcript) {
    final lower = transcript.toLowerCase();
    bool hasQuestion = false;
    String? detected;

    for (final indicator in DhammaKeywords.questionIndicators) {
      if (lower.contains(indicator)) {
        hasQuestion = true;
        detected = indicator == '?'
            ? 'Câu hỏi kết thúc bằng "?"'
            : indicator;
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
            'what should I do?"',
    );
  }

  // ─── Keyword detection (dùng trong Mock path) ─

  List<String> _detectKeywords(String lower) {
    final keywords = <String>[];

    for (final kw in [
      ...DhammaKeywords.samathaObjects,
      ...DhammaKeywords.paAukLocations,
      ...DhammaKeywords.stillnessIndicators,
      ...DhammaKeywords.jhanaIndicators,
    ]) {
      if (lower.contains(kw) && !keywords.contains(kw)) {
        keywords.add(kw);
      }
    }

    return keywords.take(10).toList();
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

  int _wordCount(String transcript) =>
      transcript.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  bool _checkAuthenticity({
    required List<CheckResult> checkResults,
    required int wordCount,
  }) {
    final passCount = checkResults.where((r) => r.passed).length;
    return passCount >= 3 && wordCount >= 15;
  }

  // ─────────────────────────────────────────────
  // EMPTY TRANSCRIPT
  // ─────────────────────────────────────────────

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

  // ─────────────────────────────────────────────
  // LOGGING
  // ─────────────────────────────────────────────

  void _log(String message) {
    assert(
      () {
        // ignore: avoid_print
        print('[AIInterviewEngine] $message');
        return true;
      }(),
    );
  }
}

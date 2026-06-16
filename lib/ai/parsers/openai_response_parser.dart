/// lib/ai/parsers/openai_response_parser.dart
/// 
/// Parse JSON string từ OpenAI → InterviewFeedback object.
/// 
/// Nguyên tắc defensive parsing:
/// - Mọi field đều có fallback an toàn
/// - Không throw exception khi parse — trả về safe feedback
/// - Log warning khi có field bất thường
/// - SemanticHint map từ string type → SemanticHint object
library;

import 'dart:convert';
import '../models/interview_feedback.dart';

class OpenAIResponseParser {
  OpenAIResponseParser._();

  /// Parse JSON string → InterviewFeedback
  /// 
  /// KHÔNG throw exception — trả về safe fallback nếu parse thất bại.
  /// Dùng [parseResult.hasError] để kiểm tra kết quả.
  static ParseResult parse(String jsonString) {
    try {
      final raw = jsonDecode(jsonString);

      if (raw is! Map<String, dynamic>) {
        return ParseResult.failure(
          'Response is not a JSON object',
          rawString: jsonString,
        );
      }

      final feedback = _mapToFeedback(raw);
      return ParseResult.success(feedback);
    } on FormatException catch (e) {
      return ParseResult.failure(
        'Invalid JSON: ${e.message}',
        rawString: jsonString,
      );
    } catch (e) {
      return ParseResult.failure(
        'Unexpected parse error: $e',
        rawString: jsonString,
      );
    }
  }

  // ─────────────────────────────────────────────
  // MAPPING
  // ─────────────────────────────────────────────

  static InterviewFeedback _mapToFeedback(Map<String, dynamic> raw) {
    final checkResults = _parseCheckResults(raw['checkResults']);
    final missingPoints = _parseStringList(raw['missingPoints']);
    final presentPoints = _parseStringList(raw['presentPoints']);
    final detectedKeywords = _parseStringList(raw['detectedKeywords']);
    final semanticHint = _parseSemanticHint(
      raw['semanticHintType'] as String? ?? 'none',
    );

    return InterviewFeedback(
      isAuthentic: raw['isAuthentic'] as bool? ?? false,
      overallScore: _clampScore(raw['overallScore']),
      checkResults: checkResults,
      missingPoints: missingPoints,
      presentPoints: presentPoints,
      languageFeedback:
          raw['languageFeedback'] as String? ?? '',
      semanticHint: semanticHint,
      encouragement: raw['encouragement'] as String? ?? '',
      suggestedNextStep:
          raw['suggestedNextStep'] as String? ?? '',
      detectedKeywords: detectedKeywords,
      // rawTranscript được inject bởi Engine (không có trong AI response)
      rawTranscript: '',
    );
  }

  static List<CheckResult> _parseCheckResults(dynamic raw) {
    if (raw is! List) return _defaultCheckResults();

    try {
      return raw
          .cast<Map<String, dynamic>>()
          .map(_parseCheckResult)
          .toList();
    } catch (_) {
      return _defaultCheckResults();
    }
  }

  static CheckResult _parseCheckResult(Map<String, dynamic> raw) {
    return CheckResult(
      checkName: raw['checkName'] as String? ?? 'Unknown',
      checkNameVi: raw['checkNameVi'] as String? ?? 'Không xác định',
      passed: raw['passed'] as bool? ?? false,
      description: raw['description'] as String? ?? '',
      tip: raw['tip'] as String? ?? '',
      detectedValue: raw['detectedValue'] as String?,
    );
  }

  static SemanticHint _parseSemanticHint(String type) {
    return switch (type) {
      'stillnessSign'       => SemanticHints.stillnessSign,
      'uggahaNimitta'       => SemanticHints.uggahaNimitta,
      'patibhagaNimitta'    => SemanticHints.patibhagaNimitta,
      'accessConcentration' => SemanticHints.accessConcentration,
      'jhanaSign'           => SemanticHints.jhanaSign,
      'vipassanaProgress'   => SemanticHints.vipassanaProgress,
      'physicalDifficulty'  => SemanticHints.physicalDifficulty,
      _                     => const SemanticHint.none(),
    };
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw is! List) return [];
    return raw.whereType<String>().toList();
  }

  static int _clampScore(dynamic raw) {
    if (raw is int) return raw.clamp(0, 100);
    if (raw is double) return raw.round().clamp(0, 100);
    return 0;
  }

  // ─── Fallback khi checkResults parse thất bại ─

  static List<CheckResult> _defaultCheckResults() => const [
        CheckResult(
          checkName: 'Opening',
          checkNameVi: 'Lời Mở Đầu',
          passed: false,
          description: 'Không thể phân tích.',
          tip: 'Vui lòng thử lại.',
        ),
        CheckResult(
          checkName: 'MeditationObject',
          checkNameVi: 'Đối Tượng Thiền',
          passed: false,
          description: 'Không thể phân tích.',
          tip: 'Vui lòng thử lại.',
        ),
        CheckResult(
          checkName: 'LocationSensation',
          checkNameVi: 'Vị Trí / Cảm Giác',
          passed: false,
          description: 'Không thể phân tích.',
          tip: 'Vui lòng thử lại.',
        ),
        CheckResult(
          checkName: 'Difficulties',
          checkNameVi: 'Khó Khăn',
          passed: false,
          description: 'Không thể phân tích.',
          tip: 'Vui lòng thử lại.',
        ),
        CheckResult(
          checkName: 'Question',
          checkNameVi: 'Câu Hỏi / Xin Chỉ Dạy',
          passed: false,
          description: 'Không thể phân tích.',
          tip: 'Vui lòng thử lại.',
        ),
      ];
}

// ─────────────────────────────────────────────
// PARSE RESULT
// ─────────────────────────────────────────────

/// Wrapper để truyền kết quả parse kèm error info
class ParseResult {
  const ParseResult._({
    required this.feedback,
    this.errorMessage,
    this.rawString,
  });

  factory ParseResult.success(InterviewFeedback feedback) =>
      ParseResult._(feedback: feedback);

  factory ParseResult.failure(
    String errorMessage, {
    String? rawString,
  }) =>
      ParseResult._(
        feedback: _buildErrorFeedback(errorMessage),
        errorMessage: errorMessage,
        rawString: rawString,
      );

  final InterviewFeedback feedback;
  final String? errorMessage;
  final String? rawString;

  bool get hasError => errorMessage != null;
  bool get isSuccess => !hasError;

  static InterviewFeedback _buildErrorFeedback(String error) {
    return InterviewFeedback(
      isAuthentic: false,
      overallScore: 0,
      checkResults: OpenAIResponseParser._defaultCheckResults(),
      missingPoints: ['Lỗi phân tích'],
      presentPoints: [],
      languageFeedback:
          'Không thể phân tích phản hồi từ AI. Vui lòng thử lại.',
      semanticHint: const SemanticHint.none(),
      encouragement: 'Đừng lo — hãy thử lại sau vài giây.',
      suggestedNextStep: 'Kiểm tra kết nối mạng và thử lại.',
      rawTranscript: '',
    );
  }
}

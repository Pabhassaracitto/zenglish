import '../../../core/constants/dhamma_keywords.dart';
import '../../models/interview_feedback.dart';

/// Phân tích ngữ nghĩa sâu hơn —
/// Phát hiện dấu hiệu trạng thái thiền
/// và trả về SemanticHint phù hợp
/// 
/// Nguyên tắc quan trọng:
/// - KHÔNG xác nhận kinh nghiệm — chỉ GỢI Ý
/// - KHÔNG nói "you have jhāna" — chỉ "possible"
/// - Luôn chỉ dẫn hỏi thiền sư
class SemanticHintAnalyzer {
  static SemanticHint analyze(String transcript) {
    final lower = transcript.toLowerCase();

    // ─── Ưu tiên check theo thứ tự (cao → thấp) ──

    // 1. Jhāna signs (cao nhất — cần báo cáo ngay)
    if (_containsAny(lower, DhammaKeywords.jhanaIndicators)) {
      return SemanticHints.jhanaSign;
    }

    // 2. Paṭibhāga nimitta (nimitta sáng, ổn định)
    if (_containsAny(lower, DhammaKeywords.patibhagaNimittaIndicators)) {
      return SemanticHints.patibhagaNimitta;
    }

    // 3. Access concentration / Upacāra
    if (_containsAny(lower, DhammaKeywords.upacamaIndicators) ||
        _containsAccessConcentrationPhrase(lower)) {
      return SemanticHints.accessConcentration;
    }

    // 4. Uggaha nimitta (nimitta sơ khởi)
    if (_containsAny(lower, DhammaKeywords.uggahaNimittaIndicators) &&
        lower.contains('nimitta')) {
      return SemanticHints.uggahaNimitta;
    }

    // 5. Stillness (tĩnh lặng — samādhi đang tiến bộ)
    if (_containsAny(lower, DhammaKeywords.stillnessIndicators) &&
        !_containsAny(lower, DhammaKeywords.hindranceWords)) {
      return SemanticHints.stillnessSign;
    }

    // 6. Vipassanā observation
    if (_containsAny(lower, DhammaKeywords.vipassanaIndicators)) {
      return SemanticHints.vipassanaProgress;
    }

    // 7. Physical difficulty
    if (_containsAny(lower, DhammaKeywords.physicalDifficulty)) {
      return SemanticHints.physicalDifficulty;
    }

    // Không nhận diện được gì đặc biệt
    return const SemanticHint.none();
  }

  // ─── Helpers ──────────────────────────────────

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((kw) => text.contains(kw));
  }

  static bool _containsAccessConcentrationPhrase(String lower) {
    // "very quiet" / "very still" + no hindrance language
    final veryStill = (lower.contains('very quiet') ||
            lower.contains('very still') ||
            lower.contains('very calm')) &&
        !_containsAny(lower, DhammaKeywords.hindranceWords);

    // "close to" something
    final closeToSomething = lower.contains('close to') ||
        lower.contains('almost there') ||
        lower.contains('nearly');

    return veryStill || closeToSomething;
  }
}

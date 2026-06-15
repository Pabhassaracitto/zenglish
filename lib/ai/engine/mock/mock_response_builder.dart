import '../../models/interview_feedback.dart';

/// Tạo các câu language feedback và encouragement
/// dựa trên kết quả phân tích
/// 
/// MVP: hard-coded responses
/// Production: GPT/Gemini API call
class MockResponseBuilder {

  // ─── Language Feedback ────────────────────────

  static String buildLanguageFeedback({
    required List<CheckResult> results,
    required bool hasOpeningWithBhante,
    required bool hasClearObject,
    required bool hasPaliTerms,
    required int wordCount,
  }) {
    final sb = StringBuffer();

    // Length feedback
    if (wordCount < 20) {
      sb.write('Báo cáo còn ngắn — '
          'cố gắng mô tả đầy đủ hơn (4–6 câu là tốt). ');
    } else if (wordCount > 150) {
      sb.write('Báo cáo khá dài — '
          'hãy cô đọng hơn, thiền sư cần nghe trọng tâm. ');
    } else {
      sb.write('Độ dài báo cáo phù hợp. ');
    }

    // Pali terms
    if (hasPaliTerms) {
      sb.write('Tốt khi dùng thuật ngữ Pāḷi — '
          'giúp thiền sư hiểu chính xác hơn. ');
    } else {
      sb.write('Có thể thêm thuật ngữ Pāḷi như ānāpāna, samādhi, nimitta '
          'để trao đổi chính xác hơn với thiền sư. ');
    }

    // Monastery English note
    if (hasOpeningWithBhante) {
      sb.write('Cách bắt đầu bằng "Bhante" rất chuẩn mực. ');
    }

    if (!hasClearObject) {
      sb.write('Hãy thêm câu mô tả đề mục: '
          '"My kammaṭṭhāna is ānāpāna."');
    }

    return sb.toString().trim();
  }

  // ─── Encouragement ────────────────────────────

  static String buildEncouragement({
    required int overallScore,
    required bool isFirstTime,
    required bool hasDifficulty,
  }) {
    if (overallScore >= 85) {
      return 'Báo cáo rõ ràng và đầy đủ. '
          'Đây là cách trình pháp hiệu quả với thiền sư.';
    }

    if (overallScore >= 65) {
      return 'Tốt — còn vài điểm nhỏ để bổ sung. '
          'Tiếp tục luyện tập theo cấu trúc 5 phần.';
    }

    if (overallScore >= 40) {
      if (hasDifficulty) {
        return 'Bạn đã mô tả khó khăn trung thực — đó là điều tốt. '
            'Hãy bổ sung thêm đề mục và điểm chú ý.';
      }
      return 'Báo cáo đang xây dựng. '
          'Hãy thêm các phần còn thiếu từng bước một.';
    }

    if (isFirstTime) {
      return 'Đây là lần đầu — hoàn toàn bình thường khi còn thiếu sót. '
          'Xem lại cấu trúc 5 phần và thử lại.';
    }

    return 'Hãy xem lại cấu trúc báo cáo 5 phần và thử lại. '
        'Mỗi lần luyện tập đều có ích.';
  }

  // ─── Next Step ────────────────────────────────

  static String buildNextStep({
    required List<String> missingPoints,
    required SemanticHint hint,
    required bool hasQuestion,
  }) {
    if (missingPoints.isNotEmpty) {
      final missing = missingPoints.take(2).join(' và ');
      return 'Lần tới: bổ sung "$missing" vào báo cáo.';
    }

    if (hint.level == SemanticHintLevel.noteworthy) {
      return 'Báo cáo chi tiết trạng thái này với thiền sư '
          'ngay trong buổi interview thực tế.';
    }

    if (!hasQuestion) {
      return 'Hãy kết thúc bằng 1 câu hỏi cụ thể cho thiền sư: '
          '"Bhante, when the breath becomes subtle, what should I do?"';
    }

    return 'Tiếp tục thực hành và báo cáo thật mỗi ngày.';
  }

  // ─── Score calculation ────────────────────────

  static int calculateScore({
    required List<CheckResult> results,
    required bool hasPaliTerms,
    required int wordCount,
    required bool hasQuestion,
  }) {
    if (results.isEmpty) return 0;

    // Base: mỗi check pass = 15 điểm (5 checks = 75 điểm)
    int score = results.where((r) => r.passed).length * 15;

    // Bonus: có Pāḷi terms (+8)
    if (hasPaliTerms) score += 8;

    // Bonus: độ dài hợp lý (+7)
    if (wordCount >= 20 && wordCount <= 150) score += 7;

    // Bonus: có câu hỏi (+5)
    if (hasQuestion) score += 5;

    // Bonus: không quá ngắn hoặc quá dài
    if (wordCount < 10) score -= 10;

    return score.clamp(0, 100);
  }
}

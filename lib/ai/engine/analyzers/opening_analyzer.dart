import '../../../core/constants/dhamma_keywords.dart';
import '../../models/interview_feedback.dart';

/// Phân tích cách mở đầu — có 'Bhante' không?
class OpeningAnalyzer {
  static CheckResult analyze(String transcript) {
    final lower = transcript.toLowerCase().trim();

    // Check starts with respectful opening
    String? detected;
    for (final opening in DhammaKeywords.respectfulOpenings) {
      if (lower.startsWith(opening) ||
          lower.startsWith('$opening,') ||
          lower.startsWith('$opening ')) {
        detected = opening;
        break;
      }
    }

    // Also check if it appears anywhere in first 30 chars
    if (detected == null) {
      final firstPart = lower.length > 30
          ? lower.substring(0, 30)
          : lower;
      for (final opening in DhammaKeywords.respectfulOpenings) {
        if (firstPart.contains(opening)) {
          detected = opening;
          break;
        }
      }
    }

    final passed = detected != null;

    return CheckResult(
      checkName: 'Opening',
      checkNameVi: 'Cách Mở Đầu',
      passed: passed,
      detectedValue: detected,
      description: passed
          ? 'Tốt — bạn đã bắt đầu với "$detected".'
          : 'Thiếu — chưa có cách mở đầu tôn trọng.',
      tip: passed
          ? 'Tiếp tục dùng "Bhante," ở đầu mỗi câu trình pháp.'
          : 'Bắt đầu bằng: "Bhante, may I report my sitting?" '
            'hoặc "Bhante, ..." '
            'Đây là quy tắc cơ bản tại mọi thiền viện Theravāda.',
    );
  }
}

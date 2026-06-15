import '../../../core/constants/dhamma_keywords.dart';
import '../../models/interview_feedback.dart';

/// Phân tích vị trí chú ý — Pa-Auk specific
/// "touching point", "nostril", "upper lip"
class LocationAnalyzer {
  static CheckResult analyze(String transcript) {
    final lower = transcript.toLowerCase();

    String? detected;
    for (final kw in DhammaKeywords.paAukLocations) {
      if (lower.contains(kw)) {
        detected = kw;
        break;
      }
    }

    final passed = detected != null;

    return CheckResult(
      checkName: 'Location',
      checkNameVi: 'Điểm Chú Ý',
      passed: passed,
      detectedValue: detected,
      description: passed
          ? 'Tốt — điểm chú ý được nêu: "$detected".'
          : 'Thiếu — chưa mô tả vị trí đặt tâm.',
      tip: passed
          ? 'Chuẩn. Pa-Auk dùng: '
            '"I keep attention at the touching point, '
            'below the nostrils."'
          : 'Hãy nêu vị trí cụ thể: '
            '"Bhante, I keep my attention at the touching point, '
            'below the nostrils." '
            'Đây là thông tin quan trọng để thiền sư '
            'xác nhận phương pháp đúng.',
    );
  }
}

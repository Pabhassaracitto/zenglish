import '../../../core/constants/dhamma_keywords.dart';
import '../../models/interview_feedback.dart';

/// Phân tích đề mục thiền — có nói về đối tượng chú ý không?
class ObjectAnalyzer {
  static CheckResult analyze(String transcript) {
    final lower = transcript.toLowerCase();

    // Collect all detected objects
    final detectedSamatha = <String>[];
    final detectedVipassana = <String>[];

    for (final kw in DhammaKeywords.samathaObjects) {
      if (lower.contains(kw)) detectedSamatha.add(kw);
    }
    for (final kw in DhammaKeywords.vipassanaObjects) {
      if (lower.contains(kw)) detectedVipassana.add(kw);
    }

    final allDetected = [...detectedSamatha, ...detectedVipassana];
    final passed = allDetected.isNotEmpty;

    String detected = '';
    String type = '';
    if (detectedSamatha.isNotEmpty) {
      detected = detectedSamatha.first;
      type = 'Samatha';
    } else if (detectedVipassana.isNotEmpty) {
      detected = detectedVipassana.first;
      type = 'Vipassanā';
    }

    return CheckResult(
      checkName: 'Object',
      checkNameVi: 'Đề Mục Thiền',
      passed: passed,
      detectedValue: passed ? '$detected ($type)' : null,
      description: passed
          ? 'Tốt — nhận diện đề mục: "$detected" ($type).'
          : 'Thiếu — chưa nêu đề mục thiền.',
      tip: passed
          ? 'Tốt. Hãy mô tả rõ hơn: "My kammaṭṭhāna is ānāpāna."'
          : 'Hãy nêu rõ đề mục: '
            '"Bhante, my kammaṭṭhāna is ānāpāna." '
            'hoặc "I am working with the breath."',
    );
  }
}

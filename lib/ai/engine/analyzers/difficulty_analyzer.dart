import '../../../core/constants/dhamma_keywords.dart';
import '../../models/interview_feedback.dart';

/// Phân tích phần khó khăn — có nêu nīvaraṇa không?
class DifficultyAnalyzer {
  static CheckResult analyze(String transcript) {
    final lower = transcript.toLowerCase();

    final detectedHindrances = <String>[];
    final detectedPhrases = <String>[];

    for (final kw in DhammaKeywords.hindranceWords) {
      if (lower.contains(kw)) detectedHindrances.add(kw);
    }
    for (final phrase in DhammaKeywords.difficultyPhrases) {
      if (lower.contains(phrase)) detectedPhrases.add(phrase);
    }

    final allDetected = [...detectedHindrances, ...detectedPhrases];
    final passed = allDetected.isNotEmpty;

    String? detectedValue;
    if (detectedHindrances.isNotEmpty) {
      detectedValue = detectedHindrances.take(2).join(', ');
    } else if (detectedPhrases.isNotEmpty) {
      detectedValue = detectedPhrases.first;
    }

    // Nếu nói "no problem" hoặc "everything is fine" → partial pass
    final noIssue = lower.contains('no problem') ||
        lower.contains('no difficulty') ||
        lower.contains('everything is fine') ||
        lower.contains('nothing unusual') ||
        lower.contains('no hindrance');

    final effectivePassed = passed || noIssue;

    return CheckResult(
      checkName: 'Difficulty',
      checkNameVi: 'Khó Khăn / Nīvaraṇa',
      passed: effectivePassed,
      detectedValue: noIssue ? 'No difficulty reported' : detectedValue,
      description: effectivePassed
          ? (noIssue
              ? 'Bạn báo cáo không có khó khăn — hợp lệ.'
              : 'Tốt — nêu được khó khăn: '
                '"${detectedValue ?? ''}".')
          : 'Thiếu — chưa nêu khó khăn hoặc nīvaraṇa.',
      tip: effectivePassed
          ? (detectedHindrances.isNotEmpty
              ? 'Hãy mô tả cụ thể hơn: khi nào, mức độ nào, '
                'bạn đã làm gì về nó.'
              : 'Tốt. Tiếp tục mô tả chân thật.')
          : 'Hãy nêu khó khăn: '
            '"Bhante, the main difficulty is [thinking / sleepiness]." '
            'Hoặc: "There is no major difficulty today." '
            'Thiền sư cần biết để hướng dẫn.',
    );
  }
}

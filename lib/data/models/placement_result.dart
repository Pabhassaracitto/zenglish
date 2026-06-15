import '../models/user_profile.dart';
import '../../core/enums/cefr_level.dart';
import '../../core/enums/meditation_stage.dart';

// ─────────────────────────────────────────────
// ENUMS — 3 Trục Tọa Độ
// ─────────────────────────────────────────────

/// Trục 2: Meditation Experience (self-reported)
enum MeditationExperience {
  /// Tò mò, chưa từng ngồi thiền
  curious,
  /// Đã thiền vài lần, chưa có hệ thống
  beginner,
  /// Đang thực hành samatha có hướng dẫn
  samathaActive,
  /// Đã có kinh nghiệm nimitta / jhāna
  samathaAdvanced,
  /// Đang thực hành vipassanā
  vipassanaActive,
  /// Đã đi retreat dài hạn, có thiền sư
  longTermPractitioner;

  String get displayLabel {
    switch (this) {
      case MeditationExperience.curious:
        return 'Tôi chưa từng thiền — chỉ tò mò';
      case MeditationExperience.beginner:
        return 'Tôi đã thử thiền vài lần';
      case MeditationExperience.samathaActive:
        return 'Tôi đang thực hành samatha (ānāpāna, kasiṇa...)';
      case MeditationExperience.samathaAdvanced:
        return 'Tôi đã có kinh nghiệm về nimitta hoặc jhāna';
      case MeditationExperience.vipassanaActive:
        return 'Tôi đang thực hành vipassanā';
      case MeditationExperience.longTermPractitioner:
        return 'Tôi đã đi retreat dài hạn và có thiền sư hướng dẫn';
    }
  }

  String get sublabel {
    switch (this) {
      case MeditationExperience.curious:
        return 'Muốn tìm hiểu Phật giáo Theravāda';
      case MeditationExperience.beginner:
        return 'Chưa có hệ thống — chưa có thiền sư';
      case MeditationExperience.samathaActive:
        return 'Đang theo hệ thống Pa-Auk hoặc tương đương';
      case MeditationExperience.samathaAdvanced:
        return 'Nimitta xuất hiện hoặc đã nhập thiền';
      case MeditationExperience.vipassanaActive:
        return 'Đang quán sát danh sắc, tam đặc tướng';
      case MeditationExperience.longTermPractitioner:
        return 'Sadi, tỳ khưu, hoặc cư sĩ tu lâu năm';
    }
  }

  /// Ánh xạ sang MeditationStage enum (data layer)
  MeditationStage toMeditationStage() {
    switch (this) {
      case MeditationExperience.curious:
        return MeditationStage.preRetreat;
      case MeditationExperience.beginner:
        return MeditationStage.preRetreat;
      case MeditationExperience.samathaActive:
        return MeditationStage.samathaPreiliminary;
      case MeditationExperience.samathaAdvanced:
        return MeditationStage.samathaUpacara;
      case MeditationExperience.vipassanaActive:
        return MeditationStage.vipassanaPreiliminary;
      case MeditationExperience.longTermPractitioner:
        return MeditationStage.vipassanaInsight;
    }
  }
}

/// Trục 3: Pāḷi Knowledge Level
enum PaliKnowledgeTier {
  /// Không biết gì về Pāḷi
  none,
  /// Biết một số từ phổ biến qua chú giải / kinh
  phonetic,
  /// Có thể nhận ra nghĩa của nhiều thuật ngữ kỹ thuật
  semantic;

  String get displayLabel {
    switch (this) {
      case PaliKnowledgeTier.none:
        return 'Tôi chưa biết gì về Pāḷi';
      case PaliKnowledgeTier.phonetic:
        return 'Tôi biết một số từ như ānāpāna, nimitta, jhāna';
      case PaliKnowledgeTier.semantic:
        return 'Tôi hiểu nghĩa của nhiều thuật ngữ kỹ thuật Pāḷi';
    }
  }

  String get sublabel {
    switch (this) {
      case PaliKnowledgeTier.none:
        return 'Pāḷi hoàn toàn mới với tôi';
      case PaliKnowledgeTier.phonetic:
        return 'Nghe quen — đọc được — chưa chắc nghĩa';
      case PaliKnowledgeTier.semantic:
        return 'Hiểu khái niệm Abhidhamma, có thể đọc Pāḷi cơ bản';
    }
  }

  /// Ánh xạ sang paliKnowledgeLevel (0–5)
  int toKnowledgeLevel() {
    switch (this) {
      case PaliKnowledgeTier.none:
        return 0;
      case PaliKnowledgeTier.phonetic:
        return 2;
      case PaliKnowledgeTier.semantic:
        return 4;
    }
  }
}

// ─────────────────────────────────────────────
// VOCAB QUESTION MODEL
// ─────────────────────────────────────────────

class VocabQuestion {
  const VocabQuestion({
    required this.id,
    required this.wordEn,
    required this.contextHint,
    required this.options,
    required this.correctIndex,
  });

  final String id;
  final String wordEn;

  /// Gợi ý ngữ cảnh — không phải định nghĩa trực tiếp
  final String contextHint;
  final List<String> options;
  final int correctIndex;

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}

// ─────────────────────────────────────────────
// PLACEMENT RESULT
// ─────────────────────────────────────────────

class PlacementResult {
  const PlacementResult({
    required this.meditationExperience,
    required this.paliTier,
    required this.vocabScore,
    required this.vocabAnswers,
    required this.derivedLanguageLevel,
    required this.derivedMeditationStage,
    required this.derivedPaliLevel,
    required this.recommendedStartLessonId,
    required this.fastTracked,
  });

  final MeditationExperience meditationExperience;
  final PaliKnowledgeTier paliTier;

  /// 0–3 (số câu đúng trong vocab test)
  final int vocabScore;

  /// Map questionId → selectedIndex
  final Map<String, int> vocabAnswers;

  // ─── Derived outputs ────────────────────────
  final CEFRLevel derivedLanguageLevel;
  final MeditationStage derivedMeditationStage;
  final int derivedPaliLevel;
  final String recommendedStartLessonId;

  /// true nếu được chuyển thẳng lên bài nâng cao
  final bool fastTracked;

  UserProfile toUserProfile({
    required String userId,
    required String displayName,
  }) {
    return UserProfile(
      userId: userId,
      displayName: displayName,
      languageLevel: derivedLanguageLevel,
      meditationStage: derivedMeditationStage,
      paliKnowledgeLevel: derivedPaliLevel,
      completedLessonIds: const [],
      inProgressLessonIds: [recommendedStartLessonId],
      preferredTradition: 'Pa-Auk',
      isMonk: meditationExperience == MeditationExperience.longTermPractitioner,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'PlacementResult('
      'lang=$derivedLanguageLevel, '
      'stage=$derivedMeditationStage, '
      'pali=$derivedPaliLevel, '
      'lesson=$recommendedStartLessonId, '
      'fastTracked=$fastTracked)';
}

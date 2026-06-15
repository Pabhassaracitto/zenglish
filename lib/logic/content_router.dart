import '../core/enums/cefr_level.dart';
import '../core/enums/meditation_stage.dart';
import '../data/models/placement_result.dart';

/// ContentRouter — Strategy Pattern
/// Ánh xạ (Language, Meditation, Pali) → Lesson ID
///
/// Priority matrix:
/// 1. Meditation stage là yếu tố QUAN TRỌNG nhất
/// (người đang vipassanā không cần học A1 CH01)
/// 2. Language level quyết định cấp độ nội dung
/// 3. Pali level bổ sung cho cả hai
class ContentRouter {
  ContentRouter._();

  /// Hàm chính — trả về lessonId bắt đầu
  static String getStartLesson({
    required CEFRLevel languageLevel,
    required MeditationStage meditationStage,
    required int paliLevel,
    required MeditationExperience meditationExperience,
  }) {
    // Xác định strategy dựa trên meditation stage
    final strategy = selectStrategy(
      meditationExperience,
      languageLevel,
    );
    return strategy.resolve(
      languageLevel: languageLevel,
      meditationStage: meditationStage,
      paliLevel: paliLevel,
    );
  }

  // ─── Strategy Selection ──────────────────────
  static RoutingStrategy selectStrategy(
    MeditationExperience experience,
    CEFRLevel langLevel,
  ) {
    switch (experience) {
      // ─── Mới hoàn toàn ───────────────────────
      case MeditationExperience.curious:
        return CuriousStrategy();
      // ─── Mới bắt đầu ─────────────────────────
      case MeditationExperience.beginner:
        return BeginnerStrategy();
      // ─── Samatha đang thực hành ───────────────
      case MeditationExperience.samathaActive:
        return SamathaActiveStrategy();
      // ─── Samatha nâng cao (nimitta/jhāna) ────
      case MeditationExperience.samathaAdvanced:
        // Fast-track nếu tiếng Anh còn yếu
        if ([CEFRLevel.a1, CEFRLevel.a2].contains(langLevel)) {
          return FastTrackSamathaStrategy();
        }
        return SamathaAdvancedStrategy();
      // ─── Vipassanā ────────────────────────────
      case MeditationExperience.vipassanaActive:
        if ([CEFRLevel.a1, CEFRLevel.a2].contains(langLevel)) {
          return FastTrackVipassanaStrategy();
        }
        return VipassanaStrategy();
      // ─── Tu lâu năm ───────────────────────────
      case MeditationExperience.longTermPractitioner:
        return LongTermStrategy(langLevel: langLevel);
    }
  }
}

// ─────────────────────────────────────────────
// STRATEGY INTERFACE
// ─────────────────────────────────────────────

abstract class RoutingStrategy {
  String resolve({
    required CEFRLevel languageLevel,
    required MeditationStage meditationStage,
    required int paliLevel,
  });

  /// Helper: chọn bài theo language level
  String byLanguageLevel(
    CEFRLevel level, {
    required String a1,
    required String a2,
    String? b1,
    String? b2,
  }) {
    switch (level) {
      case CEFRLevel.a1:
        return a1;
      case CEFRLevel.a2:
        return a2;
      case CEFRLevel.b1:
        return b1 ?? a2;
      case CEFRLevel.b2:
      case CEFRLevel.c1:
      case CEFRLevel.c2:
        return b2 ?? b1 ?? a2;
    }
  }
}

// ─────────────────────────────────────────────
// STRATEGY IMPLEMENTATIONS
// ─────────────────────────────────────────────

/// Mới hoàn toàn → bắt đầu từ đầu
class CuriousStrategy extends RoutingStrategy {
  @override
  String resolve({
    required CEFRLevel languageLevel,
    required MeditationStage meditationStage,
    required int paliLevel,
  }) {
    // Luôn bắt đầu từ CH01 — "Cơ Duyên Đến Với Đạo Phật"
    return 'A1CH01_L01';
  }
}

/// Đã thử thiền vài lần → bỏ qua CH01, bắt đầu CH02
class BeginnerStrategy extends RoutingStrategy {
  @override
  String resolve({
    required CEFRLevel languageLevel,
    required MeditationStage meditationStage,
    required int paliLevel,
  }) {
    return byLanguageLevel(
      languageLevel,
      a1: 'A1_CH02_L01', // Arriving at the Monastery
      a2: 'A1_CH03_L01', // Daily Life
    );
  }
}

/// Đang thực hành samatha → vào thẳng A2 ānāpāna
class SamathaActiveStrategy extends RoutingStrategy {
  @override
  String resolve({
    required CEFRLevel languageLevel,
    required MeditationStage meditationStage,
    required int paliLevel,
  }) {
    // Nếu tiếng Anh còn A1: cần học vocabulary thiền viện trước
    if (languageLevel == CEFRLevel.a1) {
      return 'A1_CH02_L01';
    }
    // A2 trở lên: vào thẳng bài ānāpāna
    return 'A2_CH06_L01';
  }
}

/// Samatha nâng cao, tiếng Anh A2+
/// → Bài ānāpāna hoặc 5-part report
class SamathaAdvancedStrategy extends RoutingStrategy {
  @override
  String resolve({
    required CEFRLevel languageLevel,
    required MeditationStage meditationStage,
    required int paliLevel,
  }) {
    return byLanguageLevel(
      languageLevel,
      a1: 'A2_CH06_L01',
      a2: 'A2_CH06_L01',
      b1: 'B1_CH12_L01', // 5-Part Report (Core)
    );
  }
}

/// FAST TRACK: Samatha nâng cao nhưng tiếng Anh yếu
/// → Vào CH12 (5-part report) ở cấp A1/A2 ngôn ngữ
/// Logic: Người này cần ngôn ngữ để trình pháp,
/// không cần học lại khái niệm thiền
class FastTrackSamathaStrategy extends RoutingStrategy {
  @override
  String resolve({
    required CEFRLevel languageLevel,
    required MeditationStage meditationStage,
    required int paliLevel,
  }) {
    // Fast track: thẳng vào bài trình pháp
    // với ghi chú "simplified language mode"
    return 'B1_CH12_L01';
  }
}

/// Vipassanā đang thực hành, tiếng Anh đủ
class VipassanaStrategy extends RoutingStrategy {
  @override
  String resolve({
    required CEFRLevel languageLevel,
    required MeditationStage meditationStage,
    required int paliLevel,
  }) {
    return byLanguageLevel(
      languageLevel,
      a1: 'B1_CH12_L01',
      a2: 'B1_CH12_L01',
      b1: 'B1_CH12_L01',
      b2: 'B1_CH12_L01',
    );
  }
}

/// FAST TRACK: Vipassanā nhưng tiếng Anh yếu
class FastTrackVipassanaStrategy extends RoutingStrategy {
  @override
  String resolve({
    required CEFRLevel languageLevel,
    required MeditationStage meditationStage,
    required int paliLevel,
  }) {
    return 'B1_CH12_L01';
  }
}

/// Tu lâu năm — routing tinh tế nhất
class LongTermStrategy extends RoutingStrategy {
  LongTermStrategy({required this.langLevel});
  final CEFRLevel langLevel;

  @override
  String resolve({
    required CEFRLevel languageLevel,
    required MeditationStage meditationStage,
    required int paliLevel,
  }) {
    // Người tu lâu năm:
    // Pali cao + English cao → B1/B2 content
    // Pali cao + English thấp → Fast track B1
    // Pali thấp + English thấp → A2 với nội dung sâu
    if (paliLevel >= 3 && languageLevel.index >= CEFRLevel.b1.index) {
      return 'B1_CH12_L01';
    }
    if (languageLevel == CEFRLevel.a1) {
      // Tiếng Anh rất yếu: bắt đầu bằng thiền viện basics
      // nhưng được đánh dấu để skip nhanh
      return 'A1_CH02_L01';
    }
    return 'B1_CH12_L01';
  }
}

/// Bảng ánh xạ tất cả kết hợp có thể
/// Dùng để debug hoặc unit test
class RoutingTable {
  static Map<String, String> get allCombinations {
    final result = <String, String>{};
    for (final exp in MeditationExperience.values) {
      for (final lang in CEFRLevel.values) {
        for (final pali in [0, 2, 4]) {
          final key = '${exp.name}_${lang.displayName}_pali$pali';
          final lessonId = ContentRouter.getStartLesson(
            languageLevel: lang,
            meditationStage: exp.toMeditationStage(),
            paliLevel: pali,
            meditationExperience: exp,
          );
          result[key] = lessonId;
        }
      }
    }
    return result;
  }
}

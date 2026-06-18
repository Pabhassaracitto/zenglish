//lib\data\models\lesson.dart
import '../../core/enums/cefr_level.dart';
import '../../core/enums/meditation_stage.dart';
import '../../core/enums/situation_type.dart';
import '../../core/enums/temporal_context.dart';
import 'lesson_flow.dart';
import 'situation_variant.dart';
import 'vocab_item.dart';

/// Model chính cho mỗi bài học
/// Ánh xạ trực tiếp từ JSON schema đã thiết kế
class Lesson {
  const Lesson({
    required this.lessonId,
    required this.titleEn,
    required this.titleVi,
    required this.level,
    required this.meditationStageMin,
    required this.situationTypes,
    required this.temporalContexts,
    required this.prerequisites,
    required this.monasteryNote,
    required this.authenticityReminder,
    required this.vocabulary,
    required this.lessonFlow,
    required this.situationVariants,
    this.patchesApplied = const [],
    this.needsReview = false,
    this.needsReviewNote,
  });

  /// Ví dụ: "A2_CH06_L01"
  final String lessonId;
  final String titleEn;
  final String titleVi;
  final CEFRLevel level;
  final MeditationStage meditationStageMin;
  final List<SituationType> situationTypes;
  final List<TemporalContext> temporalContexts;
  final List<String> prerequisites;
  final String monasteryNote;
  final String authenticityReminder;
  final List<VocabItem> vocabulary;
  final LessonFlow lessonFlow;

  /// Map từ SituationType → SituationVariant
  final Map<SituationType, SituationVariant> situationVariants;

  /// Ghi lại các patch đã áp dụng
  final List<String> patchesApplied;

  /// Đánh dấu cần review từ Dhamma Vision Lead
  final bool needsReview;
  final String? needsReviewNote;

  // ─── Computed ───────────────────────────────

  String get chapter {
    // "A2_CH06_L01" → "CH06"
    final parts = lessonId.split('_');
    return parts.length > 1 ? parts[1] : '';
  }

  int get lessonNumber {
    // "A2_CH06_L01" → 1
    final parts = lessonId.split('_');
    if (parts.length > 2) {
      return int.tryParse(parts[2].replaceAll('L', '')) ?? 0;
    }
    return 0;
  }

  List<VocabItem> get highPriorityVocab =>
      vocabulary.where((v) => v.isHighPriority).toList();

  List<VocabItem> get audioNeededVocab =>
      vocabulary.where((v) => v.needsAudio).toList();

  // ─── Factory ────────────────────────────────

  factory Lesson.fromJson(Map<String, dynamic> json) {
    print(
        '[Lesson.fromJson] Starting parse for lesson_id: ${json['lesson_id']}');

    // Parse lesson_flow first to catch errors early
    try {
      final lessonFlow = LessonFlow.fromJson(
        json['lesson_flow'] as Map<String, dynamic>,
      );
      print('[Lesson.fromJson] ✅ LessonFlow parsed successfully');
    } catch (e) {
      print('[Lesson.fromJson] ❌ LessonFlow parse error: $e');
      rethrow;
    }

    // Parse situation_variants
    final rawVariants =
        json['situation_variants'] as Map<String, dynamic>? ?? {};
    final variantMap = <SituationType, SituationVariant>{};

    const keyMap = {
      'A_preparation': SituationType.preparation,
      'B_first_appearance': SituationType.firstAppearance,
      'C_stable_tracking': SituationType.stableTracking,
      'D_disappeared_changed': SituationType.disappearedChanged,
      'E_past_future': SituationType.pastFuture,
    };

    keyMap.forEach((jsonKey, situationType) {
      if (rawVariants.containsKey(jsonKey)) {
        variantMap[situationType] = SituationVariant.fromJson(
          rawVariants[jsonKey] as Map<String, dynamic>,
          situationType,
        );
      }
    });

    return Lesson(
      lessonId: json['lesson_id'] as String,
      titleEn: json['title_en'] as String,
      titleVi: json['title_vi'] as String,
      level: CEFRLevel.fromString(json['level'] as String),
      meditationStageMin: MeditationStage.fromString(
        json['meditation_stage_min'] as String? ?? 'any',
      ),
      situationTypes: SituationType.values, // Default: all 5
      temporalContexts: TemporalContext.values,
      prerequisites: List<String>.from(
        json['prerequisites'] as List<dynamic>? ?? [],
      ),
      monasteryNote: json['monastery_note'] as String? ?? '',
      authenticityReminder: json['authenticity_reminder'] as String? ?? '',
      vocabulary: (json['vocabulary'] as List<dynamic>? ?? [])
          .map((e) => VocabItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessonFlow: LessonFlow.fromJson(
        json['lesson_flow'] as Map<String, dynamic>,
      ),
      situationVariants: variantMap,
      patchesApplied: List<String>.from(
        json['patches_applied'] as List<dynamic>? ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final variantsJson = <String, dynamic>{};
    const keyMap = {
      SituationType.preparation: 'A_preparation',
      SituationType.firstAppearance: 'B_first_appearance',
      SituationType.stableTracking: 'C_stable_tracking',
      SituationType.disappearedChanged: 'D_disappeared_changed',
      SituationType.pastFuture: 'E_past_future',
    };
    situationVariants.forEach((type, variant) {
      final key = keyMap[type];
      if (key != null) variantsJson[key] = variant.toJson();
    });

    return {
      'lesson_id': lessonId,
      'title_en': titleEn,
      'title_vi': titleVi,
      'level': level.displayName,
      'meditation_stage_min': meditationStageMin.name,
      'prerequisites': prerequisites,
      'monastery_note': monasteryNote,
      'authenticity_reminder': authenticityReminder,
      'vocabulary': vocabulary.map((v) => v.toJson()).toList(),
      'lesson_flow': lessonFlow.toJson(),
      'situation_variants': variantsJson,
      'patches_applied': patchesApplied,
      'needs_review': needsReview,
      if (needsReviewNote != null) 'needs_review_note': needsReviewNote,
    };
  }

  Lesson copyWith({
    String? lessonId,
    String? titleEn,
    String? titleVi,
    CEFRLevel? level,
    MeditationStage? meditationStageMin,
    List<SituationType>? situationTypes,
    List<TemporalContext>? temporalContexts,
    List<String>? prerequisites,
    String? monasteryNote,
    String? authenticityReminder,
    List<VocabItem>? vocabulary,
    LessonFlow? lessonFlow,
    Map<SituationType, SituationVariant>? situationVariants,
    List<String>? patchesApplied,
    bool? needsReview,
    String? needsReviewNote,
  }) {
    return Lesson(
      lessonId: lessonId ?? this.lessonId,
      titleEn: titleEn ?? this.titleEn,
      titleVi: titleVi ?? this.titleVi,
      level: level ?? this.level,
      meditationStageMin: meditationStageMin ?? this.meditationStageMin,
      situationTypes: situationTypes ?? this.situationTypes,
      temporalContexts: temporalContexts ?? this.temporalContexts,
      prerequisites: prerequisites ?? this.prerequisites,
      monasteryNote: monasteryNote ?? this.monasteryNote,
      authenticityReminder: authenticityReminder ?? this.authenticityReminder,
      vocabulary: vocabulary ?? this.vocabulary,
      lessonFlow: lessonFlow ?? this.lessonFlow,
      situationVariants: situationVariants ?? this.situationVariants,
      patchesApplied: patchesApplied ?? this.patchesApplied,
      needsReview: needsReview ?? this.needsReview,
      needsReviewNote: needsReviewNote ?? this.needsReviewNote,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lesson &&
          runtimeType == other.runtimeType &&
          lessonId == other.lessonId;

  @override
  int get hashCode => lessonId.hashCode;
}

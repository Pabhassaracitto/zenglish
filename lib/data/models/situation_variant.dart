import '../../core/enums/situation_type.dart';
import '../../core/enums/temporal_context.dart';

/// Một trong 5 tình huống temporal flexibility
class SituationVariant {
  const SituationVariant({
    required this.situationType,
    required this.temporalContext,
    required this.description,
    required this.contextEn,
    required this.contextVi,
    required this.sampleSentences,
    this.sampleSentencesPast,
    this.sampleSentencesFuture,
    this.typicalTeacherResponses,
    this.vocabularyFocus,
    this.monasteryNote,
    this.learningFocus,
  });

  final SituationType situationType;
  final TemporalContext temporalContext;
  final String description;
  final String contextEn;
  final String contextVi;

  /// Câu mẫu cho tình huống này
  final List<String> sampleSentences;

  /// Chỉ dùng cho Situation E (quá khứ)
  final List<String>? sampleSentencesPast;

  /// Chỉ dùng cho Situation E (tương lai)
  final List<String>? sampleSentencesFuture;

  /// Phản hồi điển hình của thiền sư
  final List<String>? typicalTeacherResponses;

  /// Từ vựng trọng tâm của tình huống này
  final List<String>? vocabularyFocus;

  /// Ghi chú thiền viện đặc biệt cho tình huống này
  final String? monasteryNote;

  /// Mục tiêu học của tình huống này
  final String? learningFocus;

  factory SituationVariant.fromJson(
    Map<String, dynamic> json,
    SituationType type,
  ) {
    return SituationVariant(
      situationType: type,
      temporalContext: TemporalContext.fromString(
        json['temporal_context'] as String? ?? 'present',
      ),
      description: json['description'] as String? ?? '',
      contextEn: json['context_en'] as String? ?? '',
      contextVi: json['context_vi'] as String? ?? '',
      sampleSentences: List<String>.from(
        json['sample_sentences'] as List<dynamic>? ?? [],
      ),
      sampleSentencesPast: json['sample_sentences_past'] != null
          ? List<String>.from(json['sample_sentences_past'] as List)
          : null,
      sampleSentencesFuture: json['sample_sentences_future'] != null
          ? List<String>.from(json['sample_sentences_future'] as List)
          : null,
      typicalTeacherResponses:
          json['typical_teacher_response'] != null
              ? List<String>.from(json['typical_teacher_response'] as List)
              : null,
      vocabularyFocus: json['vocabulary_focus'] != null
          ? List<String>.from(json['vocabulary_focus'] as List)
          : null,
      monasteryNote: json['monastery_note'] as String?,
      learningFocus: json['learning_focus'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'situation_type': situationType.code,
    'temporal_context': temporalContext.name,
    'description': description,
    'context_en': contextEn,
    'context_vi': contextVi,
    'sample_sentences': sampleSentences,
    if (sampleSentencesPast != null)
      'sample_sentences_past': sampleSentencesPast,
    if (sampleSentencesFuture != null)
      'sample_sentences_future': sampleSentencesFuture,
    if (typicalTeacherResponses != null)
      'typical_teacher_response': typicalTeacherResponses,
    if (vocabularyFocus != null) 'vocabulary_focus': vocabularyFocus,
    if (monasteryNote != null) 'monastery_note': monasteryNote,
    if (learningFocus != null) 'learning_focus': learningFocus,
  };
}

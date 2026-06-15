
/// Tri-lingual vocabulary item
/// English — Vietnamese — Pāḷi (với diacritics chuẩn)
class VocabItem {
  const VocabItem({
    required this.stt,
    required this.english,
    required this.vietnamese,
    this.pali,
    this.paliRomanized,
    required this.exampleEn,
    required this.exampleContext,
    required this.priority,
    this.note,
    this.needsAudio = false,
  });

  /// Số thứ tự trong bài học
  final int stt;

  /// Từ tiếng Anh
  final String english;

  /// Nghĩa tiếng Việt
  final String vietnamese;

  /// Từ Pāḷi với diacritics đầy đủ
  /// null nếu không có từ Pāḷi tương ứng
  final String? pali;

  /// Cách đọc gần đúng cho người Việt
  /// Ví dụ: "aa-naa-paa-na"
  final String? paliRomanized;

  /// Câu ví dụ tiếng Anh
  final String exampleEn;

  /// Ngữ cảnh sử dụng câu ví dụ
  final String exampleContext;

  /// "High" hoặc "Medium"
  final String priority;

  /// Ghi chú về phát âm hoặc sử dụng
  final String? note;

  /// Đánh dấu cần thu âm audio
  final bool needsAudio;

  bool get isHighPriority => priority.toLowerCase() == 'high';

  factory VocabItem.fromJson(Map<String, dynamic> json) {
    return VocabItem(
      stt: json['stt'] as int,
      english: json['en'] as String,
      vietnamese: json['vi'] as String,
      pali: json['pali'] as String?,
      paliRomanized: json['pali_romanized'] as String?,
      exampleEn: json['example_en'] as String,
      exampleContext: json['example_context'] as String,
      priority: json['priority'] as String,
      note: json['note'] as String?,
      needsAudio: (json['note'] as String? ?? '').contains('[NEEDS AUDIO]'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stt': stt,
      'en': english,
      'vi': vietnamese,
      'pali': pali,
      'pali_romanized': paliRomanized,
      'example_en': exampleEn,
      'example_context': exampleContext,
      'priority': priority,
      'note': note,
      'needs_audio': needsAudio,
    };
  }

  VocabItem copyWith({
    int? stt,
    String? english,
    String? vietnamese,
    String? pali,
    String? paliRomanized,
    String? exampleEn,
    String? exampleContext,
    String? priority,
    String? note,
    bool? needsAudio,
  }) {
    return VocabItem(
      stt: stt ?? this.stt,
      english: english ?? this.english,
      vietnamese: vietnamese ?? this.vietnamese,
      pali: pali ?? this.pali,
      paliRomanized: paliRomanized ?? this.paliRomanized,
      exampleEn: exampleEn ?? this.exampleEn,
      exampleContext: exampleContext ?? this.exampleContext,
      priority: priority ?? this.priority,
      note: note ?? this.note,
      needsAudio: needsAudio ?? this.needsAudio,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabItem &&
          runtimeType == other.runtimeType &&
          stt == other.stt &&
          english == other.english;

  @override
  int get hashCode => stt.hashCode ^ english.hashCode;
}

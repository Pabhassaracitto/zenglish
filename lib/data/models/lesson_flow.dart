class InputStageContent {
  const InputStageContent({
    required this.description,
    required this.sampleDialogues,
    this.audioUrl, // ← THÊM FIELD NÀY
  });
  
  final String description;
  final List<SampleDialogue> sampleDialogues;
  final String? audioUrl; // URL hoặc asset path
  
  factory InputStageContent.fromJson(Map<String, dynamic> json) {
    return InputStageContent(
      description: json['description'] as String? ?? '',
      sampleDialogues: (json['sampleDialogues'] as List<dynamic>?)
              ?.map((e) => SampleDialogue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      audioUrl: json['audioUrl'] as String?, // ← THÊM PARSE
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'sampleDialogues': sampleDialogues.map((e) => e.toJson()).toList(),
      'audioUrl': audioUrl, // ← THÊM SERIALIZE
    };
  }
}

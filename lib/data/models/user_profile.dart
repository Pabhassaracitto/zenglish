//lib\data\models\user_profile.dart
import '../../core/enums/cefr_level.dart';
import '../../core/enums/meditation_stage.dart';

/// UserProfile — đánh giá 3 trục độc lập
/// Trục 1: Ngôn ngữ (CEFR)
/// Trục 2: Giai đoạn thiền (Pa-Auk progression)
/// Trục 3: Kiến thức Pāḷi
class UserProfile {
  const UserProfile({
    required this.userId,
    required this.displayName,
    required this.languageLevel,
    required this.meditationStage,
    required this.paliKnowledgeLevel,
    required this.completedLessonIds,
    required this.inProgressLessonIds,
    this.preferredTradition = 'Pa-Auk',
    this.isMonk = false,
    this.ordinationDetails,
    this.createdAt,
    this.lastActiveAt,
    this.placementScore = 0,
    this.streakDays = 0,
    this.lastStudiedAt,
    this.showIpa = true, // ✅ NEW: Global IPA visibility preference
  });

  final String userId;
  final String displayName;

  /// Trục 1: Trình độ tiếng Anh
  final CEFRLevel languageLevel;

  /// Trục 2: Giai đoạn thực hành hiện tại
  final MeditationStage meditationStage;

  /// Trục 3: Kiến thức Pāḷi (0–5)
  /// 0 = chưa biết gì
  /// 1 = biết một số từ phổ biến
  /// 2 = có thể đọc romanized
  /// 3 = có thể đọc diacritics
  /// 4 = hiểu nghĩa nhiều từ kỹ thuật
  /// 5 = đọc Pāḷi nguyên bản
  final int paliKnowledgeLevel;

  final List<String> completedLessonIds;
  final List<String> inProgressLessonIds;

  /// "Pa-Auk" / "Mahasi" / "Goenka" / "Other"
  final String preferredTradition;

  /// true = Sa-di hoặc Tỳ khưu
  final bool isMonk;

  /// Thông tin xuất gia (nếu có)
  final OrdinationDetails? ordinationDetails;

  final DateTime? createdAt;
  final DateTime? lastActiveAt;

  // ── MERGED từ nhánh A ──
  /// Điểm placement test (0-100)
  final int placementScore;

  /// Số ngày học liên tiếp
  final int streakDays;

  /// Lần học gần nhất
  final DateTime? lastStudiedAt;

  /// Whether to show English IPA pronunciation globally
  final bool showIpa;

  // ─── Computed ───────────────────────────────

  bool isLessonCompleted(String lessonId) =>
      completedLessonIds.contains(lessonId);

  bool isLessonInProgress(String lessonId) =>
      inProgressLessonIds.contains(lessonId);

  int get totalCompletedLessons => completedLessonIds.length;

  /// Kiểm tra người dùng có thể học bài học này không
  bool canAccessLesson({
    required CEFRLevel lessonLevel,
    required MeditationStage lessonMinStage,
    required List<String> prerequisites,
  }) {
    final levelOk = languageLevel.index >= lessonLevel.index;
    final stageOk = meditationStage.index >= lessonMinStage.index ||
        lessonMinStage == MeditationStage.any;
    final prereqOk =
        prerequisites.every((id) => completedLessonIds.contains(id));
    return levelOk && stageOk && prereqOk;
  }

  // ─── Factory ────────────────────────────────

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      languageLevel: CEFRLevel.fromString(
        json['language_level'] as String,
      ),
      meditationStage: MeditationStage.fromString(
        json['meditation_stage'] as String,
      ),
      paliKnowledgeLevel: json['pali_knowledge_level'] as int? ?? 0,
      completedLessonIds: List<String>.from(
        json['completed_lesson_ids'] as List<dynamic>? ?? [],
      ),
      inProgressLessonIds: List<String>.from(
        json['in_progress_lesson_ids'] as List<dynamic>? ?? [],
      ),
      preferredTradition: json['preferred_tradition'] as String? ?? 'Pa-Auk',
      isMonk: json['is_monk'] as bool? ?? false,
      ordinationDetails: json['ordination_details'] != null
          ? OrdinationDetails.fromJson(
              json['ordination_details'] as Map<String, dynamic>,
            )
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      placementScore: json['placement_score'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      lastStudiedAt: json['last_studied_at'] != null
          ? DateTime.parse(json['last_studied_at'] as String)
          : null,
      showIpa: json['show_ipa'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'display_name': displayName,
        'language_level': languageLevel.displayName,
        'meditation_stage': meditationStage.name,
        'pali_knowledge_level': paliKnowledgeLevel,
        'completed_lesson_ids': completedLessonIds,
        'in_progress_lesson_ids': inProgressLessonIds,
        'preferred_tradition': preferredTradition,
        'is_monk': isMonk,
        if (ordinationDetails != null)
          'ordination_details': ordinationDetails!.toJson(),
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (lastActiveAt != null)
          'last_active_at': lastActiveAt!.toIso8601String(),
        'placement_score': placementScore,
        'streak_days': streakDays,
        if (lastStudiedAt != null)
          'last_studied_at': lastStudiedAt!.toIso8601String(),
        'show_ipa': showIpa,
      };

  UserProfile copyWith({
    String? userId,
    String? displayName,
    CEFRLevel? languageLevel,
    MeditationStage? meditationStage,
    int? paliKnowledgeLevel,
    List<String>? completedLessonIds,
    List<String>? inProgressLessonIds,
    String? preferredTradition,
    bool? isMonk,
    OrdinationDetails? ordinationDetails,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    int? placementScore,
    int? streakDays,
    DateTime? lastStudiedAt,
    bool? showIpa,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      languageLevel: languageLevel ?? this.languageLevel,
      meditationStage: meditationStage ?? this.meditationStage,
      paliKnowledgeLevel: paliKnowledgeLevel ?? this.paliKnowledgeLevel,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      inProgressLessonIds: inProgressLessonIds ?? this.inProgressLessonIds,
      preferredTradition: preferredTradition ?? this.preferredTradition,
      isMonk: isMonk ?? this.isMonk,
      ordinationDetails: ordinationDetails ?? this.ordinationDetails,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      placementScore: placementScore ?? this.placementScore,
      streakDays: streakDays ?? this.streakDays,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      showIpa: showIpa ?? this.showIpa,
    );
  }
}

/// Chi tiết xuất gia (Sa-di / Tỳ khưu)
class OrdinationDetails {
  const OrdinationDetails({
    required this.ordinationType,
    required this.ordinationYear,
    this.monastery,
    this.vinayaTradition,
  });

  /// "samanera" | "bhikkhu"
  final String ordinationType;
  final int ordinationYear;
  final String? monastery;

  /// "Theravāda Pātimokkha" hay khác
  final String? vinayaTradition;

  factory OrdinationDetails.fromJson(Map<String, dynamic> json) {
    return OrdinationDetails(
      ordinationType: json['ordination_type'] as String,
      ordinationYear: json['ordination_year'] as int,
      monastery: json['monastery'] as String?,
      vinayaTradition: json['vinaya_tradition'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'ordination_type': ordinationType,
        'ordination_year': ordinationYear,
        if (monastery != null) 'monastery': monastery,
        if (vinayaTradition != null) 'vinaya_tradition': vinayaTradition,
      };
}

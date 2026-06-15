enum EnglishLevel { a1, a2, b1, b2, c1, c2 }

enum MeditationExperience {
  none,
  beginner,
  intermediate,
  advanced,
  teacher
}

enum PaliLevel {
  none,
  basic,
  intermediate,
  advanced
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.englishLevel,
    required this.meditationExperience,
    required this.paliLevel,
    this.placementScore = 0,
    this.completedLessons = 0,
    this.streakDays = 0,
    required this.createdAt,
    this.lastStudiedAt,
  });

  final String id;
  final String displayName;
  final EnglishLevel englishLevel;
  final MeditationExperience meditationExperience;
  final PaliLevel paliLevel;
  final int placementScore;
  final int completedLessons;
  final int streakDays;
  final DateTime createdAt;
  final DateTime? lastStudiedAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      englishLevel: EnglishLevel.values.firstWhere(
        (e) => e.name == json['englishLevel'] || e.toString().split('.').last == json['englishLevel'],
        orElse: () => EnglishLevel.a1,
      ),
      meditationExperience: MeditationExperience.values.firstWhere(
        (e) => e.name == json['meditationExperience'] || e.toString().split('.').last == json['meditationExperience'],
        orElse: () => MeditationExperience.none,
      ),
      paliLevel: PaliLevel.values.firstWhere(
        (e) => e.name == json['paliLevel'] || e.toString().split('.').last == json['paliLevel'],
        orElse: () => PaliLevel.none,
      ),
      placementScore: json['placementScore'] as int? ?? 0,
      completedLessons: json['completedLessons'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastStudiedAt: json['lastStudiedAt'] != null
          ? DateTime.parse(json['lastStudiedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'englishLevel': englishLevel.name,
      'meditationExperience': meditationExperience.name,
      'paliLevel': paliLevel.name,
      'placementScore': placementScore,
      'completedLessons': completedLessons,
      'streakDays': streakDays,
      'createdAt': createdAt.toIso8601String(),
      'lastStudiedAt': lastStudiedAt?.toIso8601String(),
    };
  }
}

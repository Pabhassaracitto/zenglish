import 'user_profile.dart';

enum LessonType {
  vocabulary,
  conversation,
  listening,
  reading,
  dhamma,
}

enum LessonDifficulty { beginner, intermediate, advanced }

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.titlePali,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.targetLevel,
    required this.suitableFor,
    required this.estimatedMinutes,
    this.tags = const [],
    required this.iconAsset,
    required this.content,
    this.rewardPoints = 10,
    this.prerequisiteLessonIds = const [],
    this.hasPaliContent = false,
  });

  final String id;
  final String title;
  final String titlePali;
  final String description;
  final LessonType type;
  final LessonDifficulty difficulty;
  final EnglishLevel targetLevel;
  final List<MeditationExperience> suitableFor;
  final int estimatedMinutes;
  final List<String> tags;
  final String iconAsset;
  final Map<String, dynamic> content;
  final int rewardPoints;
  final List<String> prerequisiteLessonIds;
  final bool hasPaliContent;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      titlePali: json['titlePali'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: LessonType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LessonType.vocabulary,
      ),
      difficulty: LessonDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => LessonDifficulty.beginner,
      ),
      targetLevel: EnglishLevel.values.firstWhere(
        (e) => e.name == json['targetLevel'],
        orElse: () => EnglishLevel.a1,
      ),
      suitableFor: (json['suitableFor'] as List<dynamic>?)
              ?.map((e) => MeditationExperience.values.firstWhere((m) => m.name == e))
              .toList() ??
          const [],
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 10,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      iconAsset: json['iconAsset'] as String? ?? '',
      content: json['content'] as Map<String, dynamic>? ?? const {},
      rewardPoints: json['rewardPoints'] as int? ?? 10,
      prerequisiteLessonIds: (json['prerequisiteLessonIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hasPaliContent: json['hasPaliContent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titlePali': titlePali,
      'description': description,
      'type': type.name,
      'difficulty': difficulty.name,
      'targetLevel': targetLevel.name,
      'suitableFor': suitableFor.map((e) => e.name).toList(),
      'estimatedMinutes': estimatedMinutes,
      'tags': tags,
      'iconAsset': iconAsset,
      'content': content,
      'rewardPoints': rewardPoints,
      'prerequisiteLessonIds': prerequisiteLessonIds,
      'hasPaliContent': hasPaliContent,
    };
  }
}

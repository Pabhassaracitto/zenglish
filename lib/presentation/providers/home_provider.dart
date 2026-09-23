//lib\presentation\providers\home_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/cefr_level.dart';
import '../../core/enums/meditation_stage.dart';
import '../../core/providers/user_profile_provider.dart';
import '../../data/constants/lesson_asset_registry.dart';
import '../../data/di/repository_provider.dart';
import '../../data/models/lesson.dart';
import '../../data/models/placement_result.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/user_session_service.dart';
import '../../logic/content_router.dart';

// ─────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────

class HomeState {
  const HomeState({
    this.userProfile,
    this.nextLesson,
    this.isLoading = true,
    this.error,
    this.silentMode = false,
    this.greeting = '',
  });

  final UserProfile? userProfile;
  final Lesson? nextLesson;
  final bool isLoading;
  final String? error;
  final bool silentMode;
  final String greeting;

  bool get hasProfile => userProfile != null;
  bool get hasNextLesson => nextLesson != null;

  HomeState copyWith({
    UserProfile? userProfile,
    Lesson? nextLesson,
    bool? isLoading,
    String? error,
    bool? silentMode,
    String? greeting,
    bool clearError = false,
  }) {
    return HomeState(
      userProfile: userProfile ?? this.userProfile,
      nextLesson: nextLesson ?? this.nextLesson,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      silentMode: silentMode ?? this.silentMode,
      greeting: greeting ?? this.greeting,
    );
  }
}

// ─────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier(this._ref) : super(const HomeState());

  /// Nguồn sự thật DUY NHẤT cho hồ sơ và tiến độ học: [userProfileProvider]
  /// (một key JSON `userprofile` trong SharedPreferences).
  ///
  /// Trước đây Home đọc `UserSessionService.loadUserProfile()`, trong khi
  /// placement và màn hoàn thành bài lại ghi `userProfileProvider`. Service
  /// cũ chỉ được ghi bởi `saveUserProfile()` — hàm không ai gọi — nên
  /// `has_user_profile` luôn false và Home luôn thấy `profile == null`
  /// (không lời chào, không gợi ý bài kế tiếp). Đường đọc đã nhập về một mối.
  /// `UserSessionService` nay chỉ còn giữ cờ thiết bị (silent mode).
  final Ref _ref;

  final _repo = RepositoryProvider.instance;
  final _session = UserSessionService.instance;

  // ─── Init ────────────────────────────────────

  Future<void> init() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final profile =
          await _ref.read(userProfileProvider.notifier).loadFromStorage();
      if (profile == null) {
        // constructing (not copyWith) so a previous next lesson is not kept
        state = HomeState(isLoading: false, silentMode: _session.silentMode);
        return;
      }

      final nextLessonId = await _resolveNextLessonId(profile);
      final nextLesson =
          nextLessonId != null ? await _repo.getLessonById(nextLessonId) : null;

      state = HomeState(
        userProfile: profile,
        nextLesson: nextLesson,
        isLoading: false,
        silentMode: _session.silentMode,
        greeting: _buildGreeting(profile),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ─── Silent Mode ─────────────────────────────

  Future<void> toggleSilentMode() async {
    final newMode = !state.silentMode;
    state = state.copyWith(silentMode: newMode);
    await _session.setSilentMode(newMode);
  }

  // ─── Refresh ─────────────────────────────────

  Future<void> refresh() => init();

  // ─── Private helpers ─────────────────────────

  Future<String?> _resolveNextLessonId(UserProfile profile) async {
    final completed = profile.completedLessonIds.toSet();

    // 1. Còn bài học dở → tiếp tục đúng bài đó
    if (profile.inProgressLessonIds.isNotEmpty) {
      return profile.inProgressLessonIds.first;
    }

    // Catalog đã sort theo thứ tự registry (thứ tự học chuẩn của beta)
    final lessons = await _repo.loadAllLessons();
    final byId = {for (final lesson in lessons) lesson.lessonId: lesson};
    final ordered = <Lesson>[...lessons]
      ..sort((a, b) =>
          _catalogIndex(a.lessonId).compareTo(_catalogIndex(b.lessonId)));

    bool unlocked(Lesson lesson) =>
        lesson.prerequisites.every(completed.contains);

    // 2. Bài ContentRouter gợi ý, nếu chưa xong và đã đủ prerequisite
    final startId = ContentRouter.getStartLesson(
      languageLevel: profile.languageLevel,
      meditationStage: profile.meditationStage,
      paliLevel: profile.paliKnowledgeLevel,
      meditationExperience: _stageToExperience(profile.meditationStage),
    );
    final suggested = byId[startId];
    if (suggested != null &&
        !completed.contains(startId) &&
        unlocked(suggested)) {
      return startId;
    }

    // 3. Gợi ý đã hoàn thành hoặc bị khoá → đi tiếp theo thứ tự catalog
    for (final lesson in ordered) {
      if (completed.contains(lesson.lessonId)) continue;
      if (unlocked(lesson)) return lesson.lessonId;
    }

    // 4. Hết catalog
    return null;
  }

  /// Thứ tự học cố định lấy từ [LessonAssetRegistry.allPaths]; bài không có
  /// trong registry xếp ra sau cùng để không bao giờ chen vào giữa chuỗi.
  int _catalogIndex(String lessonId) {
    final paths = LessonAssetRegistry.allPaths;
    final suffix = '$lessonId.json';
    final index = paths.indexWhere((path) => path.endsWith(suffix));
    return index >= 0 ? index : paths.length;
  }

  MeditationExperience _stageToExperience(MeditationStage stage) {
    switch (stage) {
      case MeditationStage.preRetreat:
        return MeditationExperience.beginner;
      case MeditationStage.silaPreiliminary:
        return MeditationExperience.beginner;
      case MeditationStage.samathaPreiliminary:
        return MeditationExperience.samathaActive;
      case MeditationStage.samathaUpacara:
        return MeditationExperience.samathaAdvanced;
      case MeditationStage.samathaAppana:
        return MeditationExperience.samathaAdvanced;
      case MeditationStage.vipassanaPreiliminary:
        return MeditationExperience.vipassanaActive;
      case MeditationStage.vipassanaNamaRupa:
        return MeditationExperience.vipassanaActive;
      case MeditationStage.vipassanaInsight:
        return MeditationExperience.longTermPractitioner;
      case MeditationStage.any:
        return MeditationExperience.curious;
    }
  }

  String _buildGreeting(UserProfile profile) {
    final hour = DateTime.now().hour;
    final timeGreet = hour < 12
        ? 'Chào buổi sáng'
        : hour < 17
            ? 'Chào buổi chiều'
            : 'Chào buổi tối';
    return '$timeGreet, ${profile.displayName}';
  }
}

// ─────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(ref),
);

/// Derived: 3-axis display data
final threeAxisProvider = Provider<List<AxisData>>((ref) {
  final profile = ref.watch(homeProvider.select((s) => s.userProfile));
  if (profile == null) return [];

  return [
    AxisData(
      axis: 'Trục 1',
      label: 'Tiếng Anh',
      value: profile.languageLevel.displayName,
      sublabel: _langSublabel(profile.languageLevel),
      color: AxisColor.primary,
    ),
    AxisData(
      axis: 'Trục 2',
      label: 'Thiền tập',
      value: _meditationShortLabel(profile.meditationStage),
      sublabel: profile.meditationStage.displayName,
      color: AxisColor.secondary,
    ),
    AxisData(
      axis: 'Trục 3',
      label: 'Pāḷi',
      value: _paliLabel(profile.paliKnowledgeLevel),
      sublabel: _paliSublabel(profile.paliKnowledgeLevel),
      color: AxisColor.pali,
    ),
  ];
});

// ─── Helper types ────────────────────────────

enum AxisColor { primary, secondary, pali }

class AxisData {
  const AxisData({
    required this.axis,
    required this.label,
    required this.value,
    required this.sublabel,
    required this.color,
  });
  final String axis;
  final String label;
  final String value;
  final String sublabel;
  final AxisColor color;
}

// ─── Helper functions ────────────────────────

String _langSublabel(CEFRLevel level) {
  switch (level) {
    case CEFRLevel.a1:
      return 'Người mới bắt đầu';
    case CEFRLevel.a2:
      return 'Sơ cấp';
    case CEFRLevel.b1:
      return 'Trung cấp';
    case CEFRLevel.b2:
      return 'Trên trung cấp';
    case CEFRLevel.c1:
      return 'Nâng cao';
    case CEFRLevel.c2:
      return 'Chuyên gia';
  }
}

String _meditationShortLabel(MeditationStage stage) {
  switch (stage) {
    case MeditationStage.preRetreat:
      return 'Khởi đầu';
    case MeditationStage.silaPreiliminary:
      return 'Sīla';
    case MeditationStage.samathaPreiliminary:
      return 'Samatha';
    case MeditationStage.samathaUpacara:
      return 'Upacāra';
    case MeditationStage.samathaAppana:
      return 'Jhāna';
    case MeditationStage.vipassanaPreiliminary:
      return 'Vipassanā';
    case MeditationStage.vipassanaNamaRupa:
      return 'Nāma-Rūpa';
    case MeditationStage.vipassanaInsight:
      return 'Insight';
    case MeditationStage.any:
      return '—';
  }
}

String _paliLabel(int level) {
  if (level == 0) return 'Chưa biết';
  if (level <= 2) return 'Sơ cấp';
  if (level <= 4) return 'Trung cấp';
  return 'Nâng cao';
}

String _paliSublabel(int level) {
  if (level == 0) return 'Pāḷi hoàn toàn mới';
  if (level <= 2) return 'Nghe quen một số từ';
  if (level <= 4) return 'Hiểu nghĩa thuật ngữ';
  return 'Đọc được kinh điển';
}

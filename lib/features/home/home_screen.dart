// ============================================================
// HOME SCREEN
// Layout: AppBar → User Profile Card → Suggestion Card → AI Button
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

'package:ewmapp/core/theme/app_theme.dart';
import '../../core/providers/user_profile_provider.dart';
import '../../core/providers/lesson_provider.dart';
import '../../models/user_profile.dart';
import '../../models/lesson.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final suggestedLesson = ref.watch(suggestedLessonProvider);

    return Scaffold(
      backgroundColor: AppColors.creamLight,
      appBar: buildAppBar(context, ref),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.saffron),
        ),
        error: (e, __) => ErrorView(error: e.toString()),
        data: (profile) {
          if (profile == null) {
            // Redirect sẽ handle ở router, nhưng guard thêm
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/placement');
            });
            return const SizedBox.shrink();
          }
          return HomeBody(profile: profile, suggestedLesson: suggestedLesson);
        },
      ),
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: AppColors.cream,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lotus icon decoration
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.saffronGlow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('☸️', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'EWM',
            style: GoogleFonts.merriweather(
              color: AppColors.earthBrown,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        // Settings / Reset profile
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.earthLight),
          onPressed: () => showOptionsMenu(context, ref),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
    );
  }

  void showOptionsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => OptionsBottomSheet(
        onReset: () async {
          Navigator.pop(context);
          await ref.read(userProfileProvider.notifier).clearProfile();
          if (context.mounted) context.go('/placement');
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HOME BODY - Scrollable content
// ─────────────────────────────────────────────────────────────

class HomeBody extends StatelessWidget {
  const HomeBody({
    super.key,
    required this.profile,
    required this.suggestedLesson,
  });

  final UserProfile profile;
  final Lesson? suggestedLesson;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting ──
          GreetingHeader(profile: profile),
          const SizedBox(height: 24),

          // ── Section 1: User Profile Card (3 trục) ──
          const SectionLabel(label: 'Hồ sơ học tập'),
          const SizedBox(height: 12),
          UserProfileCard(profile: profile),
          const SizedBox(height: 28),

          // ── Section 2: Smart Suggestion Card ──
          const SectionLabel(label: 'Bài học gợi ý cho bạn'),
          const SizedBox(height: 12),
          if (suggestedLesson != null)
            SmartSuggestionCard(lesson: suggestedLesson!)
          else
            const NoSuggestionCard(),
          const SizedBox(height: 28),

          // ── Section 3: Start AI Interview Button ──
          const AIInterviewButton(),
          const SizedBox(height: 16),

          // ── Section 4: Stats row ──
          StatsRow(profile: profile),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// GREETING HEADER
// ─────────────────────────────────────────────────────────────

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.profile});

  final UserProfile profile;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Sādhu 🙏';
    if (hour < 12) return 'Chào buổi sáng 🌅';
    if (hour < 17) return 'Chào buổi chiều ☀️';
    if (hour < 20) return 'Chào buổi tối 🌙';
    return 'Sādhu 🙏';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textHint,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.displayName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.earthBrown,
              ),
        ),
        if (profile.streakDays > 0) ...[
          const SizedBox(height: 6),
          StreakBadge(days: profile.streakDays),
        ],
      ],
    );
  }
}

class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.saffronGlow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.saffronLight.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            '$days ngày liên tiếp',
            style: GoogleFonts.lato(
              color: AppColors.saffron,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// USER PROFILE CARD - Hiển thị 3 trục chính
// ─────────────────────────────────────────────────────────────

class UserProfileCard extends StatelessWidget {
  const UserProfileCard({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.earthDark.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Card Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.earthBrown,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Text('🧘', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Ba Trục Tu Tập',
                  style: GoogleFonts.merriweather(
                    color: AppColors.creamLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Placement score badge
                if (profile.placementScore > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.saffron,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${profile.placementScore}đ',
                      style: GoogleFonts.lato(
                        color: AppColors.earthDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── 3 Axis Rows ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Trục 1: Ngôn ngữ - English Level
                AxisRow(
                  axis: 'Trục 1',
                  axisLabel: 'Ngôn ngữ',
                  icon: '🇬🇧',
                  color: AppColors.forestGreen,
                  value: englishLevelLabel(profile.englishLevel),
                  valueColor: AppColors.forestGreen,
                  progress: (profile.englishLevel.index + 1) / 6,
                  subValue: englishLevelDesc(profile.englishLevel),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.divider),
                ),
                // Trục 2: Thiền - Meditation Experience
                AxisRow(
                  axis: 'Trục 2',
                  axisLabel: 'Thiền định',
                  icon: '🧘',
                  color: AppColors.earthBrown,
                  value: meditationLabel(profile.meditationExperience),
                  valueColor: AppColors.earthBrown,
                  progress: (profile.meditationExperience.index + 1) / 5,
                  subValue: meditationDesc(profile.meditationExperience),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.divider),
                ),
                // Trục 3: Pali - Pali Level
                AxisRow(
                  axis: 'Trục 3',
                  axisLabel: 'Pali',
                  icon: '📿',
                  color: AppColors.saffron,
                  value: paliLabel(profile.paliLevel),
                  valueColor: AppColors.saffron,
                  progress: (profile.paliLevel.index + 1) / 4,
                  subValue: paliDesc(profile.paliLevel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Label helpers ──

  String englishLevelLabel(EnglishLevel level) {
    const labels = {
      EnglishLevel.a1: 'A1',
      EnglishLevel.a2: 'A2',
      EnglishLevel.b1: 'B1',
      EnglishLevel.b2: 'B2',
      EnglishLevel.c1: 'C1',
      EnglishLevel.c2: 'C2',
    };
    return labels[level] ?? 'A1';
  }

  String englishLevelDesc(EnglishLevel level) {
    const desc = {
      EnglishLevel.a1: 'Mới bắt đầu',
      EnglishLevel.a2: 'Cơ bản',
      EnglishLevel.b1: 'Trung cấp',
      EnglishLevel.b2: 'Trên trung cấp',
      EnglishLevel.c1: 'Nâng cao',
      EnglishLevel.c2: 'Thành thạo',
    };
    return desc[level] ?? '';
  }

  String meditationLabel(MeditationExperience exp) {
    const labels = {
      MeditationExperience.none: 'Chưa thiền',
      MeditationExperience.beginner: 'Mới bắt đầu',
      MeditationExperience.intermediate: 'Trung cấp',
      MeditationExperience.advanced: 'Nâng cao',
      MeditationExperience.teacher: 'Thiền sư',
    };
    return labels[exp] ?? 'Chưa thiền';
  }

  String meditationDesc(MeditationExperience exp) {
    const desc = {
      MeditationExperience.none: 'Chưa có kinh nghiệm',
      MeditationExperience.beginner: 'Dưới 1 năm',
      MeditationExperience.intermediate: '1–3 năm',
      MeditationExperience.advanced: '3–10 năm',
      MeditationExperience.teacher: 'Giảng dạy thiền',
    };
    return desc[exp] ?? '';
  }

  String paliLabel(PaliLevel level) {
    const labels = {
      PaliLevel.none: 'Chưa biết',
      PaliLevel.basic: 'Cơ bản',
      PaliLevel.intermediate: 'Trung cấp',
      PaliLevel.advanced: 'Nâng cao',
    };
    return labels[level] ?? 'Chưa biết';
  }

  String paliDesc(PaliLevel level) {
    const desc = {
      PaliLevel.none: 'Chưa học Pali',
      PaliLevel.basic: 'Biết một số từ',
      PaliLevel.intermediate: 'Đọc được kinh',
      PaliLevel.advanced: 'Đọc & dịch thành thạo',
    };
    return desc[level] ?? '';
  }
}

// ── Single axis row widget ──
class AxisRow extends StatelessWidget {
  const AxisRow({
    super.key,
    required this.axis,
    required this.axisLabel,
    required this.icon,
    required this.color,
    required this.value,
    required this.valueColor,
    required this.progress,
    required this.subValue,
  });

  final String axis;
  final String axisLabel;
  final String icon;
  final Color color;
  final String value;
  final Color valueColor;
  final double progress; // 0.0 → 1.0
  final String subValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon circle
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(width: 12),

        // Label + Progress
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$axis · $axisLabel',
                    style: GoogleFonts.lato(
                      color: AppColors.textHint,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: valueColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      value,
                      style: GoogleFonts.lato(
                        color: valueColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: color.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subValue,
                style: GoogleFonts.lato(
                  color: AppColors.textHint,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SMART SUGGESTION CARD
// ─────────────────────────────────────────────────────────────

class SmartSuggestionCard extends StatelessWidget {
  const SmartSuggestionCard({super.key, required this.lesson});

  final Lesson lesson;

  Color get typeColor {
    switch (lesson.type) {
      case LessonType.vocabulary:
        return AppColors.forestGreen;
      case LessonType.conversation:
        return AppColors.earthBrown;
      case LessonType.listening:
        return AppColors.mossGreen;
      case LessonType.reading:
        return AppColors.earthLight;
      case LessonType.dhamma:
        return AppColors.saffron;
    }
  }

  String get typeLabel {
    switch (lesson.type) {
      case LessonType.vocabulary:
        return 'Từ vựng';
      case LessonType.conversation:
        return 'Hội thoại';
      case LessonType.listening:
        return 'Nghe';
      case LessonType.reading:
        return 'Đọc hiểu';
      case LessonType.dhamma:
        return 'Pháp thoại';
    }
  }

  String get difficultyLabel {
    switch (lesson.difficulty) {
      case LessonDifficulty.beginner:
        return 'Cơ bản';
      case LessonDifficulty.intermediate:
        return 'Trung cấp';
      case LessonDifficulty.advanced:
        return 'Nâng cao';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/lesson/${lesson.id}'),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.saffronGlow,
              AppColors.cream,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.saffronLight.withOpacity(0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.saffron.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  // AI suggested badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.saffron,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AI đề xuất',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      typeLabel,
                      style: GoogleFonts.lato(
                        color: typeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pali title (italic)
                  if (lesson.titlePali.isNotEmpty) ...[
                    Text(
                      lesson.titlePali,
                      style: GoogleFonts.lato(
                        color: AppColors.saffron,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  // Main title
                  Text(
                    lesson.title,
                    style: GoogleFonts.merriweather(
                      color: AppColors.earthDark,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    lesson.description,
                    style: GoogleFonts.lato(
                      color: AppColors.textSecond,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),

                  // ── Meta row: time, difficulty, points ──
                  Row(
                    children: [
                      MetaChip(
                        icon: Icons.access_time_rounded,
                        label: '${lesson.estimatedMinutes} phút',
                      ),
                      const SizedBox(width: 8),
                      MetaChip(
                        icon: Icons.bar_chart_rounded,
                        label: difficultyLabel,
                      ),
                      const SizedBox(width: 8),
                      MetaChip(
                        icon: Icons.stars_rounded,
                        label: '+${lesson.rewardPoints}đ',
                        color: AppColors.saffron,
                      ),
                      const Spacer(),
                      // Arrow button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.earthBrown,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Tags ──
            if (lesson.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Wrap(
                  spacing: 6,
                  children:
                      lesson.tags.map((tag) => TagChip(tag: tag)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MetaChip extends StatelessWidget {
  const MetaChip({
    super.key,
    required this.icon,
    required this.label,
    this.color = AppColors.textHint,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.lato(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '#$tag',
        style: GoogleFonts.lato(
          color: AppColors.textHint,
          fontSize: 10,
        ),
      ),
    );
  }
}

class NoSuggestionCard extends StatelessWidget {
  const NoSuggestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          const Text('🌸', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Đang chuẩn bị bài học phù hợp...',
            style: GoogleFonts.lato(
              color: AppColors.textHint,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AI INTERVIEW BUTTON
// ─────────────────────────────────────────────────────────────

class AIInterviewButton extends StatelessWidget {
  const AIInterviewButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/ai-interview'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.earthBrown,
              AppColors.earthDark,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.earthDark.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated dot indicator
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.saffronLight,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bắt đầu AI Interview',
                  style: GoogleFonts.merriweather(
                    color: AppColors.creamLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Luyện nói với AI • Cá nhân hóa hoàn toàn',
                  style: GoogleFonts.lato(
                    color: AppColors.warmTaupe,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.mic_rounded,
              color: AppColors.saffronLight,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STATS ROW
// ─────────────────────────────────────────────────────────────

class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: '📚',
            value: '${profile.completedLessons}',
            label: 'Bài hoàn thành',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: '🔥',
            value: '${profile.streakDays}',
            label: 'Ngày streak',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: '⭐',
            value: '${profile.placementScore}',
            label: 'Điểm test',
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.merriweather(
              color: AppColors.earthBrown,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.lato(
              color: AppColors.textHint,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────────

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.saffron,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.merriweather(
            color: AppColors.earthBrown,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(
            'Có lỗi xảy ra',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OptionsBottomSheet extends StatelessWidget {
  const OptionsBottomSheet({super.key, required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tùy chọn',
              style: GoogleFonts.merriweather(
                color: AppColors.earthBrown,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading:
                  const Icon(Icons.refresh_rounded, color: AppColors.error),
              title: Text(
                'Làm lại bài kiểm tra đầu vào',
                style: GoogleFonts.lato(color: AppColors.error),
              ),
              subtitle: Text(
                'Xóa hồ sơ và bắt đầu lại',
                style: GoogleFonts.lato(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              ),
              onTap: onReset,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

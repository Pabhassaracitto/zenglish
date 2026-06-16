// ============================================================
// APP ROUTER - GoRouter với redirect logic
//
// Luồng:
//   / → check profile → /placement hoặc /home
//   /placement → PlacementTestScreen
//   /home → HomeScreen
//   /lesson/:id → LessonScreen
//   /ai-interview → AIInterviewScreen (placeholder)
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:zenglish/core/theme/app_theme.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../providers/user_profile_provider.dart';
import '../../data/models/user_profile.dart';
import '../../core/enums/cefr_level.dart';
import '../../core/enums/meditation_stage.dart';

// ── Tên route (constants để tránh typo) ──
abstract class AppRoutes {
  static const String splash = '/';
  static const String placement = '/placement';
  static const String home = '/home';
  static const String lesson = '/lesson';
  static const String aiInterview = '/ai-interview';
}

// ── Router Provider ──
final appRouterProvider = Provider<GoRouter>((ref) {
  // Listen to profile changes để trigger redirect
  final routerNotifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: routerNotifier,
    debugLogDiagnostics: false, // Set false khi production

    // ── REDIRECT LOGIC ──
    redirect: (context, state) {
      final profileState = ref.read(userProfileProvider);
      final isLoading = profileState.isLoading;
      final hasProfile = profileState.valueOrNull != null;

      final currentPath = state.matchedLocation;

      // Đang loading → chờ (không redirect)
      if (isLoading) return null;

      // Chưa có profile → bắt buộc phải làm placement test
      if (!hasProfile) {
        // Nếu đang ở placement → OK, không redirect
        if (currentPath == AppRoutes.placement) return null;
        // Mọi nơi khác → về placement
        return AppRoutes.placement;
      }

      // Đã có profile → không cho vào splash hoặc placement nữa
      if (hasProfile) {
        if (currentPath == AppRoutes.splash ||
            currentPath == AppRoutes.placement) {
          return AppRoutes.home;
        }
      }

      return null; // Không redirect
    },

    // ── ROUTES ──
    routes: [
      // Root splash - chỉ dùng như entry point
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Placement Test
      GoRoute(
        path: AppRoutes.placement,
        name: 'placement',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PlacementTestScreen(),
          transitionsBuilder: fadeTransition,
        ),
      ),

      // Home
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: fadeTransition,
        ),
      ),

      // Lesson với dynamic id
      GoRoute(
        path: '${AppRoutes.lesson}/:lessonId',
        name: 'lesson',
        pageBuilder: (context, state) {
          final lessonId = state.pathParameters['lessonId'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: LessonScreen(lessonId: lessonId),
            transitionsBuilder: slideUpTransition,
          );
        },
      ),

      // AI Interview
      GoRoute(
        path: AppRoutes.aiInterview,
        name: 'ai-interview',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AIInterviewScreen(),
          transitionsBuilder: slideUpTransition,
        ),
      ),
    ],

    // ── ERROR PAGE ──
    errorBuilder: (context, state) => RouterErrorPage(
      error: state.error?.toString() ?? 'Trang không tồn tại',
    ),
  );
});

// ─────────────────────────────────────────────────────────────
// ROUTER NOTIFIER - Để GoRouter listen Riverpod state
// ─────────────────────────────────────────────────────────────

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    // Lắng nghe userProfile thay đổi → notify router để re-evaluate redirect
    ref.listen(userProfileProvider, (previous, next) {
      // Chỉ notify khi state thực sự thay đổi (tránh loop)
      if (previous?.valueOrNull != next.valueOrNull ||
          previous?.isLoading != next.isLoading) {
        notifyListeners();
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────
// PAGE TRANSITIONS
// ─────────────────────────────────────────────────────────────

Widget fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
    child: child,
  );
}

Widget slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    )),
    child: FadeTransition(
      opacity: CurveTween(curve: Curves.easeIn).animate(animation),
      child: child,
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// SPLASH SCREEN - Hiện trong lúc check profile state
// ─────────────────────────────────────────────────────────────

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Router sẽ tự redirect, screen này chỉ hiện thoáng qua
    return Scaffold(
      backgroundColor: AppTheme.cardBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text('☸️', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'English for Wisdom & Meditation',
              style: GoogleFonts.merriweather(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ERROR PAGE
// ─────────────────────────────────────────────────────────────

class RouterErrorPage extends StatelessWidget {
  const RouterErrorPage({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🙏', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Lỗi điều hướng',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.earthBrown,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PLACEHOLDER SCREENS - Những screen chưa implement
// Thay bằng import thực khi code xong
// ─────────────────────────────────────────────────────────────

class PlacementTestScreen extends StatelessWidget {
  const PlacementTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamLight,
      appBar: AppBar(title: const Text('Bài kiểm tra đầu vào')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📝', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 20),
              Text(
                'Placement Test',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'PlacementTestScreen đã được implement\nở file riêng',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Demo: Simulate complete test
              Consumer(
                builder: (context, ref, _) => ElevatedButton(
                  onPressed: () async {
                    // Tạo mock profile để test luồng
                    await ref.read(userProfileProvider.notifier).saveProfile(
                          UserProfile(
                            userId: 'user001',
                            displayName: 'Sư Minh Tuệ',
                            languageLevel: CEFRLevel.b1,
                            meditationStage: MeditationStage.samathaPreiliminary,
                            paliKnowledgeLevel: 2,
                            completedLessonIds: const [],
                            inProgressLessonIds: const [],
                            placementScore: 72,
                            streakDays: 1,
                            createdAt: DateTime.now(),
                            lastStudiedAt: DateTime.now(),
                          ),
                        );
                    if (context.mounted) context.go(AppRoutes.home);
                  },
                  child: const Text('Hoàn thành Test (Demo)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamLight,
      appBar: AppBar(
        title: Text('Bài học: $lessonId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📖', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'LessonScreen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Lesson ID: $lessonId',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class AIInterviewScreen extends StatelessWidget {
  const AIInterviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamLight,
      appBar: AppBar(
        title: const Text('AI Interview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎙️', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text('AIInterviewEngine sẽ được tích hợp ở đây'),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenglish/core/theme/app_theme.dart';
import 'package:zenglish/presentation/providers/audio_provider.dart';
import 'package:zenglish/presentation/providers/lesson_provider.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({
    super.key,
    required this.lessonId,
  });
  
  final String lessonId;
  
  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}
  
class _LessonScreenState extends ConsumerState<LessonScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lessonProvider.notifier).loadLesson(widget.lessonId);
    });
  }
  
  @override
  void dispose() {
    // Stop và cleanup audio khi đóng màn hình
    ref.read(audioProvider.notifier).stop();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonProvider);

    // Loading state
    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Error state - Fallback UI
    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Content Not Available'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 40,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMD),
                const Text(
                  'Content Not Available Yet',
                  style: AppTheme.headingMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spaceSM),
                Text(
                  state.error ?? 'This lesson could not be loaded. Please try again later.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spaceLG),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // No lesson found
    if (!state.hasLesson) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lesson Not Found'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMD),
                const Text(
                  'Content Not Available',
                  style: AppTheme.headingMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spaceSM),
                Text(
                  'The lesson you are looking for does not exist or has not been loaded yet.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spaceLG),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Success state - render lesson
    // TODO: Implement actual lesson content rendering
    return Scaffold(
      appBar: AppBar(
        title: Text(state.lesson?.titleEn ?? 'Lesson'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text('Lesson loaded: ${state.lesson?.lessonId}'),
      ),
    );
  }
}

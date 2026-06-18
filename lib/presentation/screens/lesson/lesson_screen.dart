import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenglish/core/theme/app_theme.dart';
import 'package:zenglish/data/models/lesson.dart';
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
    final lesson = state.lesson!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.titleEn),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.titleEn,
                    style: AppTheme.headingLarge,
                  ),
                  const SizedBox(height: AppTheme.spaceSM),
                  Text(
                    'Level: ${lesson.level} • ID: ${lesson.lessonId}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceLG),
            
            // Lesson flow stages
            Text(
              'Lesson Flow',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            
            // Input Stage
            _buildStageCard(
              'Input (Nghe & Hiểu)',
              '${lesson.lessonFlow.input.sampleDialogues.length} dialogues',
              Icons.hearing,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            
            // Pattern Stage
            _buildStageCard(
              'Pattern (Mẫu Câu)',
              '${lesson.lessonFlow.pattern.corePatterns.length} patterns',
              Icons.abc,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            
            // Guided Stage
            _buildStageCard(
              'Guided (Luyện Tập)',
              '${lesson.lessonFlow.guided.interviewSteps.length} steps',
              Icons.people,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            
            // Output Stage
            _buildStageCard(
              'Output (Tự Nói)',
              '${lesson.lessonFlow.output.evaluationCriteria.length} criteria',
              Icons.mic,
            ),
            const SizedBox(height: AppTheme.spaceLG),
            
            // Vocabulary
            Text(
              'Vocabulary (${lesson.vocabulary.length} words)',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            ..._buildVocabularyList(lesson),
          ],
        ),
      ),
    );
  }

  Widget _buildStageCard(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primary),
            ),
            const SizedBox(width: AppTheme.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildVocabularyList(Lesson lesson) {
    return lesson.vocabulary.take(5).map((vocab) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spaceSM),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(vocab.english, style: AppTheme.bodyLarge),
                  if (vocab.isHighPriority)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('High Priority', style: TextStyle(fontSize: 10, color: Colors.red)),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Vietnamese: ${vocab.vietnamese}', style: const TextStyle(fontSize: 13)),
              if ((vocab.pali?.isNotEmpty ?? false)) ...[
                const SizedBox(height: 2),
                Text('Pali: ${vocab.pali}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    // ... existing build code
    return Container(); // Placeholder for the rest of the build method
  }
}

// lib/presentation/screens/lesson/stages/pattern_view_stage.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenglish/core/theme/app_theme.dart';
import 'package:zenglish/data/models/lesson.dart';
import 'package:zenglish/data/models/lesson_flow.dart';

import '../../../providers/lesson_provider.dart';

/// Stage chỉ hiển thị Core Patterns (Mẫu Câu) của bài học
/// Không có tương tác, chỉ để học và ghi nhớ cấu trúc câu
class PatternViewStage extends ConsumerWidget {
  const PatternViewStage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonProvider);
    final lesson = state.lesson;

    if (lesson == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final patterns = lesson.lessonFlow.pattern.corePatterns;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _StageTitleCard(
            icon: Icons.abc_rounded,
            title: 'Mẫu Câu Cốt Lõi',
            subtitle: 'Học các cấu trúc câu quan trọng trong bài này.',
          ),
          const SizedBox(height: 16),

          if (patterns.isEmpty)
            const Center(
              child: Text(
                'Chưa có mẫu câu nào trong bài học này.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...patterns.asMap().entries.map((entry) {
              final index = entry.key;
              final pattern = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _PatternCard(
                  pattern: pattern,
                  index: index + 1,
                ),
              );
            }),

          const SizedBox(height: 24),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final notifier = ref.read(lessonProvider.notifier);
                notifier.markCurrentStageComplete();
                notifier.nextStage();
              },
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Tiếp theo: Nối Từ →'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageTitleCard extends StatelessWidget {
  const _StageTitleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.12),
            AppTheme.primary.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12, 
                    color: Colors.grey
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternCard extends StatelessWidget {
  const _PatternCard({
    required this.pattern,
    required this.index,
  });

  final CorePattern pattern;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pattern number and function
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pattern.function,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),

            // Pattern template (main structure)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.2),
                ),
              ),
              child: Text(
                pattern.template,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'monospace',
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Monastery note (if available)
            if (pattern.monasteryEnglishNote != null &&
                pattern.monasteryEnglishNote!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pattern.monasteryEnglishNote!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.amber,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Examples
            if (pattern.examples.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              const Text(
                'Ví dụ:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              ...pattern.examples.take(3).map(
                (example) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          example,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (pattern.examples.length > 3)
                Text(
                  '... và ${pattern.examples.length - 3} ví dụ khác',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
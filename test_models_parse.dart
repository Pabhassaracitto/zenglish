import 'dart:convert';
import 'dart:io';
import 'lib/data/models/lesson.dart';

void main() {
  final files = [
    'assets/data/lessons/A1_CH05_L01.json',
    'assets/data/lessons/A2_CH06_L01.json',
    'assets/data/lessons/A2_CH07_L01.json',
    'assets/data/lessons/B1_CH12_L01.json',
  ];

  for (final filePath in files) {
    print('\n======================================');
    print('Testing $filePath:');
    final file = File(filePath);
    if (!file.existsSync()) {
      print('❌ File does not exist!');
      continue;
    }
    
    final content = file.readAsStringSync();
    try {
      final json = jsonDecode(content) as Map<String, dynamic>;
      final lesson = Lesson.fromJson(json);
      print('✅ Success! Raw parse status:');
      print('   Lesson ID: ${lesson.lessonId}');
      print('   Title: ${lesson.titleEn}');
      print('   Vocabulary Count: ${lesson.vocabulary.length}');
    } catch (e, stack) {
      print('❌ Parse failed: $e');
      print(stack);
    }
  }
}

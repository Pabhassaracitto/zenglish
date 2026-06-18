import 'dart:convert';
import 'dart:io';

void main() {
  final jsonFile = File('assets/data/lessons/A2_CH06_L01.json');
  final content = jsonFile.readAsStringSync();
  
  try {
    final json = jsonDecode(content) as Map<String, dynamic>;
    print('✅ JSON parse success');
    print('   lesson_id: ${json['lesson_id']}');
    print('   title_en: ${json['title_en']}');
    print('   lesson_flow keys: ${(json['lesson_flow'] as Map).keys}');
    print('   guided.interview_steps count: ${((json['lesson_flow'] as Map)['guided'] as Map)['interview_steps']?.length ?? 0}');
  } catch (e) {
    print('❌ JSON parse error: $e');
  }
}

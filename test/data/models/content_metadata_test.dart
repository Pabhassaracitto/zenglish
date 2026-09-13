import 'package:flutter_test/flutter_test.dart';
import 'package:zenglish/data/models/lesson_flow.dart';
import 'package:zenglish/data/models/vocab_item.dart';

void main() {
  const vocab = {
    'stt': 1, 'en': 'breath', 'vi': 'hơi thở',
    'example_en': 'I notice the breath.', 'example_context': 'Practice',
    'priority': 'High',
  };
  test('explicit audio flag takes precedence over legacy note', () {
    expect(VocabItem.fromJson({...vocab, 'needs_audio': true}).needsAudio, isTrue);
    expect(VocabItem.fromJson({...vocab, 'note': '[NEEDS AUDIO]'}).needsAudio, isTrue);
    expect(VocabItem.fromJson({
      ...vocab, 'needs_audio': false, 'note': '[NEEDS AUDIO]',
    }).needsAudio, isFalse);
  });
  test('reading text survives serialization and blank audio is unavailable', () {
    final input = InputPhase.fromJson({
      'title': 'Read', 'description': 'Read an email',
      'reading_text_en': 'Dear Monastery Office,',
      'email_structure_note': 'Introduce yourself.', 'audio_url': '  ',
    });
    expect(input.audioUrl, isNull);
    final restored = InputPhase.fromJson(input.toJson());
    expect(restored.readingTextEn, input.readingTextEn);
    expect(restored.readingNote, input.readingNote);
  });
}

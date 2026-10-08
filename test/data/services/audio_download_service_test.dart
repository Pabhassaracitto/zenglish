import 'package:flutter_test/flutter_test.dart';
import 'package:zenglish/data/services/audio_download_service.dart';

void main() {
  test('encode/parse index: round-trip giữ nguyên thông tin file', () {
    const info = DownloadedAudioInfo(
      fileName: 'A1_CH01_L01_input_01.mp3',
      lessonId: 'A1_CH01_L01',
      bytes: 123456,
      downloadedAtMillis: 1728300000000,
    );
    final encoded = encodeAudioIndex({info.fileName: info});
    final parsed = parseAudioIndex(encoded);

    expect(parsed, hasLength(1));
    final restored = parsed['A1_CH01_L01_input_01.mp3'];
    expect(restored, isNotNull);
    expect(restored!.lessonId, 'A1_CH01_L01');
    expect(restored.bytes, 123456);
    expect(restored.downloadedAtMillis, 1728300000000);
  });

  test('parse index: dữ liệu hỏng trả về rỗng thay vì crash', () {
    expect(parseAudioIndex(null), isEmpty);
    expect(parseAudioIndex(''), isEmpty);
    expect(parseAudioIndex('{không phải json'), isEmpty);
    expect(parseAudioIndex('{"version":1,"files":"oops"}'), isEmpty);
    expect(parseAudioIndex('[1,2,3]'), isEmpty);
  });

  test('parse index: entry thiếu trường bắt buộc bị bỏ qua', () {
    final parsed = parseAudioIndex(
      '{"version":1,"files":{"a.mp3":{"bytes":1}}}',
    );
    expect(parsed, isEmpty);
  });

  test('parse index: entry hợp lệ giữa đống hỏng vẫn đọc được', () {
    final parsed = parseAudioIndex(
      '{"version":1,"files":{'
      '"ok.mp3":{"file_name":"ok.mp3","lesson_id":"A1_CH01_L01",'
      '"bytes":10,"downloaded_at":7},'
      '"bad.mp3":{"bytes":1}}}',
    );
    expect(parsed.keys, ['ok.mp3']);
    expect(parsed['ok.mp3']!.bytes, 10);
  });
}

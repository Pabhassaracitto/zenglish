import 'package:flutter_test/flutter_test.dart';
import 'package:zenglish/data/constants/audio_catalog.dart';
import 'package:zenglish/data/constants/lesson_asset_registry.dart';

void main() {
  test('mọi bài trong registry đều có audio trong danh mục Hugging Face', () {
    for (final path in LessonAssetRegistry.allPaths) {
      final lessonId = path.split('/').last.replaceAll('.json', '');
      expect(AudioCatalog.filesForLesson(lessonId), isNotEmpty,
          reason: lessonId);
      expect(AudioCatalog.estimatedBytesForLesson(lessonId), greaterThan(0),
          reason: lessonId);
    }
  });

  test('tên file đúng quy ước <LESSON_ID>_input_NN.mp3 và không trùng', () {
    final seen = <String>{};
    for (final file in AudioCatalog.files) {
      expect(
        AudioCatalog.followsFileNameConvention(file.lessonId, file.fileName),
        isTrue,
        reason: file.fileName,
      );
      expect(seen.add(file.fileName), isTrue,
          reason: 'file trùng: ${file.fileName}');
      expect(file.estimatedBytes, greaterThan(0), reason: file.fileName);
      expect(file.remoteUrl,
          '${AudioCatalog.huggingFaceBaseUrl}${file.fileName}');
      expect(file.bundledAssetPath, 'assets/audio/${file.fileName}');
    }
  });

  test('isCatalogFileName phân biệt file danh mục AI với bản thu ngoài', () {
    expect(AudioCatalog.isCatalogFileName(AudioCatalog.files.first.fileName),
        isTrue);
    expect(AudioCatalog.isCatalogFileName('human_recording.mp3'), isFalse);
    expect(AudioCatalog.isCatalogFileName('assets/audio/demo.mp3'), isFalse);
  });

  test('ước tính dung lượng toàn bộ khớp tổng từng file', () {
    final sum =
        AudioCatalog.files.fold<int>(0, (acc, f) => acc + f.estimatedBytes);
    expect(AudioCatalog.estimatedBytesTotal, sum);
  });
}

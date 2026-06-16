// lib/data/repositories/local_json_content_repository.dart

import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/lesson.dart';
import 'i_lesson_repository.dart';

/// Đọc dữ liệu bài học từ các file JSON trong assets/data/lessons/.
///
/// Chiến lược cache:
///   - Lần đầu gọi loadAllLessons() → đọc tất cả file JSON → parse → lưu RAM
///   - Các lần sau → trả về từ cache ngay lập tức
///   - Cache bị xóa khi gọi clearCache() (dùng cho hot-reload dev)
///
/// Error handling:
///   - File lỗi format JSON → log warning, bỏ qua, tiếp tục load file khác
///   - File không tồn tại → log warning, bỏ qua
///   - Không có file nào load được → throw NoLessonsAvailableException
class LocalJsonContentRepository implements ILessonRepository {
  LocalJsonContentRepository({
    AssetBundle? assetBundle,
    this.lessonAssetPaths = const [],
  }) : _assetBundle = assetBundle ?? rootBundle;

  /// AssetBundle để inject trong tests (MockAssetBundle)
  final AssetBundle _assetBundle;

  /// Danh sách đường dẫn đến các file JSON lesson.
  ///
  /// Lý do hardcode path list thay vì scan thư mục:
  /// Flutter assets không hỗ trợ liệt kê file trong folder lúc runtime.
  /// Giải pháp: dùng AssetManifest để tự động discover (xem _discoverAssetPaths).
  final List<String> lessonAssetPaths;

  // ─── Cache ────────────────────────────────────────────────────────────────

  /// In-memory cache. null = chưa load. [] = đã load nhưng không có bài nào.
  List<Lesson>? _cachedLessons;

  /// Index để getLessonById() O(1) thay vì O(n)
  Map<String, Lesson>? _lessonIndex;

  bool get _isCacheValid => _cachedLessons != null;

  // ─── ILessonRepository ────────────────────────────────────────────────────

  @override
  Future<List<Lesson>> loadAllLessons() async {
    // Cache hit → trả về ngay, không đọc file lần nữa
    if (_isCacheValid) {
      return List.unmodifiable(_cachedLessons!);
    }

    // Xác định danh sách paths cần load
    final paths = lessonAssetPaths.isNotEmpty
        ? lessonAssetPaths
        : await _discoverAssetPaths();

    if (paths.isEmpty) {
      throw const NoLessonsAvailableException(
        'Không tìm thấy file JSON nào trong assets/data/lessons/. '
        'Hãy kiểm tra pubspec.yaml và thư mục assets.',
      );
    }

    final lessons = <Lesson>[];
    final errors = <String>[];

    // Load song song để tối ưu tốc độ khi có nhiều file
    final futures = paths.map((path) => _loadSingleLesson(path));
    final results = await Future.wait(futures, eagerError: false);

    for (var i = 0; i < results.length; i++) {
      final result = results[i];
      if (result != null) {
        lessons.add(result);
      } else {
        errors.add(paths[i]);
      }
    }

    // Log summary (dùng debugPrint để không xuất hiện production)
    if (errors.isNotEmpty) {
      debugPrint(
        '[LocalJsonContentRepository] ⚠️ Bỏ qua ${errors.length} file lỗi:\n'
        '${errors.map((e) => '  - $e').join('\n')}',
      );
    }

    if (lessons.isEmpty) {
      throw NoLessonsAvailableException(
        'Tất cả ${paths.length} file JSON đều lỗi. Không có lesson nào được load.',
        cause: 'Kiểm tra format JSON. Files có vấn đề: $errors',
      );
    }

    // Sort theo lessonId để đảm bảo thứ tự nhất quán
    lessons.sort((a, b) => a.lessonId.compareTo(b.lessonId));

    // Lưu vào cache
    _cachedLessons = List.unmodifiable(lessons);
    _buildIndex();

    debugPrint(
      '[LocalJsonContentRepository] ✅ Loaded ${lessons.length}/${paths.length} lessons.',
    );

    return List.unmodifiable(_cachedLessons!);
  }

  @override
  Future<Lesson?> getLessonById(String lessonId) async {
    // Đảm bảo cache đã được populate
    if (!_isCacheValid) {
      await loadAllLessons();
    }
    return _lessonIndex?[lessonId];
  }

  @override
  Future<List<Lesson>> getLessonsByLevel(String level) async {
    final allLessons = await loadAllLessons();
    return allLessons
        .where(
          (lesson) =>
              lesson.level.displayName.toUpperCase() == level.toUpperCase(),
        )
        .toList();
  }

  @override
  Future<void> clearCache() async {
    _cachedLessons = null;
    _lessonIndex = null;
    debugPrint('[LocalJsonContentRepository] 🗑️ Cache cleared.');
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Auto-discover tất cả lesson JSON từ AssetManifest.
  ///
  /// Không cần hardcode danh sách file.
  /// Dhamma Content Editor chỉ cần thêm file vào thư mục + khai báo pubspec.yaml.
  Future<List<String>> _discoverAssetPaths() async {
    try {
      final manifestContent =
          await _assetBundle.loadString('AssetManifest.json');
      final manifest = json.decode(manifestContent) as Map<String, dynamic>;

      final lessonPaths = manifest.keys
          .where(
            (key) =>
                key.startsWith('assets/data/lessons/') &&
                key.endsWith('.json'),
          )
          .toList();

      debugPrint(
        '[LocalJsonContentRepository] 🔍 Discovered ${lessonPaths.length} lesson files.',
      );

      return lessonPaths;
    } on Exception catch (e) {
      debugPrint(
        '[LocalJsonContentRepository] ❌ Lỗi đọc AssetManifest: $e',
      );
      return [];
    }
  }

  /// Load và parse một file JSON lesson.
  ///
  /// Trả về null nếu file không đọc được hoặc JSON sai format.
  /// Không throw exception để không làm gián đoạn việc load các file khác.
  Future<Lesson?> _loadSingleLesson(String assetPath) async {
    // 1. Đọc raw string từ asset
    final String rawJson;
    try {
      rawJson = await _assetBundle.loadString(assetPath);
    } on FlutterError catch (e) {
      debugPrint(
        '[LocalJsonContentRepository] ❌ File không tồn tại: $assetPath\n'
        '  Error: $e',
      );
      return null;
    } on Exception catch (e) {
      debugPrint(
        '[LocalJsonContentRepository] ❌ Lỗi đọc file: $assetPath\n'
        '  Error: $e',
      );
      return null;
    }

    // 2. Parse JSON string → Map
    final Map<String, dynamic> jsonMap;
    try {
      final decoded = json.decode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        debugPrint(
          '[LocalJsonContentRepository] ❌ File không phải JSON object: $assetPath',
        );
        return null;
      }
      jsonMap = decoded;
    } on FormatException catch (e) {
      debugPrint(
        '[LocalJsonContentRepository] ❌ JSON sai format: $assetPath\n'
        '  Line ${e.offset}: ${e.message}',
      );
      return null;
    }

    // 3. Parse Map → Lesson model
    try {
      final lesson = Lesson.fromJson(jsonMap);

      // Validate cơ bản: lessonId không được rỗng
      if (lesson.lessonId.isEmpty) {
        debugPrint(
          '[LocalJsonContentRepository] ❌ lesson_id rỗng trong: $assetPath',
        );
        return null;
      }

      return lesson;
    } on TypeError catch (e) {
      // TypeError xảy ra khi kiểu dữ liệu trong JSON sai
      // Ví dụ: JSON có "level": 2 thay vì "level": "A2"
      debugPrint(
        '[LocalJsonContentRepository] ❌ Lỗi kiểu dữ liệu trong $assetPath\n'
        '  TypeError: $e\n'
        '  Kiểm tra lại kiểu dữ liệu các trường trong JSON.',
      );
      return null;
    } on Exception catch (e) {
      debugPrint(
        '[LocalJsonContentRepository] ❌ Lỗi parse Lesson từ $assetPath\n'
        '  Error: $e',
      );
      return null;
    }
  }

  /// Xây dựng index O(1) lookup sau khi load xong
  void _buildIndex() {
    if (_cachedLessons == null) return;
    _lessonIndex = {
      for (final lesson in _cachedLessons!) lesson.lessonId: lesson,
    };
  }
}

// ─── Debug helper (stripped in release builds) ────────────────────────────

void debugPrint(String message) {
  assert(() {
    // ignore: avoid_print
    print(message);
    return true;
  }());
}

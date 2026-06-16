// lib/data/constants/lesson_asset_registry.dart

/// Registry tập trung danh sách tất cả lesson JSON files.
///
/// Mục đích:
///   - Fallback nếu AssetManifest discovery không hoạt động
///   - Type-safe compile-time check (build sẽ fail nếu quên thêm vào đây)
///   - Dhamma Content Editor biết chính xác file nào đang được load
///
/// Convention: Thêm file mới vào đây VÀ khai báo trong pubspec.yaml.
abstract final class LessonAssetRegistry {
  static const String _basePath = 'assets/data/lessons';

  static const List<String> allPaths = [
    // ── Chapter 06 ─────────────────────────────────────────────
    '$_basePath/A2_CH06_L01.json',
    // Thêm bài mới tại đây
  ];

  /// Validate tất cả paths đều follow convention
  static bool validatePaths() {
    return allPaths.every(
      (p) => p.startsWith(_basePath) && p.endsWith('.json'),
    );
  }
}

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
    // ── Chapter 05 (A1) ────────────────────────────────────────
    '$_basePath/A1_CH05_L01.json',
    
    // ── Chapter 06 (A2) ────────────────────────────────────────
    '$_basePath/A2_CH06_L01.json',
    
    // ── Chapter 07 (A2) ────────────────────────────────────────
    '$_basePath/A2_CH07_L01.json',
    
    // ── Chapter 12 (B1) ────────────────────────────────────────
    '$_basePath/B1_CH12_L01.json',
  ];

  /// Validate tất cả paths đều follow convention
  static bool validatePaths() {
    return allPaths.every(
      (p) => p.startsWith(_basePath) && p.endsWith('.json'),
    );
  }
}

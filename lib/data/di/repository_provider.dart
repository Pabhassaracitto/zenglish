// lib/data/di/repository_provider.dart

import '../repositories/firebase_repository.dart';
import '../repositories/i_lesson_repository.dart';
import '../repositories/local_json_content_repository.dart';

/// Central factory cho data layer.
///
/// Chiến lược swap implementation:
///
///   Dev/MVP     → LocalJsonContentRepository  (assets JSON)
///   Staging     → LocalJsonContentRepository  (assets JSON, validate)
///   Production  → FirebaseRepository          (Firestore)
///   A/B Testing → RemoteConfigRepository      (Firebase Remote Config)
///   Unit Test   → MockLessonRepository        (inject qua constructor)
///
/// KHÔNG có UI code nào import trực tiếp implementation cụ thể.
/// Tất cả đều đi qua ILessonRepository.
class RepositoryProvider {
  RepositoryProvider._(); // Prevent instantiation

  static ILessonRepository? _instance;

  /// Singleton instance. Lazy-initialized.
  static ILessonRepository get instance {
    _instance ??= _createRepository();
    return _instance!;
  }

  /// Cấu hình môi trường.
  /// Trong production, đọc từ --dart-define hoặc flavor config.
  static RepositoryEnvironment environment = RepositoryEnvironment.localJson;

  static ILessonRepository _createRepository() {
    switch (environment) {
      case RepositoryEnvironment.localJson:
        return LocalJsonContentRepository(
            // Không truyền lessonAssetPaths → tự động discover từ AssetManifest
            // Hoặc hardcode để tránh depend vào AssetManifest:
            // lessonAssetPaths: LessonAssetRegistry.allPaths,
            );

      case RepositoryEnvironment.firebase:
        return FirebaseRepository();

      case RepositoryEnvironment.mock:
        // Import mock chỉ khi cần (tránh bloat production binary)
        throw UnimplementedError(
          'Mock environment chỉ dùng trong tests. '
          'Inject MockLessonRepository trực tiếp trong test setup.',
        );
    }
  }

  /// Inject custom repository (dùng trong integration tests)
  static void overrideWith(ILessonRepository repository) {
    _instance = repository;
  }

  /// Reset về trạng thái ban đầu.
  /// Gọi sau mỗi test case để đảm bảo isolation.
  static void reset() {
    _instance = null;
  }
}

/// Enum định nghĩa các môi trường có thể swap.
enum RepositoryEnvironment {
  /// Đọc từ assets/data/lessons/*.json
  /// Dùng cho dev, MVP, offline mode
  localJson,

  /// Đọc từ Firestore
  /// Dùng cho production
  firebase,

  /// In-memory mock data
  /// Chỉ dùng trong unit tests
  mock,
}

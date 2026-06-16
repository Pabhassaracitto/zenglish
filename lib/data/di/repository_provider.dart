//lib\data\di\repository_provider.dart
import '../mock/mock_database.dart';
import '../repositories/firebase_repository.dart';
import '../repositories/lesson_repository.dart';

/// Swap giữa Mock và Firebase bằng 1 flag
/// Không cần thay đổi bất kỳ UI code nào
class RepositoryProvider {
  static LessonRepository? _instance;

  /// useMock = true → MockDatabase (MVP, không cần Firebase)
  /// useMock = false → FirebaseRepository (production)
  static LessonRepository get instance {
    _instance ??= _createRepository();
    return _instance!;
  }

  static bool useMock = true; // ← Đổi thành false khi deploy

  static LessonRepository _createRepository() {
    if (useMock) {
      final mock = MockDatabase();
      mock.seed(); // Load sample data
      return mock;
    }
    return FirebaseRepository();
  }

  /// Reset singleton (dùng trong testing)
  static void reset() => _instance = null;
}

/// lib/core/env/env.dart
/// 
/// Đọc API Key từ environment variable (--dart-define)
/// 
/// Cách dùng khi build/run:
/// flutter run --dart-define=OPENAI_API_KEY=sk-...
/// 
/// Cách dùng với VS Code launch.json:
/// "args": ["--dart-define=OPENAI_API_KEY=${env:OPENAI_API_KEY}"]
/// 
/// KHÔNG BKAO GIỜ hardcode key vào source code.
/// KHÔNG commit .env file vào git.
library;

class Env {
  Env._();

  /// OpenAI API Key — inject qua --dart-define khi build
  static const String openAIKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '', // Trống → service sẽ throw ConfigurationError
  );

  /// Model GPT muốn dùng — có thể override khi build
  static const String openAIModel = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-4o-mini', // Cost-efficient, đủ mạnh cho task này
  );

  /// Timeout (giây) — có thể tune theo môi trường
  static const int openAITimeoutSeconds = int.fromEnvironment(
    'OPENAI_TIMEOUT_SECONDS',
    defaultValue: 30,
  );

  /// Kiểm tra config hợp lệ
  static bool get isConfigured =>
      openAIKey.isNotEmpty && openAIKey.startsWith('sk-');

  static void assertConfigured() {
    if (!isConfigured) {
      throw const OpenAIConfigurationError(
        'OpenAI API Key chưa được cấu hình. '
        'Chạy app với: flutter run --dart-define=OPENAI_API_KEY=sk-...',
      );
    }
  }
}

/// Exception khi API Key chưa cấu hình
class OpenAIConfigurationError implements Exception {
  const OpenAIConfigurationError(this.message);
  final String message;

  @override
  String toString() => 'OpenAIConfigurationError: $message';
}

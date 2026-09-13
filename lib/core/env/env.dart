/// Offline beta: never embed a service API key in distributed clients.
/// Remote AI must be reintroduced through an authenticated backend.
class Env {
  Env._();
  static const String openAIKey = '';
  static const String openAIModel = 'gpt-4o-mini';
  static const int openAITimeoutSeconds = 30;
  static bool get isConfigured => false;

  static void assertConfigured() {
    throw const OpenAIConfigurationError(
      'Remote AI is disabled in the offline beta.',
    );
  }
}

class OpenAIConfigurationError implements Exception {
  const OpenAIConfigurationError(this.message);
  final String message;
  @override
  String toString() => 'OpenAIConfigurationError: $message';
}

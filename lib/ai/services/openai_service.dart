/// lib/ai/services/openai_service.dart
/// 
/// Service giao tiếp với OpenAI Chat Completions API.
/// 
/// Trách nhiệm:
///   - Gửi HTTP request đến OpenAI
///   - Handle timeout, network error, rate limit
///   - Trả về raw JSON string để Engine parse
///   - KHÔNG parse business logic — đó là việc của Engine
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/env/env.dart';
import '../../data/models/lesson.dart';
import '../prompts/interview_system_prompt.dart';

// ─────────────────────────────────────────────
// EXCEPTIONS
// ─────────────────────────────────────────────

/// Base class cho mọi OpenAI error
sealed class OpenAIException implements Exception {
  const OpenAIException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Lỗi cấu hình (API Key trống)
class OpenAIConfigError extends OpenAIException {
  const OpenAIConfigError(super.message);
}

/// Timeout — mạng chậm hoặc OpenAI overloaded
class OpenAITimeoutError extends OpenAIException {
  const OpenAITimeoutError()
      : super('Request timed out. Please check your connection.');
}

/// Lỗi mạng — offline hoặc DNS
class OpenAINetworkError extends OpenAIException {
  const OpenAINetworkError(String detail)
      : super('Network error: $detail');
}

/// HTTP error (401, 429, 500, etc.)
class OpenAIHttpError extends OpenAIException {
  const OpenAIHttpError({
    required this.statusCode,
    required String detail,
  }) : super('HTTP $statusCode: $detail');

  final int statusCode;

  bool get isRateLimit => statusCode == 429;
  bool get isUnauthorized => statusCode == 401;
  bool get isServerError => statusCode >= 500;
  bool get isQuotaExceeded => statusCode == 402;
}

/// Response không đúng format JSON
class OpenAIParseError extends OpenAIException {
  const OpenAIParseError(String detail)
      : super('Failed to parse response: $detail');
}

// ─────────────────────────────────────────────
// SERVICE
// ─────────────────────────────────────────────

class OpenAIService {
  OpenAIService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _endpoint =
      'https://api.openai.com/v1/chat/completions';

  /// Phân tích báo cáo trình pháp
  /// 
  /// Returns: Raw JSON string từ GPT
  /// Throws: OpenAIException subclasses
  Future<String> analyzeReport({
    required String userTranscript,
    required Lesson currentLesson,
  }) async {
    // Guard: API Key
    if (!Env.isConfigured) {
      throw const OpenAIConfigError(
        'OpenAI API Key chưa được cấu hình. '
        'Xem lib/core/env/env.dart để biết cách thiết lập.',
      );
    }

    final systemPrompt = InterviewSystemPrompt.build(
      currentLesson: currentLesson,
    );

    final requestBody = _buildRequestBody(
      systemPrompt: systemPrompt,
      userMessage: userTranscript,
    );

    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: _buildHeaders(),
            body: jsonEncode(requestBody),
          )
          .timeout(
            Duration(seconds: Env.openAITimeoutSeconds),
            onTimeout: () => throw const OpenAITimeoutError(),
          );

      return _handleResponse(response);
    } on OpenAIException {
      // Re-throw các exception của chúng ta
      rethrow;
    } on SocketException catch (e) {
      throw OpenAINetworkError(e.message);
    } on TimeoutException {
      throw const OpenAITimeoutError();
    } catch (e) {
      throw OpenAINetworkError(e.toString());
    }
  }

  // ─── Private helpers ────────────────────────

  Map<String, String> _buildHeaders() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Env.openAIKey}',
      };

  Map<String, dynamic> _buildRequestBody({
    required String systemPrompt,
    required String userMessage,
  }) =>
      {
        'model': Env.openAIModel,
        'messages': [
          {
            'role': 'system',
            'content': systemPrompt,
          },
          {
            'role': 'user',
            'content': userMessage,
          },
        ],
        // JSON mode — đảm bảo GPT trả về JSON thuần
        'response_format': {'type': 'json_object'},
        // Temperature thấp → ổn định, ít sáng tạo
        'temperature': 0.3,
        // Giới hạn token để kiểm soát chi phí
        'max_tokens': 1500,
      };

  String _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return _extractContent(response.body);
    }

    // Parse error body nếu có
    final errorDetail = _extractErrorMessage(response.body);

    throw OpenAIHttpError(
      statusCode: response.statusCode,
      detail: errorDetail,
    );
  }

  String _extractContent(String responseBody) {
    try {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final choices = json['choices'] as List<dynamic>?;

      if (choices == null || choices.isEmpty) {
        throw const OpenAIParseError('No choices in response');
      }

      final message =
          choices[0]['message'] as Map<String, dynamic>?;

      if (message == null) {
        throw const OpenAIParseError('No message in choice');
      }

      final content = message['content'] as String?;

      if (content == null || content.trim().isEmpty) {
        throw const OpenAIParseError('Empty content in message');
      }

      return content.trim();
    } on OpenAIException {
      rethrow;
    } catch (e) {
      throw OpenAIParseError('Malformed response structure: $e');
    }
  }

  String _extractErrorMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      return error?['message'] as String? ?? 'Unknown error';
    } catch (_) {
      return body.length > 200 ? '${body.substring(0, 200)}...' : body;
    }
  }
}

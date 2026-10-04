// lib/data/services/speech_service.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Kết quả của một lần đọc bằng giọng tổng hợp.
///
/// Không bao giờ throw qua ranh giới widget — luôn trả về enum để UI
/// hiển thị thông báo phù hợp.
enum SpeechResult {
  /// Đã đọc xong (hoặc đã bắt đầu đọc thành công).
  success,

  /// Người dùng/bộ máy yêu cầu dừng giữa chừng.
  stopped,

  /// Thiết bị không có engine TTS hoặc không hỗ trợ ngôn ngữ yêu cầu.
  unsupported,

  /// Chế độ im lặng của app đang bật.
  silentMode,

  /// Văn bản rỗng — không có gì để đọc.
  emptyText,

  /// Lỗi khác.
  error,
}

/// Giao diện tổng hợp giọng nói (text-to-speech).
///
/// Mục đích của abstraction này: **thay engine mà không sửa call-site.**
///
/// - Hiện tại: [FlutterTtsSynthesizer] dùng engine TTS của hệ điều hành
///   (Google TTS trên Android). Chạy offline nếu người dùng đã tải gói giọng.
/// - Dự kiến: engine offline đóng gói kèm app (ví dụ Sherpa-onnx) cho các
///   ngôn ngữ mà TTS hệ thống không hỗ trợ tốt. Chỉ cần implement interface
///   này và đổi [SpeechService.instance].
///
/// Quy ước ưu tiên nguồn âm thanh trong app:
///   1. Bản thu thật (`audio_url` trong lesson JSON) — luôn ưu tiên.
///   2. Giọng tổng hợp (implementation của interface này) — dùng tạm.
///   3. Không có gì → UI hướng dẫn người học đọc văn bản.
abstract class SpeechSynthesizer {
  /// Đọc [text]. Hoàn tất khi engine đọc xong (hoặc bị dừng).
  Future<SpeechResult> speak(
    String text, {
    String language,
    double rate,
    double pitch,
  });

  /// Dừng ngay lập tức.
  Future<void> stop();

  /// Engine có đang phát không.
  bool get isSpeaking;

  /// Phát ra `true` khi bắt đầu đọc, `false` khi dừng/đọc xong.
  Stream<bool> get speakingStream;

  /// Giải phóng tài nguyên.
  Future<void> dispose();
}

/// Điểm truy cập duy nhất tới engine TTS đang dùng.
///
/// Đổi engine (ví dụ sang Sherpa-onnx) chỉ cần gọi [overrideWith] lúc khởi
/// động app hoặc trong test — không file UI nào import implementation cụ thể.
class SpeechService {
  SpeechService._();

  static SpeechSynthesizer? _instance;

  static SpeechSynthesizer get instance {
    _instance ??= FlutterTtsSynthesizer();
    return _instance!;
  }

  /// Inject engine khác (test, hoặc engine offline đóng gói sau này).
  static void overrideWith(SpeechSynthesizer synthesizer) {
    _instance = synthesizer;
  }

  static void reset() {
    _instance = null;
  }
}

/// Engine TTS của hệ điều hành thông qua package `flutter_tts`.
class FlutterTtsSynthesizer implements SpeechSynthesizer {
  FlutterTtsSynthesizer({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  final StreamController<bool> _speakingController =
      StreamController<bool>.broadcast();

  bool _initialized = false;
  bool _isSpeaking = false;
  String? _currentLanguage;
  Completer<SpeechResult>? _completer;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Stream<bool> get speakingStream => _speakingController.stream;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    // Chờ engine đọc xong rồi mới trả về từ speak().
    await _tts.awaitSpeakCompletion(true);

    _tts.setStartHandler(() => _emit(true));
    _tts.setCompletionHandler(() {
      _emit(false);
      _complete(SpeechResult.success);
    });
    _tts.setCancelHandler(() {
      _emit(false);
      _complete(SpeechResult.stopped);
    });
    _tts.setErrorHandler((dynamic message) {
      debugPrint('❌ FlutterTtsSynthesizer error: $message');
      _emit(false);
      _complete(SpeechResult.error);
    });

    _initialized = true;
  }

  void _emit(bool speaking) {
    _isSpeaking = speaking;
    if (!_speakingController.isClosed) {
      _speakingController.add(speaking);
    }
  }

  void _complete(SpeechResult result) {
    final completer = _completer;
    _completer = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
  }

  @override
  Future<SpeechResult> speak(
    String text, {
    String language = 'en-US',
    double rate = 0.45,
    double pitch = 1.0,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return SpeechResult.emptyText;

    try {
      await _ensureInitialized();

      // Đang đọc → dừng trước, tránh chồng tiếng.
      if (_isSpeaking) {
        await stop();
      }

      if (_currentLanguage != language) {
        final available = await _isLanguageAvailable(language);
        if (!available) {
          debugPrint('⚠️ TTS: ngôn ngữ $language không khả dụng trên thiết bị');
          return SpeechResult.unsupported;
        }
        await _tts.setLanguage(language);
        _currentLanguage = language;
      }

      await _tts.setSpeechRate(rate);
      await _tts.setPitch(pitch);

      _completer = Completer<SpeechResult>();
      final code = await _tts.speak(trimmed);

      // flutter_tts trả 1 khi queue thành công; 0 là lỗi.
      if (code == 0) {
        _complete(SpeechResult.error);
        return SpeechResult.error;
      }

      // awaitSpeakCompletion(true) → speak() đã chờ xong; nếu handler chưa
      // kịp bắn thì coi như thành công.
      final pending = _completer;
      if (pending == null || pending.isCompleted) {
        return SpeechResult.success;
      }
      _complete(SpeechResult.success);
      return SpeechResult.success;
    } catch (e) {
      debugPrint('❌ FlutterTtsSynthesizer.speak exception: $e');
      _emit(false);
      _complete(SpeechResult.error);
      return SpeechResult.error;
    }
  }

  Future<bool> _isLanguageAvailable(String language) async {
    try {
      final result = await _tts.isLanguageAvailable(language);
      // Android trả bool; một số nền tảng trả int/null.
      if (result is bool) return result;
      if (result is int) return result > 0;
      return true;
    } catch (_) {
      // Không xác định được → cứ thử đọc, lỗi sẽ được bắt ở speak().
      return true;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('⚠️ FlutterTtsSynthesizer.stop: $e');
    }
    _emit(false);
    _complete(SpeechResult.stopped);
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _speakingController.close();
  }
}

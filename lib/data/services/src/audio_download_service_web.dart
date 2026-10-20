// lib/data/services/src/audio_download_service_web.dart
//
// Web stub — trình duyệt không có file system để lưu audio.
// Toàn bộ audio được stream trực tiếp từ Hugging Face qua just_audio;
// service này chỉ tồn tại để code compile và UI không crash.

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../constants/audio_catalog.dart';
import 'audio_download_models.dart';

/// Stub cho web: không tải, không lưu, nhưng giữ API đồng bộ với bản IO
/// để các provider / màn hình không cần fork theo platform.
class AudioDownloadService {
  AudioDownloadService._internal();

  static AudioDownloadService instance = AudioDownloadService._internal();

  /// Web không hỗ trợ file IO — luôn rỗng.
  Map<String, DownloadedAudioInfo> get index => const {};

  int get downloadedBytes => 0;

  bool isDownloaded(String fileName) => false;

  bool isLessonFullyDownloaded(String lessonId) => false;

  String? localPath(String fileName) => null;

  List<DownloadedAudioInfo> downloadedFilesForLesson(String lessonId) =>
      const [];

  bool isDownloadingLesson(String lessonId) => false;

  void requestCancel() {
    // No-op trên web — không có lượt tải nào đang chạy.
  }

  Future<void> ensureLoaded() async {
    // Trên web không có thư mục để đọc — giữ index rỗng.
    debugPrint('ℹ️ AudioDownloadService (web): ensureLoaded = no-op');
  }

  /// Web không lưu file — trả về notFound để UI hiểu không có local.
  /// Luồng Input của web sẽ stream từ remoteUrl (just_audio setUrl).
  Future<DownloadOutcome> downloadFile(
    RemoteAudioFile file, {
    AudioProgressCallback? onProgress,
  }) async {
    debugPrint('ℹ️ AudioDownloadService (web): downloadFile không hỗ trợ — dùng stream thay thế');
    return DownloadOutcome.notFound;
  }

  Future<DownloadOutcome> downloadLesson(
    String lessonId, {
    AudioProgressCallback? onProgress,
  }) async {
    debugPrint('ℹ️ AudioDownloadService (web): downloadLesson không hỗ trợ trên web');
    return DownloadOutcome.notFound;
  }

  Future<void> deleteFile(String fileName) async {
    // no-op
  }

  Future<void> deleteLesson(String lessonId) async {
    // no-op
  }

  Future<void> deleteAll() async {
    // no-op
  }

  // ─── Test hooks (để test không phân biệt platform) ───────────────────────
  @visibleForTesting
  // ignore: avoid_setters_without_getters
  set debugHttpClient(http.Client? _) {}

  @visibleForTesting
  // ignore: avoid_setters_without_getters
  set debugDirectoryProvider(dynamic _) {}
}

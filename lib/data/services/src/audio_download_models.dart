// lib/data/services/src/audio_download_models.dart
//
// Pure models + helpers for audio download — 100% web-compatible,
// không phụ thuộc dart:io hay path_provider.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kết quả của một lượt tải — UI dựa vào đây để chọn thông báo.
enum DownloadOutcome {
  /// Tải xong, file đã nằm trong thư mục local và ghi vào index.
  success,

  /// Người dùng bấm huỷ giữa chừng; file tạm đã được dọn.
  cancelled,

  /// File không tồn tại trên máy chủ (404) — nội dung chưa được upload.
  notFound,

  /// Không có kết nối mạng, hết thời gian chờ hoặc lỗi đường truyền.
  networkError,

  /// Không ghi/đọc được bộ nhớ thiết bị (hết dung lượng, quyền…).
  storageError,
}

/// Thông tin một file đã tải về máy.
class DownloadedAudioInfo {
  const DownloadedAudioInfo({
    required this.fileName,
    required this.lessonId,
    required this.bytes,
    required this.downloadedAtMillis,
  });

  final String fileName;
  final String lessonId;
  final int bytes;
  final int downloadedAtMillis;

  Map<String, dynamic> toJson() => {
        'file_name': fileName,
        'lesson_id': lessonId,
        'bytes': bytes,
        'downloaded_at': downloadedAtMillis,
      };

  static DownloadedAudioInfo? fromJson(Map<String, dynamic> json) {
    final fileName = json['file_name'];
    final lessonId = json['lesson_id'];
    if (fileName is! String || lessonId is! String) return null;
    return DownloadedAudioInfo(
      fileName: fileName,
      lessonId: lessonId,
      bytes: json['bytes'] is int ? json['bytes'] as int : 0,
      downloadedAtMillis:
          json['downloaded_at'] is int ? json['downloaded_at'] as int : 0,
    );
  }
}

/// Encode index thành JSON — hàm thuần, kiểm thử được không cần thiết bị.
String encodeAudioIndex(Map<String, DownloadedAudioInfo> index) {
  return jsonEncode({
    'version': 1,
    'files': {
      for (final entry in index.entries) entry.key: entry.value.toJson(),
    },
  });
}

/// Parse index từ JSON — dữ liệu hỏng được bỏ qua thay vì làm crash app.
Map<String, DownloadedAudioInfo> parseAudioIndex(String? raw) {
  if (raw == null || raw.trim().isEmpty) return {};
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return {};
    final files = decoded['files'];
    if (files is! Map<String, dynamic>) return {};
    final result = <String, DownloadedAudioInfo>{};
    for (final entry in files.entries) {
      final value = entry.value;
      if (value is! Map<String, dynamic>) continue;
      final info = DownloadedAudioInfo.fromJson(value);
      if (info != null) result[entry.key] = info;
    }
    return result;
  } catch (e) {
    debugPrint('⚠️ AudioDownloadService: index hỏng, bỏ qua: $e');
    return {};
  }
}

typedef AudioProgressCallback = void Function(
  int receivedBytes,
  int totalBytes,
);

/// Ghi nhớ lựa chọn "Tải sau" cho từng bài để không hỏi lại lần nữa.
///
/// Chỉ lưu khi người học **chủ động** bấm "Tải sau"; lần sau mở bài chỉ còn
/// nút "Tải audio" gọn, không banner mời.
class AudioPromptStore {
  AudioPromptStore._internal();

  static AudioPromptStore instance = AudioPromptStore._internal();

  static const String _key = 'audio_download_prompt_dismissed_v1';

  Set<String>? _dismissed;

  Future<Set<String>> _load() async {
    if (_dismissed != null) return _dismissed!;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? const <String>[];
      _dismissed = raw.toSet();
    } catch (e) {
      debugPrint('⚠️ AudioPromptStore: không đọc được prefs: $e');
      _dismissed = {};
    }
    return _dismissed!;
  }

  Future<bool> isDismissed(String lessonId) async =>
      (await _load()).contains(lessonId);

  Future<void> markDismissed(String lessonId) async {
    final set = await _load();
    if (set.add(lessonId)) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_key, set.toList());
      } catch (e) {
        debugPrint('⚠️ AudioPromptStore: không ghi được prefs: $e');
      }
    }
  }
}

// lib/data/services/audio_download_service.dart
//
// Tải audio bài học từ Hugging Face về bộ nhớ app và quản lý danh mục file
// đã tải. Nguyên tắc thiết kế:
//
//   * Không bao giờ ném lỗi xuyên qua UI — mọi kết quả trả về bằng enum
//     [DownloadOutcome] để màn hình chọn thông báo phù hợp.
//   * File được ghi dạng `.part` rồi đổi tên khi tải xong, nên app tắt giữa
//     chừng cũng không bao giờ để lại file "nửa vời" được coi là đã tải.
//   * Chỉ mục (index) nằm trong chính thư mục audio để xoá thư mục là xoá
//     sạch cả dữ liệu theo dõi.
//
// Lớp này cố tình KHÔNG phụ thuộc Riverpod/UI để giữ phần thuần (encode/parse
// index) kiểm thử được bằng `flutter test`.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/audio_catalog.dart';

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

/// Singleton quản lý tải/lưu/xoá audio bài học.
class AudioDownloadService {
  AudioDownloadService._internal();

  static AudioDownloadService instance = AudioDownloadService._internal();

  static const String _audioDirName = 'zenglish_audio';
  static const String _indexFileName = 'audio_index.json';

  /// Điểm gán dependency cho test (không đụng SharedPreferences/path_provider).
  @visibleForTesting
  http.Client? debugHttpClient;

  @visibleForTesting
  Future<Directory> Function()? debugDirectoryProvider;

  final http.Client _fallbackClient = http.Client();
  Map<String, DownloadedAudioInfo>? _index;
  bool _loadFailed = false;
  bool _cancelRequested = false;
  final Set<String> _activeDownloads = {};

  // ─── Trạng thái công khai (đồng bộ, gọi sau [ensureLoaded]) ───────────────

  /// Chỉ mục file đã tải (bản sao đọc được).
  Map<String, DownloadedAudioInfo> get index =>
      Map.unmodifiable(_index ?? const {});

  bool isDownloaded(String fileName) {
    if (_index == null || !_index!.containsKey(fileName)) return false;
    // File có thể bị xoá ngoài app — kiểm tra thật rồi mới coi là đã tải.
    final path = localPath(fileName);
    if (path == null || !File(path).existsSync()) {
      _index!.remove(fileName);
      unawaited(_saveIndex());
      return false;
    }
    return true;
  }

  /// Đường dẫn local dự kiến của một file; `null` trước khi [ensureLoaded].
  String? localPath(String fileName) {
    final dir = _lastDir;
    return dir == null ? null : '${dir.path}/$fileName';
  }

  Directory? _lastDir;

  List<DownloadedAudioInfo> downloadedFilesForLesson(String lessonId) =>
      (_index ?? const <String, DownloadedAudioInfo>{})
          .values
          .where((info) => info.lessonId == lessonId)
          .toList(growable: false);

  int get downloadedBytes =>
      (_index ?? const <String, DownloadedAudioInfo>{})
          .values
          .fold(0, (sum, info) => sum + info.bytes);

  bool isDownloadingLesson(String lessonId) => _activeDownloads.any(
        (fileName) =>
            AudioCatalog.filesForLesson(lessonId)
                .any((f) => f.fileName == fileName),
      );

  // ─── Yêu cầu huỷ ────────────────────────────────────────────────────────────

  void requestCancel() => _cancelRequested = true;

  // ─── Khởi động / index ──────────────────────────────────────────────────────

  Future<Directory> _audioDir() async {
    final base = debugDirectoryProvider != null
        ? await debugDirectoryProvider!()
        : await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_audioDirName');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    _lastDir = dir;
    return dir;
  }

  /// Đọc index từ đĩa. An toàn khi gọi nhiều lần.
  Future<void> ensureLoaded() async {
    if (_index != null || _loadFailed) return;
    try {
      final dir = await _audioDir();
      final file = File('${dir.path}/$_indexFileName');
      _index = parseAudioIndex(
        file.existsSync() ? file.readAsStringSync() : null,
      );
      // Dọn các entry mà file đã biến mất (xoá tay, clear cache…).
      final missing = _index!.keys
          .where((name) => !File('${dir.path}/$name').existsSync())
          .toList();
      for (final name in missing) {
        _index!.remove(name);
      }
      if (missing.isNotEmpty) await _saveIndex();
    } catch (e) {
      debugPrint('⚠️ AudioDownloadService: không đọc được index: $e');
      _index = {};
      _loadFailed = true;
    }
  }

  Future<void> _saveIndex() async {
    try {
      final dir = await _audioDir();
      final file = File('${dir.path}/$_indexFileName');
      file.writeAsStringSync(encodeAudioIndex(_index ?? {}));
    } catch (e) {
      debugPrint('⚠️ AudioDownloadService: không ghi được index: $e');
    }
  }

  // ─── Tải ────────────────────────────────────────────────────────────────────

  http.Client get _client => debugHttpClient ?? _fallbackClient;

  /// Tải MỘT file. Không bao giờ ném lỗi.
  ///
  /// Cờ huỷ do điểm vào công khai ([downloadLesson]) reset — để lượt huỷ giữa
  /// bài nhiều file không bị "quên" khi chuyển sang file kế tiếp.
  Future<DownloadOutcome> downloadFile(
    RemoteAudioFile file, {
    AudioProgressCallback? onProgress,
  }) async {
    _activeDownloads.add(file.fileName);
    File? tempFile;
    try {
      final uri = Uri.parse(file.remoteUrl);

      // HEAD trước để lấy dung lượng thật (progress chính xác hơn ước tính).
      var totalBytes = file.estimatedBytes;
      try {
        final head = await _client.head(uri);
        if (head.statusCode == 404) return DownloadOutcome.notFound;
        if (head.statusCode == 200 && head.contentLength > 0) {
          totalBytes = head.contentLength;
        }
      } catch (_) {
        // Server có thể từ chối HEAD — vẫn thử GET, lỗi mạng thật sẽ lộ ở đó.
      }

      final request = http.Request('GET', uri);
      final response = await _client.send(request);

      if (response.statusCode == 404) {
        await response.stream.drain();
        return DownloadOutcome.notFound;
      }
      if (response.statusCode != 200) {
        await response.stream.drain();
        return DownloadOutcome.networkError;
      }
      if (response.contentLength > 0) {
        totalBytes = response.contentLength;
      }

      final dir = await _audioDir();
      tempFile = File('${dir.path}/${file.fileName}.part');
      if (tempFile.existsSync()) tempFile.deleteSync();

      final sink = tempFile.openWrite(mode: FileMode.write);
      var received = 0;
      var cancelled = false;
      try {
        await for (final chunk in response.stream) {
          if (_cancelRequested) {
            cancelled = true;
            break;
          }
          sink.add(chunk);
          received += chunk.length;
          onProgress?.call(received, totalBytes);
        }
        await sink.flush();
      } finally {
        await sink.close();
      }

      if (cancelled) {
        if (tempFile.existsSync()) tempFile.deleteSync();
        return DownloadOutcome.cancelled;
      }
      if (received == 0) {
        if (tempFile.existsSync()) tempFile.deleteSync();
        return DownloadOutcome.networkError;
      }

      final destination = File('${dir.path}/${file.fileName}');
      if (destination.existsSync()) destination.deleteSync();
      tempFile.renameSync(destination.path);

      _index ??= {};
      _index![file.fileName] = DownloadedAudioInfo(
        fileName: file.fileName,
        lessonId: file.lessonId,
        bytes: received,
        downloadedAtMillis: DateTime.now().millisecondsSinceEpoch,
      );
      await _saveIndex();
      return DownloadOutcome.success;
    } on SocketException catch (e) {
      debugPrint('❌ AudioDownloadService [SocketException]: $e');
      return DownloadOutcome.networkError;
    } on http.ClientException catch (e) {
      debugPrint('❌ AudioDownloadService [ClientException]: $e');
      return DownloadOutcome.networkError;
    } on TimeoutException catch (e) {
      debugPrint('❌ AudioDownloadService [Timeout]: $e');
      return DownloadOutcome.networkError;
    } on FileSystemException catch (e) {
      debugPrint('❌ AudioDownloadService [FileSystemException]: $e');
      return DownloadOutcome.storageError;
    } catch (e) {
      debugPrint('❌ AudioDownloadService [unknown]: $e');
      return DownloadOutcome.networkError;
    } finally {
      _activeDownloads.remove(file.fileName);
      if (tempFile != null && tempFile.existsSync()) {
        try {
          tempFile.deleteSync();
        } catch (_) {
          // Đã đổi tên thành công hoặc file đã được dọn — bỏ qua.
        }
      }
    }
  }

  /// Tải toàn bộ audio của một bài học (hiện tại mỗi bài 1 file).
  Future<DownloadOutcome> downloadLesson(
    String lessonId, {
    AudioProgressCallback? onProgress,
  }) async {
    await ensureLoaded();
    _cancelRequested = false;
    final files = AudioCatalog.filesForLesson(lessonId);
    if (files.isEmpty) return DownloadOutcome.notFound;

    var completedBytes = 0;
    final totalEstimated =
        files.fold<int>(0, (sum, f) => sum + f.estimatedBytes);

    for (final file in files) {
      if (isDownloaded(file.fileName)) {
        completedBytes += _index![file.fileName]!.bytes;
        onProgress?.call(completedBytes, totalEstimated);
        continue;
      }
      final outcome = await downloadFile(
        file,
        onProgress: (received, total) {
          onProgress?.call(completedBytes + received, completedBytes + total);
        },
      );
      if (outcome != DownloadOutcome.success) return outcome;
      completedBytes += _index![file.fileName]?.bytes ?? 0;
    }
    return DownloadOutcome.success;
  }

  // ─── Xoá ────────────────────────────────────────────────────────────────────

  Future<void> deleteFile(String fileName) async {
    try {
      final dir = await _audioDir();
      final file = File('${dir.path}/$fileName');
      if (file.existsSync()) file.deleteSync();
    } catch (e) {
      debugPrint('⚠️ AudioDownloadService: xoá file lỗi: $e');
    }
    _index?.remove(fileName);
    await _saveIndex();
  }

  Future<void> deleteLesson(String lessonId) async {
    final infos = downloadedFilesForLesson(lessonId);
    for (final info in infos) {
      await deleteFile(info.fileName);
    }
  }

  Future<void> deleteAll() async {
    final names = (_index ?? {}).keys.toList();
    for (final name in names) {
      await deleteFile(name);
    }
  }
}

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

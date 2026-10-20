// lib/data/services/src/audio_download_service_io.dart
//
// IO implementation — chỉ dùng trên Android/iOS/desktop.
// File này IMPORT dart:io, nên không bao giờ được compile trên web.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../constants/audio_catalog.dart';
import 'audio_download_models.dart';

/// Singleton quản lý tải/lưu/xoá audio bài học (bản IO).
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

  /// True nếu bài học đã có đủ file local (để UI quyết định hiện nút tải).
  bool isLessonFullyDownloaded(String lessonId) {
    final files = AudioCatalog.filesForLesson(lessonId);
    if (files.isEmpty) return false;
    return files.every((f) => isDownloaded(f.fileName));
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

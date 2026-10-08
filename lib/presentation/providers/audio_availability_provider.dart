// lib/presentation/providers/audio_availability_provider.dart
//
// Trả lời câu hỏi: "Với bài học này, audio nào đang CÓ SẴN trên máy?"
//
// Kết quả ([LocalAudioLookup]) được nạp vào `resolveInputAudio()` để quyết
// định phát từ asset/file local hay stream từ Hugging Face. Provider dùng
// `revision` làm family key: mỗi lần tải/xoá audio xong,
// `audioDownloadProvider` tăng revision → lookup được tính lại → UI chuyển
// sang phát local ngay, không hỏi lại người học.

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/constants/audio_catalog.dart';
import '../../data/services/audio_download_service.dart';
import '../../data/services/input_audio_resolver.dart';

Map<String, String>? _bundledCache;

/// Kiểm tra file nào trong [AudioCatalog] đã được bundle kèm app khi build
/// (đặt trong `assets/audio/`). Cache một lần — bundle không đổi lúc runtime.
Future<Map<String, String>> probeBundledAudio() async {
  if (_bundledCache != null) return _bundledCache!;
  final result = <String, String>{};
  for (final file in AudioCatalog.files) {
    try {
      await rootBundle.load(file.bundledAssetPath);
      result[file.fileName] = file.bundledAssetPath;
    } catch (_) {
      // Không có trong bundle — bỏ qua, không phải lỗi.
    }
  }
  _bundledCache = result;
  return result;
}

/// Chỉ mục file đã tải (bản snapshot theo revision).
final audioIndexProvider = FutureProvider.autoDispose
    .family<Map<String, DownloadedAudioInfo>, int>(
  (ref, revision) async {
    final service = AudioDownloadService.instance;
    await service.ensureLoaded();
    return service.index;
  },
);

/// Lookup local (bundle + đã tải) cho `resolveInputAudio()`.
final audioAvailabilityProvider = FutureProvider.autoDispose
    .family<LocalAudioLookup, int>(
  (ref, revision) async {
    final index = await ref.watch(audioIndexProvider(revision).future);
    final service = AudioDownloadService.instance;

    final downloaded = <String, String>{};
    for (final info in index.values) {
      final path = service.localPath(info.fileName);
      if (path != null && service.isDownloaded(info.fileName)) {
        downloaded[info.fileName] = path;
      }
    }

    final bundled = await probeBundledAudio();
    return LocalAudioLookup(bundled: bundled, downloaded: downloaded);
  },
);

/// Tổng dung lượng ước tính đã tải về máy (cho màn hình Quản lý audio).
int downloadedBytesOf(Map<String, DownloadedAudioInfo> index) =>
    index.values.fold(0, (sum, info) => sum + info.bytes);

/// Định dạng byte thành chuỗi MB dễ đọc theo kiểu Việt Nam ("1,5 MB").
String formatMb(int bytes) {
  final mb = bytes / (1024 * 1024);
  return '${mb.toStringAsFixed(1).replaceAll('.', ',')} MB';
}

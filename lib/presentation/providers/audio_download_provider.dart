// lib/presentation/providers/audio_download_provider.dart
//
// Điều phối việc tải audio: bài đơn, theo chương hoặc toàn bộ — kèm tiến
// trình, huỷ, lỗi và thông báo kết quả. UI chỉ đọc state ở đây, không gọi
// thẳng service.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/constants/audio_catalog.dart';
import '../../data/services/audio_download_service.dart';

class AudioDownloadState {
  const AudioDownloadState({
    this.activeLessonId,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.batchDone = 0,
    this.batchTotal = 0,
    this.errorLessonId,
    this.errorMessage,
    this.lastSuccessLessonId,
    this.revision = 0,
  });

  /// Bài đang tải (null nếu không có lượt tải nào chạy).
  final String? activeLessonId;
  final int receivedBytes;
  final int totalBytes;

  /// Tiến trình tải theo lô (chương / toàn bộ).
  final int batchDone;
  final int batchTotal;

  /// Lỗi của lượt tải gần nhất (null nếu không có lỗi).
  final String? errorLessonId;
  final String? errorMessage;

  /// Bài vừa tải thành công — UI dùng để hiện snackbar chúc mừng.
  final String? lastSuccessLessonId;

  /// Tăng mỗi lần index local thay đổi → availability lookup tính lại.
  final int revision;

  bool get isBusy => activeLessonId != null;

  double get progress {
    if (totalBytes <= 0) return 0;
    final value = receivedBytes / totalBytes;
    return value.clamp(0.0, 1.0);
  }

  AudioDownloadState copyWith({
    String? activeLessonId,
    bool clearActive = false,
    int? receivedBytes,
    int? totalBytes,
    int? batchDone,
    int? batchTotal,
    String? errorLessonId,
    String? errorMessage,
    bool clearError = false,
    String? lastSuccessLessonId,
    bool clearLastSuccess = false,
    int? revision,
  }) {
    return AudioDownloadState(
      activeLessonId:
          clearActive ? null : (activeLessonId ?? this.activeLessonId),
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      batchDone: batchDone ?? this.batchDone,
      batchTotal: batchTotal ?? this.batchTotal,
      errorLessonId:
          clearError ? null : (errorLessonId ?? this.errorLessonId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastSuccessLessonId: clearLastSuccess
          ? null
          : (lastSuccessLessonId ?? this.lastSuccessLessonId),
      revision: revision ?? this.revision,
    );
  }
}

class AudioDownloadNotifier extends StateNotifier<AudioDownloadState> {
  AudioDownloadNotifier() : super(const AudioDownloadState());

  AudioDownloadService get _service => AudioDownloadService.instance;

  // ─── Tải một bài ─────────────────────────────────────────────────────────

  Future<void> downloadLesson(String lessonId) async {
    if (state.isBusy) return;
    if (_service.isLessonFullyDownloaded(lessonId)) return;

    state = state.copyWith(
      activeLessonId: lessonId,
      receivedBytes: 0,
      totalBytes: AudioCatalog.estimatedBytesForLesson(lessonId),
      clearError: true,
      clearLastSuccess: true,
    );

    final outcome = await _service.downloadLesson(
      lessonId,
      onProgress: (received, total) {
        if (!mounted || state.activeLessonId != lessonId) return;
        state = state.copyWith(receivedBytes: received, totalBytes: total);
      },
    );

    _applyOutcome(lessonId, outcome);
  }

  // ─── Tải theo lô (chương / toàn bộ) ──────────────────────────────────────

  Future<void> downloadBatch(List<String> lessonIds) async {
    if (state.isBusy) return;
    final pending = lessonIds
        .where((id) => AudioCatalog.filesForLesson(id).isNotEmpty)
        .where((id) => !_service.isLessonFullyDownloaded(id))
        .toList();
    if (pending.isEmpty) return;

    state = state.copyWith(
      batchDone: 0,
      batchTotal: pending.length,
      clearError: true,
      clearLastSuccess: true,
    );

    for (var i = 0; i < pending.length; i++) {
      final lessonId = pending[i];
      state = state.copyWith(activeLessonId: lessonId, receivedBytes: 0,
          totalBytes: AudioCatalog.estimatedBytesForLesson(lessonId));

      final outcome = await _service.downloadLesson(
        lessonId,
        onProgress: (received, total) {
          if (!mounted || state.activeLessonId != lessonId) return;
          state = state.copyWith(receivedBytes: received, totalBytes: total);
        },
      );

      if (outcome == DownloadOutcome.cancelled) {
        state = state.copyWith(
          clearActive: true,
          batchDone: i,
          revision: state.revision + 1,
        );
        return;
      }
      if (outcome != DownloadOutcome.success) {
        state = state.copyWith(clearActive: true, batchDone: i);
        _applyOutcome(lessonId, outcome, keepBatch: true);
        return;
      }
      state = state.copyWith(batchDone: i + 1);
    }

    state = state.copyWith(
      clearActive: true,
      lastSuccessLessonId: pending.last,
      revision: state.revision + 1,
    );
  }

  // ─── Huỷ / xoá ────────────────────────────────────────────────────────────

  void cancel() {
    _service.requestCancel();
  }

  Future<void> deleteLesson(String lessonId) async {
    await _service.deleteLesson(lessonId);
    state = state.copyWith(
      revision: state.revision + 1,
      clearError: true,
      clearLastSuccess: true,
    );
  }

  Future<void> deleteAll() async {
    await _service.deleteAll();
    state = state.copyWith(
      revision: state.revision + 1,
      clearError: true,
      clearLastSuccess: true,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearLastSuccess() {
    state = state.copyWith(clearLastSuccess: true);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _applyOutcome(
    String lessonId,
    DownloadOutcome outcome, {
    bool keepBatch = false,
  }) {
    switch (outcome) {
      case DownloadOutcome.success:
        state = state.copyWith(
          clearActive: true,
          lastSuccessLessonId: lessonId,
          revision: state.revision + 1,
          batchDone: keepBatch ? state.batchDone : 0,
          batchTotal: keepBatch ? state.batchTotal : 0,
        );
      case DownloadOutcome.cancelled:
        state = state.copyWith(
          clearActive: true,
          revision: state.revision + 1,
          batchDone: keepBatch ? state.batchDone : 0,
          batchTotal: keepBatch ? state.batchTotal : 0,
        );
      case DownloadOutcome.notFound:
        state = state.copyWith(
          clearActive: true,
          errorLessonId: lessonId,
          errorMessage:
              'Chưa có file audio này trên máy chủ. Nội dung sẽ được bổ sung '
              'trong bản cập nhật tới.',
          batchDone: keepBatch ? state.batchDone : 0,
          batchTotal: keepBatch ? state.batchTotal : 0,
        );
      case DownloadOutcome.networkError:
        state = state.copyWith(
          clearActive: true,
          errorLessonId: lessonId,
          errorMessage:
              'Không có kết nối hoặc tải thất bại. Kiểm tra mạng rồi thử lại.',
          batchDone: keepBatch ? state.batchDone : 0,
          batchTotal: keepBatch ? state.batchTotal : 0,
        );
      case DownloadOutcome.storageError:
        state = state.copyWith(
          clearActive: true,
          errorLessonId: lessonId,
          errorMessage:
              'Không lưu được file vào bộ nhớ máy. Hãy kiểm tra dung lượng '
              'trống rồi thử lại.',
          batchDone: keepBatch ? state.batchDone : 0,
          batchTotal: keepBatch ? state.batchTotal : 0,
        );
    }
  }
}

final audioDownloadProvider =
    StateNotifierProvider<AudioDownloadNotifier, AudioDownloadState>(
  (ref) => AudioDownloadNotifier(),
);

/// Extension nhỏ để kiểm tra "đã tải đủ audio của bài chưa" từ index.
extension DownloadedLessonCheck on AudioDownloadService {
  bool isLessonFullyDownloaded(String lessonId) {
    final files = AudioCatalog.filesForLesson(lessonId);
    if (files.isEmpty) return false;
    return files.every((f) => isDownloaded(f.fileName));
  }
}

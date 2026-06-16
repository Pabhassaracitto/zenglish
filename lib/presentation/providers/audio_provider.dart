import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/services/audio_playback_service.dart';
import 'home_provider.dart';

// ─────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────

enum AudioPlaybackState {
  idle,      // Chưa load
  loading,   // Đang load audio
  ready,     // Sẵn sàng phát
  playing,   // Đang phát
  paused,    // Đã tạm dừng
  completed, // Phát xong
  error,     // Lỗi
}

class AudioState {
  const AudioState({
    this.playbackState = AudioPlaybackState.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentSource,
    this.error,
  });

  final AudioPlaybackState playbackState;
  final Duration position;
  final Duration duration;
  final String? currentSource;
  final String? error;

  bool get isPlaying => playbackState == AudioPlaybackState.playing;
  bool get isLoading => playbackState == AudioPlaybackState.loading;
  bool get isPaused => playbackState == AudioPlaybackState.paused;
  bool get hasError => playbackState == AudioPlaybackState.error;
  
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  AudioState copyWith({
    AudioPlaybackState? playbackState,
    Duration? position,
    Duration? duration,
    String? currentSource,
    String? error,
    bool clearError = false,
  }) {
    return AudioState(
      playbackState: playbackState ?? this.playbackState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentSource: currentSource ?? this.currentSource,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────

class AudioNotifier extends StateNotifier<AudioState> {
  AudioNotifier(this._ref) : super(const AudioState()) {
    _init();
  }

  final Ref _ref;
  final _service = AudioPlaybackService.instance;

  void _init() {
    // Lắng nghe trạng thái player
    _service.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.loading) {
        state = state.copyWith(
          playbackState: AudioPlaybackState.loading,
          clearError: true,
        );
      } else if (playerState.processingState == ProcessingState.ready) {
        if (playerState.playing) {
          state = state.copyWith(
            playbackState: AudioPlaybackState.playing,
          );
        } else {
          state = state.copyWith(
            playbackState: AudioPlaybackState.paused,
          );
        }
      } else if (playerState.processingState == ProcessingState.completed) {
        state = state.copyWith(
          playbackState: AudioPlaybackState.completed,
          position: state.duration,
        );
      }
    });

    // Lắng nghe vị trí phát
    _service.positionStream.listen((position) {
      if (position != null) {
        state = state.copyWith(position: position);
      }
    });

    // Lắng nghe độ dài audio
    _service.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });
  }

  // ─── Play Methods ────────────────────────────

  Future<void> play(String source) async {
    // Kiểm tra Silent Mode
    final isSilentMode = _ref.read(
      homeProvider.select((s) => s.silentMode),
    );

    if (isSilentMode) {
      state = state.copyWith(
        playbackState: AudioPlaybackState.error,
        error: 'SILENT_MODE',
      );
      return;
    }

    try {
      state = state.copyWith(
        playbackState: AudioPlaybackState.loading,
        currentSource: source,
        clearError: true,
      );

      await _service.play(source);
    } catch (e) {
      state = state.copyWith(
        playbackState: AudioPlaybackState.error,
        error: e.toString(),
      );
    }
  }

  Future<void> togglePlayPause() async {
    // Kiểm tra Silent Mode
    final isSilentMode = _ref.read(
      homeProvider.select((s) => s.silentMode),
    );

    if (isSilentMode && !_service.isPlaying) {
      state = state.copyWith(
        playbackState: AudioPlaybackState.error,
        error: 'SILENT_MODE',
      );
      return;
    }

    try {
      await _service.togglePlayPause();
    } catch (e) {
      state = state.copyWith(
        playbackState: AudioPlaybackState.error,
        error: e.toString(),
      );
    }
  }

  Future<void> pause() async {
    try {
      await _service.pause();
    } catch (e) {
      state = state.copyWith(
        playbackState: AudioPlaybackState.error,
        error: e.toString(),
      );
    }
  }

  Future<void> stop() async {
    try {
      await _service.stop();
      state = const AudioState(); // Reset về idle
    } catch (e) {
      state = state.copyWith(
        playbackState: AudioPlaybackState.error,
        error: e.toString(),
      );
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _service.seek(position);
      state = state.copyWith(position: position);
    } catch (e) {
      state = state.copyWith(
        playbackState: AudioPlaybackState.error,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    // Note: Không dispose AudioPlaybackService ở đây vì nó là singleton
    // Chỉ dispose khi app tắt hoàn toàn
    super.dispose();
  }
}

// ─────────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────────

final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>(
  (ref) => AudioNotifier(ref),
);

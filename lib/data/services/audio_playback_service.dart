// lib/data/services/audio_playback_service.dart

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Result of an audio play attempt — avoids throwing across widget boundaries.
enum AudioLoadResult { success, missingAsset, networkError, silentMode, unknown }

/// Singleton Service quản lý việc phát audio trong app.
/// Đảm bảo chỉ có 1 instance AudioPlayer để tránh đè âm thanh.
class AudioPlaybackService {
  AudioPlaybackService._internal();

  static final AudioPlaybackService instance =
      AudioPlaybackService._internal();

  AudioPlayer? _player;
  String? _currentSource;

  // ─── Getters ───────────────────────────────────────────────────────────────

  AudioPlayer get player {
    _player ??= AudioPlayer();
    return _player!;
  }

  bool get isPlaying => _player?.playing ?? false;

  Stream<PlayerState> get playerStateStream => player.playerStateStream;
  Stream<Duration?> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;

  Duration get position => _player?.position ?? Duration.zero;
  Duration get duration => _player?.duration ?? Duration.zero;

  String? get currentSource => _currentSource;

  // ─── Public Play API ───────────────────────────────────────────────────────

  /// Auto-detect: URL vs asset path.
  /// Returns [AudioLoadResult] so the caller can show appropriate UI feedback
  /// WITHOUT crashing. Never rethrows.
  Future<AudioLoadResult> play(String source, {bool isSilentMode = false}) async {
    // ── 1. Silent-mode gate ────────────────────────────────────────────────
    if (isSilentMode) {
      debugPrint('🔇 AudioPlaybackService: silent mode — rejecting play()');
      return AudioLoadResult.silentMode;
    }

    // ── 2. Route to correct loader ─────────────────────────────────────────
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return _playFromUrl(source);
    } else {
      // Strip "asset:///" prefix if present so we always pass a clean path.
      final assetPath = source.startsWith('asset:///')
          ? source.replaceFirst('asset:///', '')
          : source;
      return _playFromAsset(assetPath);
    }
  }

  /// Pause the current playback.
  Future<void> pause() async {
    await _player?.pause();
  }

  /// Stop + forget source.
  Future<void> stop() async {
    await _player?.stop();
    _currentSource = null;
  }

  Future<void> seek(Duration position) async {
    await _player?.seek(position);
  }

  Future<void> togglePlayPause({bool isSilentMode = false}) async {
    if (isSilentMode) return;
    if (isPlaying) {
      await pause();
    } else {
      await player.play();
    }
  }

  // ─── Cleanup ───────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    _currentSource = null;
  }

  Future<void> reset() async {
    await stop();
    await _player?.seek(Duration.zero);
  }

  // ─── Private Loaders ───────────────────────────────────────────────────────

  Future<AudioLoadResult> _playFromUrl(String url) async {
    try {
      if (_currentSource == url && isPlaying) {
        await pause();
        return AudioLoadResult.success;
      }

      if (_currentSource != url) {
        await player.setUrl(url);
        _currentSource = url;
      }

      await player.play();
      return AudioLoadResult.success;
    } on PlayerException catch (e) {
      debugPrint('❌ AudioPlaybackService [URL] PlayerException: $e');
      await _safeReset();
      return AudioLoadResult.networkError;
    } catch (e) {
      debugPrint('❌ AudioPlaybackService [URL] unknown error: $e');
      await _safeReset();
      return AudioLoadResult.unknown;
    }
  }

  Future<AudioLoadResult> _playFromAsset(String assetPath) async {
    try {
      final cacheKey = 'asset:///$assetPath';

      if (_currentSource == cacheKey && isPlaying) {
        await pause();
        return AudioLoadResult.success;
      }

      if (_currentSource != cacheKey) {
        // This throws if the file doesn't exist in the bundle.
        await player.setAsset(assetPath);
        _currentSource = cacheKey;
      }

      await player.play();
      return AudioLoadResult.success;

    // just_audio wraps missing assets in PlayerException with an
    // ASSET_LOAD_ERROR code; we also catch generic exceptions as fallback.
    } on PlayerException catch (e) {
      debugPrint('❌ AudioPlaybackService [Asset] PlayerException: $e');
      await _safeReset();
      // Treat any asset-load failure as "missing asset" for MVP messaging.
      return AudioLoadResult.missingAsset;
    } catch (e) {
      debugPrint('❌ AudioPlaybackService [Asset] unknown error: $e');
      await _safeReset();
      return AudioLoadResult.missingAsset; // conservative for MVP
    }
  }

  /// Hard-reset without throwing — called after any error.
  Future<void> _safeReset() async {
    try {
      await _player?.stop();
      _currentSource = null;
    } catch (_) {
      // Swallow — we're already in error recovery.
    }
  }
}
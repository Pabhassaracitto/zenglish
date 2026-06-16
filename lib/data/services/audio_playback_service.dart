import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

/// Singleton Service quản lý việc phát audio trong app
/// Đảm bảo chỉ có 1 instance AudioPlayer để tránh đè âm thanh
class AudioPlaybackService {
  AudioPlaybackService._internal();
  
  static final AudioPlaybackService instance = AudioPlaybackService._internal();
  
  AudioPlayer? _player;
  String? _currentSource;
  
  // ─── Getters ─────────────────────────────────
  
  AudioPlayer get player {
    _player ??= AudioPlayer();
    return _player!;
  }
  
  bool get isPlaying => _player?.playing ?? false;
  
  Stream<PlayerState> get playerStateStream => 
      player.playerStateStream;
  
  Stream<Duration?> get positionStream => 
      player.positionStream;
  
  Stream<Duration?> get durationStream => 
      player.durationStream;
  
  Duration get position => _player?.position ?? Duration.zero;
  Duration get duration => _player?.duration ?? Duration.zero;
  
  String? get currentSource => _currentSource;
  
  // ─── Play Methods ────────────────────────────
  
  /// Phát audio từ URL (network)
  Future<void> playFromUrl(String url) async {
    try {
      if (_currentSource == url && isPlaying) {
        // Nếu đang phát cùng source → pause
        await pause();
        return;
      }
      
      if (_currentSource != url) {
        // Load source mới
        await player.setUrl(url);
        _currentSource = url;
      }
      
      await player.play();
    } catch (e) {
      debugPrint('❌ Error playing audio from URL: $e');
      rethrow;
    }
  }
  
  /// Phát audio từ assets
  Future<void> playFromAsset(String assetPath) async {
    try {
      final source = 'asset:///$assetPath';
      
      if (_currentSource == source && isPlaying) {
        await pause();
        return;
      }
      
      if (_currentSource != source) {
        await player.setAsset(assetPath);
        _currentSource = source;
      }
      
      await player.play();
    } catch (e) {
      debugPrint('❌ Error playing audio from asset: $e');
      rethrow;
    }
  }
  
  /// Phát audio từ source tự động (phát hiện URL hoặc asset)
  Future<void> play(String source) async {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      await playFromUrl(source);
    } else if (source.startsWith('assets/') || source.startsWith('asset://')) {
      final assetPath = source.replaceFirst('asset:///', '');
      await playFromAsset(assetPath);
    } else {
      // Mặc định coi như asset
      await playFromAsset(source);
    }
  }
  
  // ─── Control Methods ─────────────────────────
  
  Future<void> pause() async {
    await _player?.pause();
  }
  
  Future<void> stop() async {
    await _player?.stop();
    _currentSource = null;
  }
  
  Future<void> seek(Duration position) async {
    await _player?.seek(position);
  }
  
  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await player.play();
    }
  }
  
  // ─── Cleanup ─────────────────────────────────
  
  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    _currentSource = null;
  }
  
  /// Reset player về trạng thái ban đầu
  Future<void> reset() async {
    await stop();
    await _player?.seek(Duration.zero);
  }
}

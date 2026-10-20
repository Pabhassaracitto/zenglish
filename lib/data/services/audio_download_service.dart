// lib/data/services/audio_download_service.dart
//
// Facade điều hướng platform — giữ public API ổn định cho toàn app.
//
//   * Shared models + helpers (encode/parse, DownloadedAudioInfo, …)
//     → `src/audio_download_models.dart` (web-safe)
//   * Platform impl của AudioDownloadService
//     → `src/audio_download_service_io.dart`  trên mobile/desktop
//     → `src/audio_download_service_web.dart` trên web

export 'src/audio_download_models.dart';

export 'src/audio_download_service_io.dart'
    if (dart.library.html) 'src/audio_download_service_web.dart';

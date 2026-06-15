// ============================================================
// MAIN.DART - Entry point
// Khởi tạo: SharedPreferences → ProviderScope → App
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zenglishapp/core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/user_profile_provider.dart';

Future<void> main() async {
  // ── 1. Đảm bảo Flutter binding sẵn sàng ──
  WidgetsFlutterBinding.ensureInitialized();

  // ── 2. UI settings ──
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar: dark icons trên nền kem
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.creamLight,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // ── 3. Khởi tạo SharedPreferences ──
  final sharedPreferences = await SharedPreferences.getInstance();

  // ── 4. Chạy app với ProviderScope ──
  runApp(
    ProviderScope(
      // Override sharedPreferencesProvider với instance thực
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      observers: [
        // Log provider changes khi debug
        if (const bool.fromEnvironment('dart.vm.product') == false)
          const _AppProviderObserver(),
      ],
      child: const ZENGLISHApp(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// ROOT APP WIDGET
// ─────────────────────────────────────────────────────────────

class ZENGLISHApp extends ConsumerWidget {
  const ZENGLISHApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy router (đã được cung cấp bởi appRouterProvider)
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      // ── App Info ──
      title: 'ZENGLISH - English for Wisdom & Meditation',
      debugShowCheckedModeBanner: false,

      // ── Router ──
      routerConfig: router,

      // ── Theme ──
      theme: AppTheme.light,
      // darkTheme: AppTheme.dark, // TODO: Implement dark theme
      themeMode: ThemeMode.light,

      // ── Localization (cơ bản) ──
      locale: const Locale('vi', 'VN'),
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],

      // ── Builder: Wrap toàn bộ app ──
      builder: (context, child) {
        // Đảm bảo text scale không quá lớn (UX nhất quán)
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.85, 1.15),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PROVIDER OBSERVER - Debug logging
// ─────────────────────────────────────────────────────────────

class _AppProviderObserver extends ProviderObserver {
  const _AppProviderObserver();

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Chỉ log providers quan trọng
    if (provider.name == 'userProfileProvider') {
      debugPrint(
        '[Provider] ${provider.name}: '
        '${previousValue.runtimeType} → ${newValue.runtimeType}',
      );
    }
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    debugPrint('[Provider ERROR] ${provider.name}: $error');
  }
}

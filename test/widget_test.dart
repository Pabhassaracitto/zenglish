import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenglish/core/providers/user_profile_provider.dart';
import 'package:zenglish/data/services/user_session_service.dart';
import 'package:zenglish/main.dart';
import 'package:zenglish/presentation/screens/placement/placement_test_screen.dart';
import 'package:zenglish/l10n/app_localizations.dart';

void main() {
  testWidgets('first launch reaches placement without a network or profile',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await UserSessionService.instance.init();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ZENGLISHApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(PlacementTestScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final code in ['vi', 'en']) {
    testWidgets('generated $code translations work through the stable facade',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        locale: Locale(code),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(builder: (context) {
          return Scaffold(body: Text(context.l10n.continueText));
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.text(code == 'vi' ? 'Tiếp tục' : 'Continue'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

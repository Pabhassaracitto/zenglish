#!/usr/bin/env python3
import json
import glob
import os

def generate_localizations():
    arb_files = sorted(glob.glob('lib/l10n/*.arb'))
    translations = {}
    
    with open('lib/l10n/app_vi.arb', 'r', encoding='utf-8') as fp:
        vi_data = json.load(fp)
        all_keys = sorted([k for k in vi_data.keys() if not k.startswith('@')])

    for f in arb_files:
        with open(f, 'r', encoding='utf-8') as fp:
            data = json.load(fp)
            loc = data.get('@@locale')
            translations[loc] = {k: data.get(k, vi_data.get(k, '')) for k in all_keys}

    def escape_dart_str(s):
        s = s.replace('\\', '\\\\')
        s = s.replace("'", "\\'")
        s = s.replace('\n', '\\n')
        s = s.replace('\r', '\\r')
        s = s.replace('$', '\\$')
        return s

    def class_name(loc):
        if loc == 'zh_TW':
            return 'AppLocalizationsZhTw'
        return f'AppLocalizations{loc.capitalize()}'

    out = []
    out.append('// GENERATED FILE - DO NOT EDIT MANUALLY')
    out.append('// ZenGlish localization facade supporting 26 languages.\n')
    out.append('import \'dart:async\';\n')
    out.append('import \'package:flutter/foundation.dart\';')
    out.append('import \'package:flutter/widgets.dart\';')
    out.append('import \'package:flutter_localizations/flutter_localizations.dart\';\n')
    out.append('/// Extension on [BuildContext] to easily access [AppLocalizations].')
    out.append('extension AppLocalizationsX on BuildContext {')
    out.append('  AppLocalizations get l10n => AppLocalizations.of(this);')
    out.append('}\n')
    out.append('/// Abstract base class for ZenGlish localizations.')
    out.append('abstract class AppLocalizations {')
    out.append('  AppLocalizations(this.localeName);\n')
    out.append('  final String localeName;\n')
    out.append('  static AppLocalizations of(BuildContext context) {')
    out.append('    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? lookupAppLocalizations(const Locale(\'vi\'));')
    out.append('  }\n')
    out.append('  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();\n')
    out.append('  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[')
    out.append('    delegate,')
    out.append('    GlobalMaterialLocalizations.delegate,')
    out.append('    GlobalCupertinoLocalizations.delegate,')
    out.append('    GlobalWidgetsLocalizations.delegate,')
    out.append('  ];\n')
    out.append('  static const List<Locale> supportedLocales = <Locale>[')
    out.append("    Locale('ar'),")
    out.append("    Locale('bn'),")
    out.append("    Locale('bo'),")
    out.append("    Locale('de'),")
    out.append("    Locale('en'),")
    out.append("    Locale('es'),")
    out.append("    Locale('fr'),")
    out.append("    Locale('hi'),")
    out.append("    Locale('id'),")
    out.append("    Locale('it'),")
    out.append("    Locale('ja'),")
    out.append("    Locale('km'),")
    out.append("    Locale('ko'),")
    out.append("    Locale('lo'),")
    out.append("    Locale('mn'),")
    out.append("    Locale('mr'),")
    out.append("    Locale('my'),")
    out.append("    Locale('pt'),")
    out.append("    Locale('ru'),")
    out.append("    Locale('si'),")
    out.append("    Locale('ta'),")
    out.append("    Locale('te'),")
    out.append("    Locale('th'),")
    out.append("    Locale('vi'),")
    out.append("    Locale('zh'),")
    out.append("    Locale('zh', 'TW'),")
    out.append('  ];\n')

    for k in all_keys:
        out.append(f'  String get {k};')

    out.append('}\n')
    out.append('class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {')
    out.append('  const _AppLocalizationsDelegate();\n')
    out.append('  @override')
    out.append('  Future<AppLocalizations> load(Locale locale) {')
    out.append('    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));')
    out.append('  }\n')
    out.append('  @override')
    out.append('  bool isSupported(Locale locale) => <String>[')
    out.append("    'ar', 'bn', 'bo', 'de', 'en', 'es', 'fr', 'hi', 'id', 'it', 'ja', 'km', 'ko', 'lo', 'mn', 'mr', 'my', 'pt', 'ru', 'si', 'ta', 'te', 'th', 'vi', 'zh'")
    out.append('  ].contains(locale.languageCode);\n')
    out.append('  @override')
    out.append('  bool shouldReload(_AppLocalizationsDelegate old) => false;')
    out.append('}\n')
    out.append('AppLocalizations lookupAppLocalizations(Locale locale) {')
    out.append("  if (locale.languageCode == 'zh') {")
    out.append("    if (locale.countryCode == 'TW') {")
    out.append('      return AppLocalizationsZhTw();')
    out.append('    }')
    out.append('    return AppLocalizationsZh();')
    out.append('  }')
    out.append('  switch (locale.languageCode) {')
    for loc in sorted(translations.keys()):
        if loc == 'zh_TW':
            continue
        cname = class_name(loc)
        out.append(f"    case '{loc}': return {cname}();")
    out.append('  }')
    out.append('  return AppLocalizationsVi();')
    out.append('}\n')

    for loc, vals in translations.items():
        cname = class_name(loc)
        out.append(f'/// The translations for `{loc}`.')
        out.append(f'class {cname} extends AppLocalizations {{')
        out.append(f"  {cname}([super.localeName = '{loc}']);\n")
        for k in all_keys:
            v = escape_dart_str(vals[k])
            out.append(f'  @override\n  String get {k} => \'{v}\';\n')
        out.append('}\n')

    content = '\n'.join(out)
    with open('lib/l10n/app_localizations.dart', 'w', encoding='utf-8') as fp:
        fp.write(content)

    print(f'Successfully wrote {len(content)} bytes to lib/l10n/app_localizations.dart')

if __name__ == '__main__':
    generate_localizations()

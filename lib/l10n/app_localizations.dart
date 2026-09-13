// Stable facade: generated translations must not overwrite this extension.
import 'package:flutter/widgets.dart';
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

extension LocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

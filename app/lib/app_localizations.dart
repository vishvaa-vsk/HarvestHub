import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'helloWorld': 'Hello World',
    },
    'es': {
      'helloWorld': 'Hola Mundo',
    },
    'fr': {
      'helloWorld': 'Bonjour le monde',
    },
  };

  String get helloWorld {
    return _localizedValues[locale.languageCode]!['helloWorld']!;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.sync(() => AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) {
    return false;
  }
}

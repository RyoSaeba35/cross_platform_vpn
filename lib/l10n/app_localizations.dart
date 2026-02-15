import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Vulcain VPN',
      'connected': 'Connected',
      'disconnected': 'Disconnected',
      'connecting': 'Connecting...',
      'location': 'Location',
      'duration': 'Duration',
      'secure_connection': '🔒 Your connection is secure',
      'disconnect': 'Disconnect',
      'connect': 'Connect',
      'connecting_btn': 'Connecting...',
      'france': 'France',
      'settings': 'Settings',
      'language': 'Language',
      'english': 'English',
      'french': 'French',
      'fetching_ip': 'Fetching IP...',
    },
    'fr': {
      'app_title': 'Vulcain VPN',
      'connected': 'Connecté',
      'disconnected': 'Déconnecté',
      'connecting': 'Connexion en cours...',
      'location': 'Localisation',
      'duration': 'Durée',
      'secure_connection': '🔒 Votre connexion est sécurisée',
      'disconnect': 'Déconnecter',
      'connect': 'Connecter',
      'connecting_btn': 'Connexion...',
      'france': 'France',
      'settings': 'Paramètres',
      'language': 'Langue',
      'english': 'Anglais',
      'french': 'Français',
      'fetching_ip': 'Récupération IP...',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Convenience getters
  String get appTitle => translate('app_title');
  String get connected => translate('connected');
  String get disconnected => translate('disconnected');
  String get connecting => translate('connecting');
  String get location => translate('location');
  String get duration => translate('duration');
  String get secureConnection => translate('secure_connection');
  String get disconnect => translate('disconnect');
  String get connect => translate('connect');
  String get connectingBtn => translate('connecting_btn');
  String get france => translate('france');
  String get settings => translate('settings');
  String get language => translate('language');
  String get english => translate('english');
  String get french => translate('french');
  String get fetchingIp => translate('fetching_ip');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

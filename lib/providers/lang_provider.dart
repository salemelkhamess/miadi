import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _selectedLocale = Locale('fr');

  Locale get selectedLocale => _selectedLocale;

  set selectedLocale(Locale locale) {
    _selectedLocale = Locale(locale.languageCode);
    notifyListeners();
  }
}

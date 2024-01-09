import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreferences {
  static const String _selectedLanguageKey = 'selected_language';

  // Récupérer la langue sélectionnée
  static Future<Locale?> getSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString(_selectedLanguageKey);
    if (languageCode != null && languageCode.isNotEmpty) {
      return Locale(languageCode);
    }
    return null;
  }

  // Enregistrer la langue sélectionnée
  static Future<void> setSelectedLanguage(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLanguageKey, locale.languageCode);
  }
}

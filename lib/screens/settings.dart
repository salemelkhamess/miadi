import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/lang_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  Locale _selectedLocale = Locale('en', 'US'); // Anglais par défaut

  void _onLocaleChanged(Locale locale) {
    setState(() {
      _selectedLocale = locale;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('parametre'),
      ),
      body: Center(
        child: DropdownButton<Locale>(
          value: _selectedLocale,
          onChanged: (Locale? newLocale) {
            if (newLocale != null) {
              _onLocaleChanged(newLocale);
            }
          },
          items: [
            DropdownMenuItem(
              value: Locale('en', 'US'),
              child: Text('English'),
            ),
            DropdownMenuItem(
              value: Locale('fr', 'FR'),
              child: Text('Français'),
            ),
            DropdownMenuItem(
              value: Locale('ar', 'AR'),
              child: Text('العربية'),
            ),
          ],
        ),
      ),
    );
  }
}

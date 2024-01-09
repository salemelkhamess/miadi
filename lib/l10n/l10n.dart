import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class L10n{

  static const List<Locale> all = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];


  AppLocalizations translation(BuildContext context) {
    return AppLocalizations.of(context)!;
  }
}
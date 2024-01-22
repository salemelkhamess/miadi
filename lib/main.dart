import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rdv/main_layout.dart';
import 'package:rdv/models/auth_model.dart';
import 'package:rdv/providers/lang_provider.dart';
import 'package:rdv/screens/auth_page.dart';
import 'package:rdv/screens/booking_page.dart';
import 'package:rdv/screens/contact.dart';
import 'package:rdv/screens/doctor_by_sp.dart';
import 'package:rdv/screens/site_by_cartier.dart';
import 'package:rdv/screens/success_booked.dart';
import 'package:rdv/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;

import 'package:intl/date_symbol_data_local.dart';
import './l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // ChangeNotifierProvider<LanguageProvider>(
  //   create: (_) => LanguageProvider()..fetchLocaleFromPreferences(),
  //   child: MyApp(selectedLocale),
  // );
  // intl.Intl.defaultLocale = 'fr'; // Set default locale to French
  // runApp(MyApp());

  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: MyApp(),
    ),
  );

  // initializeDateFormatting('fr_FR', null).then((_) {
  //   // Récupérer la langue sélectionnée depuis les préférences partagées
  //
  //
  // });
}

class MyApp extends StatefulWidget {

  // final Locale? selectedLocale;

  MyApp();

  //this is for push navigator
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool> checkAuthenticationStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final tokenValue = prefs.getString('token') ?? '';

    return tokenValue.isNotEmpty && tokenValue != '';
  }



  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);


    return FutureBuilder<bool>(
      future: checkAuthenticationStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While checking the authentication status, show a loading indicator
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If an error occurred while checking, handle it accordingly
          return Center(child: Text('An error occurred'));
        } else {
          // Retrieve the authentication status result
          bool isAuthenticated = snapshot.data ?? false;

          return ChangeNotifierProvider<AuthModel>(
            create: (context) => AuthModel(),
            child: MaterialApp(
              navigatorKey: MyApp.navigatorKey,
              title: 'Rendez-vous ',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                //pre-define input decoration
                inputDecorationTheme: const InputDecorationTheme(
                  focusColor: Config.primaryColor,
                  border: Config.outlinedBorder,
                  focusedBorder: Config.focusBorder,
                  errorBorder: Config.errorBorder,
                  enabledBorder: Config.outlinedBorder,
                  floatingLabelStyle: TextStyle(color: Config.primaryColor),
                  prefixIconColor: Colors.black38,
                ),
                scaffoldBackgroundColor: Colors.white,
                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                  backgroundColor: Config.primaryColor,
                  selectedItemColor: Colors.white,
                  showSelectedLabels: true,
                  showUnselectedLabels: false,
                  unselectedItemColor: Colors.grey.shade700,
                  elevation: 10,
                  type: BottomNavigationBarType.fixed,
                ),
              ),
              supportedLocales: AppLocalizations.supportedLocales,
              locale: languageProvider.selectedLocale,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ]
              ,
              initialRoute: isAuthenticated ? 'main' :   '/',
              routes: {
                '/': (context) =>  AuthPage(),
                'main': (context) =>  MainLayout(),
                'booking_page': (context) => BookingPage(),
                'success_booking': (context) => const AppointmentBooked(),
                'contact': (context) =>   ContactUsApp(),

                'site_by_cartier': (context) {
                  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                  final id = args['id'] as int?;
                  final name = args['name'] as String?;

                  return SiteByCartier(id: id,name: name,);

                },

                'doctor_by_sp': (context) {
                  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                  final  sps = args['sp'] as String;
                  return DoctorBySp(sp: sps);
                },



              },
            ),
          );
        }
      },
    );

      //define ThemeData here
    // return ChangeNotifierProvider<AuthModel>(
    //   create: (context) => AuthModel(),
    //   child: MaterialApp(
    //     navigatorKey: navigatorKey,
    //     title: 'Rendez-vous ',
    //     debugShowCheckedModeBanner: false,
    //     theme: ThemeData(
    //       //pre-define input decoration
    //       inputDecorationTheme: const InputDecorationTheme(
    //         focusColor: Config.primaryColor,
    //         border: Config.outlinedBorder,
    //         focusedBorder: Config.focusBorder,
    //         errorBorder: Config.errorBorder,
    //         enabledBorder: Config.outlinedBorder,
    //         floatingLabelStyle: TextStyle(color: Config.primaryColor),
    //         prefixIconColor: Colors.black38,
    //       ),
    //       scaffoldBackgroundColor: Colors.white,
    //       bottomNavigationBarTheme: BottomNavigationBarThemeData(
    //         backgroundColor: Config.primaryColor,
    //         selectedItemColor: Colors.white,
    //         showSelectedLabels: true,
    //         showUnselectedLabels: false,
    //         unselectedItemColor: Colors.grey.shade700,
    //         elevation: 10,
    //         type: BottomNavigationBarType.fixed,
    //       ),
    //     ),
    //     initialRoute:   '/',
    //     routes: {
    //       '/': (context) =>  AuthPage(),
    //       'main': (context) => const MainLayout(),
    //       'booking_page': (context) => BookingPage(),
    //       'success_booking': (context) => const AppointmentBooked(),
    //       'site_by_cartier': (context) {
    //         final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    //         final id = args['id'] as int?;
    //         return SiteByCartier(id: id);
    //
    //       },
    //
    //
    //     },
    //   ),
    // );

  }
}

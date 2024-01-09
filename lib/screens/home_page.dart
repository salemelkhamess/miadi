import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rdv/components/appointment_card.dart';
import 'package:rdv/components/doctor_card.dart';
import 'package:rdv/models/auth_model.dart';
import 'package:rdv/screens/site_by_cartier.dart';
import 'package:rdv/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;

import '../providers/dio_provider.dart';
import '../providers/lang_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Map<String, dynamic> user = {};
  Map<String,dynamic> doctor = {};
  List<dynamic> sites = [];

  List<dynamic> favList = [];
  List<dynamic> cartier = [];
  List<dynamic> filteredSites = []; // Liste filtrée en fonction de la recherche

  String selectedSpecialty ='Dentiste';
  List<String> specialities = [];
  Future<void> _initializeData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final data = await fetchSpecialities(token);
    setState(() {
      specialities = data;
    });

  }
  Future<List<String>> fetchSpecialities(String token) async {
    try {
      var user = await Dio().get(
        '${Config.baseUrl}/speciality',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (user.statusCode == 200 && user.data != '') {
        final data = List<String>.from(user.data);
        return data;
      }
    } catch (error) {
      // En cas d'erreur, renvoyer une liste vide
    }

    return []; // Valeur par défaut en cas d'erreur
  }
  bool isSearchVisible = false; // État pour contrôler la visibilité du champ de recherche

  // Fonction pour effectuer la recherche
  void filterDoctorList(String query) {
    setState(() {
      filteredSites = sites
          .where((doctor) => doctor['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
      isSearchVisible=true;
    });
  }

  @override
  void initState() {
    super.initState();
    check();
    _initializeData();
    print(sites);
  }


  Locale _selectedLocale = Locale('fr');

  void _onLocaleChanged(Locale locale) {
    Provider.of<LanguageProvider>(context, listen: false).selectedLocale = locale;
    _selectedLocale = locale;
  }


  Future<void> check() async {
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');
    if (token != null && token.isNotEmpty) {
      final response = await DioProvider().getSites(token);
      final cartiers = await DioProvider().getCartiers(token);
      final users = await DioProvider().getUser(token);
      if (response != null) {
        setState(() {
          //json decode
          // final  appointment = json.decode(appts);
          final site = json.decode(response);
          final cartier = json.decode(cartiers);
          final user = json.decode(users);

          final data = {
            'sites': site,
            'cartiers': cartier,
            'users': user,
          };
          final auth = Provider.of<AuthModel>(context, listen: false);
          auth.setUserData(user);
          // auth.setAppointmentData(doctor);
          // auth.setFavData(favList);
          auth.setSiteData(site);
          auth.setCartierData(cartier);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    Config().init(context);
    user = Provider.of<AuthModel>(context, listen: false).getUser;
    doctor = Provider.of<AuthModel>(context, listen: false).getAppointment;
    favList = Provider.of<AuthModel>(context, listen: false).getFav;
    sites = Provider.of<AuthModel>(context,listen: false).getSite;
    cartier = Provider.of<AuthModel>(context,listen: false).getCartier;

    return Scaffold(
      //if user is empty, then return progress indicator
      body: sites.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.choisirVotreClinique,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                           SizedBox(
                            child : DropdownButton<Locale>(

                              value: _selectedLocale,
                              onChanged: (Locale? newLocale) {
                                if (newLocale != null) {
                                  _onLocaleChanged(newLocale);
                                  setState(() {
                                    _selectedLocale = newLocale;
                                  });
                                }
                              },
                              items: [
                                DropdownMenuItem(
                                  value: Locale('en'),
                                  child: Text('English'),
                                ),
                                DropdownMenuItem(
                                  value: Locale('fr'),
                                  child: Text('Français'),
                                ),
                                DropdownMenuItem(
                                  value: Locale('ar'),
                                  child: Text('العربية'),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Config.spaceMedium,
                       Text(
                         AppLocalizations.of(context)!.rechercheParClinique,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Config.spaceSmall,
                      SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: List<Widget>.generate(cartier.length, (index) {
                            return   Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8), // Adjust the horizontal padding as needed
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, 'site_by_cartier',
                                          arguments: {'id': cartier[index]['id']});
                                    },
                                    child: CircleAvatar(
                                      radius: 37,
                                      backgroundColor: Colors.white,
                                      child: Image.asset(
                                        "assets/cl.png",
                                        fit: BoxFit.cover, // Adjust the fit as needed
                                      ),
                                    ),
                                  ),

                                  Text(
                                   "${  AppLocalizations.of(context)!.clinique} ${cartier[index]['name']}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  )

                                ],
                              ),
                            );

                          }),
                        ),
                      ),

                /*      Config.spaceSmall,
                       Text(
                        AppLocalizations.of(context)!.rechercheParSp,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),*/

                      Config.spaceSmall,
                      Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: TextField(
                          onChanged: filterDoctorList,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.dr_by_name,
                          ),
                        ),
                      ),
                      // Liste des docteurs filtrée

                      Column(
                        children: [
                          // Liste des docteurs filtrée (Visible seulement si la recherche est active)
                          Visibility(
                            visible: isSearchVisible,
                            child: Column(
                              children: List.generate(filteredSites.length, (index) {
                                return DoctorCard(
                                  doctor: filteredSites[index],
                                  //if lates fav list contains particular doctor id, then show fav icon
                                  isFav: favList
                                      .contains(filteredSites[index]['id'])
                                      ? true
                                      : false,
                                );
                              }
                              ),
                            ),
                          ),
                          // Liste des docteurs complète (Visible si la recherche n'est pas active)
                          Visibility(
                            visible: !isSearchVisible,
                            child: Column(
                              children: List.generate(sites.length, (index) {
                                return DoctorCard(
                                  doctor: sites[index],
                                  //if lates fav list contains particular doctor id, then show fav icon
                                  isFav: favList
                                      .contains(sites[index]['id'])
                                      ? true
                                      : false,
                                );
                              }),
                            ),
                          ),
                        ],
                      ),


                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

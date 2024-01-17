import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rdv/components/appointment_card.dart';
import 'package:rdv/components/doctor_card.dart';
import 'package:rdv/models/auth_model.dart';
import 'package:rdv/screens/site_by_cartier.dart';
import 'package:rdv/screens/whatsapp.dart';
import 'package:rdv/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;

import '../components/custom_image.dart';
import '../components/favorite_box.dart';
import '../providers/dio_provider.dart';
import '../providers/lang_provider.dart';
import '../utils/color.dart';

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

  late String _selectedLocation ="FR";

  var _locations = ['FR', 'AR', 'EN'];


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
    sites = Provider.of<AuthModel>(context, listen: false).getSite;
    cartier = Provider.of<AuthModel>(context, listen: false).getCartier;

    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;

    return Scaffold(
/*
      floatingActionButton: WhatsAppFloatingButton(),
*/

      body: sites.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

        Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.bv ,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: AppColor.darker,
                      fontFamily: "Metropolis",
                      fontWeight: FontWeight.w900),
                ),

              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.appname ,
                    style: TextStyle(
                        fontSize: 11.0,
                        color: Colors.black,
                        fontFamily: "Metropolis",
                        fontWeight: FontWeight.w300),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [


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
                              child: Text('English',style: TextStyle( fontFamily: "Metropolis",)),
                            ),
                            DropdownMenuItem(
                              value: Locale('fr'),
                              child: Text('Français',style: TextStyle( fontFamily: "Metropolis",),),
                            ),
                            DropdownMenuItem(
                              value: Locale('ar'),
                              child: Text('العربية',style: TextStyle( fontFamily: "Metropolis",)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Container(
                height: _height * 0.06,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                    color: Colors.grey.withOpacity(0.25)),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 20),
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/search.svg",
                        height: 20,
                        color: AppColor.blue,
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 20),
                        child: Text(
                          "search",
                          style: TextStyle(
                              fontFamily: "Metropolis",
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ]
      ),
    ),

            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: cartier.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, 'site_by_cartier',
                          arguments: {'id': cartier[index]['id']});
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.shadowColor.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImage(),
                          Container(
                            width: 280 - 20,
                            padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildName("${  AppLocalizations.of(context)!.clinique} ${cartier[index]['name']}",),
                                SizedBox(height: 2),
                                _buildInfo(
                                    "${cartier[index]['address']}"
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildName(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 18,
        color: AppColor.textColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInfo(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adresse',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColor.labelColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColor.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Spacer(), // Utilisez Spacer pour occuper l'espace disponible

        FavoriteBox(
          size: 16,
          onTap: (){},
          isFavorited: false,
        )
      ],
    );

  }

  Widget _buildImage() {
    return CustomImage(
    'assets/Cl2.png',
      width: double.infinity,
      height: 190,
      radius: 15,
    );
  }
}



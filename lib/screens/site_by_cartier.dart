import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rdv/components/appointment_card.dart';
import 'package:rdv/components/doctor_card.dart';
import 'package:rdv/models/auth_model.dart';
import 'package:rdv/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/custom_appbar.dart';
import '../main.dart';
import '../providers/dio_provider.dart';
import '../utils/color.dart';
import 'doctor_details.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SiteByCartier extends StatefulWidget {
  final id;
  final name;

  const SiteByCartier({required this.id, this.name}) ;

  @override
  State<SiteByCartier> createState() => _SiteByCartierState(id:id,name:name);
}

class _SiteByCartierState extends State<SiteByCartier> {

  List<dynamic> sites = [];
  Map<String,dynamic> mes_sites = {};

  late int id ;
  late String name;
  _SiteByCartierState({required this.id,required this.name});

  String selectedSpecialty = 'Dentiste';
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

  Future<void> getSiteByCartier(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final site = await DioProvider().getSitesByCartier(token, id);
    if (site != 'Error') {
      setState(() {
        sites = json.decode(site);

      });
    }
  }
  List<dynamic> filteredSites = []; // Liste filtrée en fonction de la recherche

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
  // Fonction pour charger les données des docteurs depuis l'API (utilisez votre propre logique d'appel API ici)
  // void loadDoctorData() async {
  //   // Utilisez http pour effectuer la requête d'API vers votre Laravel backend
  //   // Assurez-vous d'ajuster l'URL de l'API selon votre configuration
  //   var response = await http.get(Uri.parse("https://votre-api-laravel.com/api/doctors"));
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       sites = json.decode(response.body);
  //       filteredSites = sites; // Initialisez filteredSites avec la liste complète au début
  //     });
  //   } else {
  //     // Gestion des erreurs
  //     print("Erreur lors du chargement des docteurs depuis l'API");
  //   }
  // }


  @override
  void initState() {
    getSiteByCartier(id);
    super.initState();
    _initializeData();
    // loadDoctorData();

  }

  late String _selectedLocation ="FR";

  var _locations = ['FR', 'AR', 'EN'];
  static const colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];
  @override
  Widget build(BuildContext context) {
    Config().init(context);

    return Scaffold(
      appBar: CustomAppBar(
        appTitle:'',
        icon: const FaIcon(Icons.arrow_back_ios),

      ),
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
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    elevation: 2, // Ajoutez l'élévation souhaitée pour le Card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Container(
                      padding: EdgeInsets.only(left: 5, top: 5),
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: AnimatedTextKit(
                          animatedTexts: [
                            ColorizeAnimatedText(
                              '${AppLocalizations.of(context)!.clinique} ${name}',
                              textStyle: TextStyle(
                                  fontSize: 18
                              ),
                              colors: colorizeColors,
                            ),
                          ],
                          isRepeatingAnimation: true,
                          pause: const Duration(milliseconds: 1000),
                          displayFullTextOnTap: true,
                          stopPauseOnTap: true,
                          onTap: () {
                            print("Tap Event");
                          },
                        ),
                      ),
                      ),
                    ),
                  ),




                /*            Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                AppLocalizations.of(context)!.appname ,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: AppColor.darker,
                          fontFamily: "Metropolis",
                          fontWeight: FontWeight.w900),
                    ),

                  ],
                ),*/
         /*       Padding(
                  padding: const EdgeInsets.all(10.0),
                  child:Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 5 ,top: 5),
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      decoration: BoxDecoration(
                        color:Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 2,
                            spreadRadius: 2,
                            color: Colors.grey,

                          ),
                        ],
                      ),

                      child: Center(
                        child: Text(
                          "CLINQUE ${name}",
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.green,
                              fontFamily: "Metropolis",
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),*/
/*

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:  Center(
                    // child: Padding(
                    //   padding: EdgeInsets.all(20),
                    //   child: Text(
                    //     'Prendre votre rendez vous',
                    //     style: TextStyle(
                    //       fontSize: 16,
                    //       fontWeight: FontWeight.w600,
                    //     ),
                    //   ),
                    // ),

                    child:  Padding(
                      padding: EdgeInsets.all(10.0),
                  child: Container(
                    width: double.infinity,
                    child: DropdownButton<String>(
                      isExpanded: true, // Permet aux éléments de la liste de prendre toute la largeur
                      value: selectedSpecialty,
                      hint: Text('Select a specialty'),
                      onChanged: (String? newValue) {

                        setState(() async{

                          selectedSpecialty = newValue!;

                          Navigator.pushNamed(context, 'doctor_by_sp', arguments: {'sp': selectedSpecialty});

                        }
                        );
                      },
                      items: specialities.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: SizedBox(
                            width: double.infinity, // Ajuste la largeur de l'élément à la largeur maximale
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),


                  ),
                  ),
*/

      /*          Config.spaceSmall,
                 Text(
                  AppLocalizations.of(context)!.best_dr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),*/
                Config.spaceSmall,

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: filterDoctorList,
                    style: TextStyle(
                      fontFamily: "Metropolis",
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsetsDirectional.only(start: 20),
                      hintText: AppLocalizations.of(context)!.dr_by_name,
                      hintStyle: TextStyle(
                        color: Colors.black,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsetsDirectional.only(end: 12),
                        child: Icon(
                            Icons.search
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.25),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(28)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: isSearchVisible,

                  child: Column(
                    children: List.generate(filteredSites.length, (index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        height: 150,
                        child: GestureDetector(
                          child: Card(
                            elevation: 5,
                            color: Colors.white,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: Config.widthSize * 0.33,
                                  child:           CircleAvatar(
                                    radius: 65.0,
                                    backgroundImage: NetworkImage('${Config.baseUrlImage}${filteredSites[index]['image']}'),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          " ${filteredSites[index]['name']} ${filteredSites[index]['last_name']}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        SizedBox(height: 5,),
                                        Text(
                                          " ${filteredSites[index]['sp']} ",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            //pass the details to detail page
                            MyApp.navigatorKey.currentState!.push(MaterialPageRoute(
                                builder: (_) => DoctorDetails(
                                  doctor: sites[index],
                                  isFav: false,
                                )));
                          },
                        ),
                      );
                    }),
                  ),
                ),

                Visibility(
                  visible: !isSearchVisible,

                  child: Column(
                    children: List.generate(sites.length, (index) {

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        height: 150,
                        child: GestureDetector(
                          child: Card(
                            elevation: 5,
                            color: Colors.white,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: Config.widthSize * 0.33,

                                  child:           CircleAvatar(
                                    radius: 65.0,
                                    backgroundImage: NetworkImage('${Config.baseUrlImage}${sites[index]['image']}'),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          " ${sites[index]['name']}  ${sites[index]['last_name']}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        SizedBox(height: 5,),
                                        Text(
                                          " ${sites[index]['sp']} ",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        SizedBox(height: 5,),

                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            //pass the details to detail page
                            MyApp.navigatorKey.currentState!.push(MaterialPageRoute(
                                builder: (_) => DoctorDetails(
                                  doctor: sites[index],
                                  isFav: false,
                                )));
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

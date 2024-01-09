import 'dart:convert';

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

import '../main.dart';
import '../providers/dio_provider.dart';
import 'doctor_details.dart';

class DoctorBySp extends StatefulWidget {
  String sp;

   DoctorBySp({required this.sp}) ;


  @override
  State<DoctorBySp> createState() => _DoctorBySpState(sp:sp);
}

class _DoctorBySpState extends State<DoctorBySp> {

  String sp;
  List<dynamic> doctors = [];
  _DoctorBySpState({required this.sp}){
    _initializeData();
      }

  Future<void> _initializeData() async {
    await getDocBySp(sp);
  }


  Future<void> getDocBySp(String sps) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final doc = await DioProvider().getDoctorsBySp(token, sps);
    if (doc != 'Error') {
      setState(() {
        doctors = json.decode(doc);
      });
    }
  }

  List<dynamic> filteredSites = []; // Liste filtrée en fonction de la recherche

  bool isSearchVisible = false; // État pour contrôler la visibilité du champ de recherche

  // Fonction pour effectuer la recherche
  void filterDoctorList(String query) {
    setState(() {
      filteredSites = doctors
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
  //       doctors = json.decode(response.body);
  //       filteredSites = doctors; // Initialisez filteredSites avec la liste complète au début
  //     });
  //   } else {
  //     // Gestion des erreurs
  //     print("Erreur lors du chargement des docteurs depuis l'API");
  //   }
  // }


  @override
  void initState() {
    super.initState();
    // getDocBySp(sp);

    // loadDoctorData();

  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);


    return Scaffold(

      body: doctors.isEmpty
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
                      AppLocalizations.of(context)!.you_can,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      AppLocalizations.of(context)!.ser_by,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage:
                        AssetImage('assets/doctor_1.jpg'),
                      ),
                    )
                  ],
                ),


                Config.spaceSmall,

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        AppLocalizations.of(context)!.take_rdv,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),



                  ),
                ),

                Config.spaceSmall,
                 Text(
                  AppLocalizations.of(context)!.best_dr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Config.spaceSmall,
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: filterDoctorList,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.dr_by_name,
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
                                  // child: Image.network(
                                  //   "http://192.168.43.164:8000${doctor['doctor_profile']}",
                                  //   fit: BoxFit.fill,
                                  // ),

                                  // child: Image.asset('assets/fb.jpeg'),
                                  child:           CircleAvatar(
                                    radius: 65.0,
                                    backgroundImage: NetworkImage('${Config.baseUrlImage}${filteredSites[index]['image']}'),
                                    // backgroundImage: AssetImage('assets/fb.jpeg'),
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
                                          " ${filteredSites[index]['name']}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Text(
                                          "${AppLocalizations.of(context)!.prenom} : ${filteredSites[index]['last_name']}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children:  <Widget>[
                                            Icon(
                                              Icons.star_border,
                                              color: Colors.yellow,
                                              size: 16,
                                            ),
                                            Spacer(
                                              flex: 1,
                                            ),
                                            Text('4.5'),
                                            Spacer(
                                              flex: 1,
                                            ),
                                            Text(AppLocalizations.of(context)!.reviews),
                                            Spacer(
                                              flex: 1,
                                            ),
                                            Text('(20)'),
                                            Spacer(
                                              flex: 7,
                                            ),
                                          ],
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
                                  doctor: filteredSites[index],
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
                    children: List.generate(doctors.length, (index) {
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
                                  // child: Image.network(
                                  //   "http://192.168.43.164:8000${doctor['doctor_profile']}",
                                  //   fit: BoxFit.fill,
                                  // ),

                                  // child: Image.asset('assets/fb.jpeg'),
                                  child:           CircleAvatar(
                                    radius: 65.0,
                                    backgroundImage: NetworkImage('${Config.baseUrlImage}${doctors[index]['image']}'),
                                    // backgroundImage: AssetImage('assets/fb.jpeg'),
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
                                          " ${doctors[index]['name']}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Text(
                                          "${AppLocalizations.of(context)!.prenom} : ${doctors[index]['last_name']}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children:  <Widget>[
                                            Icon(
                                              Icons.star_border,
                                              color: Colors.yellow,
                                              size: 16,
                                            ),
                                            Spacer(
                                              flex: 1,
                                            ),
                                            Text('4.5'),
                                            Spacer(
                                              flex: 1,
                                            ),
                                            Text(AppLocalizations.of(context)!.reviews),
                                            Spacer(
                                              flex: 1,
                                            ),
                                            Text('(20)'),
                                            Spacer(
                                              flex: 7,
                                            ),
                                          ],
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
                                  doctor: doctors[index],
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

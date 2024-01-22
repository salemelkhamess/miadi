import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rdv/bankily/auth-service.dart';
import 'package:rdv/components/button.dart';
import 'package:rdv/components/custom_appbar.dart';
import 'package:rdv/main.dart';
import 'package:rdv/models/booking_datetime_converted.dart';
import 'package:rdv/providers/dio_provider.dart';
import 'package:rdv/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bankily/authentication_manager.dart';
import '../models/auth_model.dart';

class BookingPage extends StatefulWidget {
  BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Map<String, dynamic> user = {};

  bool isLoading = false;
  List<String> paymentMethods = ['Bankily'];
  // List<String> paymentMethods = ['Bankily', 'Masrivi', 'Seddad'];

  // Déclarer une variable pour stocker la méthode de paiement sélectionnée

  String? selectedPaymentMethod;
  String? tokenB;// Modifiez le type de la variable en String nullable

  final _codeController = TextEditingController();
  final _passcodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  AuthenticationManager authManager = AuthenticationManager();

  bool iSLoading = false;

  //declaration
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusDay = DateTime.now();

  DateTime _currentDay = DateTime.now();
  int? _currentIndex;
  bool _isWeekend = true;
  bool _dateSelected = true;
  bool _timeSelected = true;
  String? token; //get token for insert booking date and time into database
  int commission = 0;
  Future<void> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
  }


  String Day = '';


  void _startLoading() {
    setState(() {
      iSLoading = true;
    });

    Timer(Duration(seconds: 5), () {
      setState(() {
        iSLoading = false;
      });
    });
  }

  @override
  void initState() {
    getToken();
    print('init');
    super.initState();

    getCommission();
  }


  Future<dynamic> getCommission() async {
    try {
      var response = await Dio().get('${Config.baseUrl}/commision'
          );

      if (response.statusCode == 200 && response.data != '') {


        print(response.data);
        setState(() {
          commission = response.data;
        });
        return json.encode(response.data);


      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }


  @override
  Widget build(BuildContext context) {
    Config().init(context);

    print('++++++++++++++');
    print('Commision' );
    print(commission);

    final doctor = ModalRoute.of(context)!.settings.arguments as Map;
    user = Provider.of<AuthModel>(context, listen: false).getUser;



    final List<dynamic> horrorList = doctor['id']['horror'];
    // List<String> dayList = horrorList.map<String>((horror) => horror['day']).toList();
    List<String> dayList = horrorList.map<String>((horror) => horror['day']).toList();
    List<String> hour = horrorList.map<String>((horror) => horror['day']).toList();
     int price = int.parse(doctor['id']['price']);
    //int price = doctor['id']['price']+commission;

    int doctor_id = doctor['id']['id'];
     int clinique_id = int.parse(doctor['id']['clinique_id']);
    //int clinique_id = doctor['id']['clinique_id'];


    String selectedDay = dayList.isNotEmpty ? dayList[0] : '';

    String formattedPrice = NumberFormat('#,##0').format(price);

    return Scaffold(
      appBar: CustomAppBar(
        appTitle: AppLocalizations.of(context)!.rdv,
        icon: const FaIcon(Icons.arrow_back_ios),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                 Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.select_day,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                _tableCalendar(),
              // Container(
              //   width:double.infinity,
              //   padding: EdgeInsets.all(10),
              //   child: Card(
              //
              //   elevation: 2,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //     child:Padding(
              //       padding: const EdgeInsets.all(16.0),
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             'Dr. ${doctor['id']["name"]} ${doctor['id']['last_name']}',
              //             style: TextStyle(
              //               fontSize: 18,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //           SizedBox(height: 20),
              //           Text(
              //             'Clinique: ${doctor['id']['clinique']['name']}',
              //             style: TextStyle(
              //               fontSize: 16,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //           SizedBox(height: 20),
              //
              //           Text(
              //             'Selectionner le jour du rendez-vous',
              //             style: TextStyle(
              //               fontSize: 16,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //           SizedBox(height: 20),
              //           Container(
              //             width: double.infinity,
              //             child: DropdownButton<String>(
              //               value: selectedDay,
              //               onChanged: (String? newValue) {
              //                 setState(() {
              //                   Day = newValue!;
              //                 });
              //               },
              //               items: dayList.map<DropdownMenuItem<String>>((String value) {
              //                 return DropdownMenuItem<String>(
              //                   value: value,
              //                   child: Text(value),
              //                 );
              //               }).toList(),
              //             ),
              //           ),
              //
              //         ],
              //       ),
              //     ),
              //   ),
              // ),


              ],
            ),
          ),
          // _isWeekend
              // ? SliverToBoxAdapter(
              //     child: Container(
              //       padding: const EdgeInsets.symmetric(
              //           horizontal: 10, vertical: 30),
              //       alignment: Alignment.center,
              //       child: const Text(
              //         'Le week-end n\'est pas disponible, veuillez sélectionner une autre date',
              //         style: TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.bold,
              //           color: Colors.grey,
              //         ),
              //       ),
              //     ),
              //   )
              // :
          // SliverGrid(
          //         delegate: SliverChildBuilderDelegate(
          //           (context, index) {
          //             return InkWell(
          //               splashColor: Colors.transparent,
          //               onTap: () {
          //                 setState(() {
          //                   _currentIndex = index;
          //                   _timeSelected = true;
          //                 });
          //               },
          //               child: Container(
          //                 margin: const EdgeInsets.all(5),
          //                 decoration: BoxDecoration(
          //                   border: Border.all(
          //                     color: _currentIndex == index
          //                         ? Colors.white
          //                         : Colors.black,
          //                   ),
          //                   borderRadius: BorderRadius.circular(15),
          //                   color: _currentIndex == index
          //                       ? Config.primaryColor
          //                       : null,
          //                 ),
          //                 alignment: Alignment.center,
          //                 child: Text(
          //                   '${index + 8}:00 ${index + 8 > 11 ? "PM" : "AM"}',
          //                   style: TextStyle(
          //                     fontWeight: FontWeight.bold,
          //                     color:
          //                         _currentIndex == index ? Colors.white : null,
          //                   ),
          //                 ),
          //               ),
          //             );
          //           },
          //           childCount: 16,
          //         ),
          //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //             crossAxisCount: 4, childAspectRatio: 1.5),
          //       ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 80),
              child: isLoading ? CircularProgressIndicator()
              :
              Button(
                width: double.infinity,
                title: AppLocalizations.of(context)!.take_rdv,
                onPressed: () async {
                  // setState(() {
                  //   isLoading = true; // Afficher la barre de progression
                  // });

                  // final getDate = DateConverted.getDate(_currentDay);
                  // final getDay = DateConverted.getDay(_currentDay.weekday);
                  // final getTime = DateConverted.getTime(_currentIndex!);

                  // Afficher la boîte de dialogue pour choisir la méthode de paiement
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return AlertDialog(
                                title: Text(AppLocalizations.of(context)!.chose_p_m),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: paymentMethods.map((String method) {
                                    return RadioListTile<String>(
                                      title: Text(method),
                                      value: method,
                                      groupValue: selectedPaymentMethod,
                                      onChanged: (String? value) {
                                        setState(() {
                                          selectedPaymentMethod = value;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () async{
                                      Navigator.of(context).pop(selectedPaymentMethod); // Passez la valeur sélectionnée lors de la fermeture de la boîte de dialogue

                                      if (selectedPaymentMethod=='Bankily') {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Center(
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width ,

                                                child: StatefulBuilder(
                                                  builder: (BuildContext context, StateSetter setState) {
                                                    return AlertDialog(
                                                      // title: Text(AppLocalizations.of(context)!.p_info +'$selectedPaymentMethod'),
                                                      content: Form(
                                                        key: _formKey,
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                                              child: Container(
                                                                  child: Column(
                                                                    children: [
                                                                      Center(
                                                                          child: GestureDetector(
                                                                            onTap: () async {
                                                                              const bankilyUrl = 'bankily://'; // Remplacez par l'URL personnalisée de Bankily
                                                                              if (await canLaunch(bankilyUrl)) {
                                                                                await launch(bankilyUrl);
                                                                              } else {
                                                                                SnackBar(
                                                                                  content: Text(
                                                                                    "Erreur lors de l\'ouverture de Bankily",
                                                                                    // AppLocalizations.of(context)!.copied,
                                                                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                                                                  ),
                                                                                  backgroundColor: Colors.green, // Set the background color of the SnackBar
                                                                                  duration: Duration(seconds: 4), // Set the duration for which the SnackBar is shown
                                                                                  behavior: SnackBarBehavior.floating, // Display the SnackBar with a floating animation
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(20), // Apply rounded corners to the SnackBar
                                                                                  ),
                                                                                );
                                                                              }
                                                                            },
                                                                            child: CircleAvatar(
                                                                              radius: 30.0, // Ajustez la taille du cercle ici
                                                                              backgroundImage: AssetImage("assets/bk.png"),
                                                                            ),
                                                                          ),

                                                                      ),

                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text('${AppLocalizations.of(context)!.tottal_pay}',style: TextStyle(fontSize: 16,color: Colors.black),),
                                                                          Text("${ formattedPrice } MRU",style: TextStyle(
                                                                            color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18
                                                                          ))
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: 5,),

                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text('${AppLocalizations.of(context)!.code_bpay} : 017028',style: TextStyle(fontSize: 18,color: Colors.black),),
                                                                          InkWell(
                                                                              onTap: () async {
                                                                                await Clipboard.setData(ClipboardData(text: "017028"));
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  SnackBar(
                                                                                    content: Text(
                                                                                      AppLocalizations.of(context)!.copied,
                                                                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                                                                    ),
                                                                                    backgroundColor: Colors.green, // Set the background color of the SnackBar
                                                                                    duration: Duration(seconds: 4), // Set the duration for which the SnackBar is shown
                                                                                    behavior: SnackBarBehavior.floating, // Display the SnackBar with a floating animation
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(20), // Apply rounded corners to the SnackBar
                                                                                    ),
                                                                                  ),
                                                                                );                                                                              },
                                                                              child:  Icon(Icons.copy)
                                                                          )
                                                                        ],
                                                                      ),


                                                                    ],
                                                                  )
                                                              ),

                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                                              child: TextFormField(
                                                                controller: _codeController,
                                                                decoration: InputDecoration(
                                                                  border: OutlineInputBorder(),
                                                                  hintText: AppLocalizations.of(context)!.numero_bk,
                                                                ),
                                                                validator: (value) {
                                                                  if (value ==null) {
                                                                    return AppLocalizations.of(context)!.nuber_info;
                                                                  }
                                                                  if (value.length != 8) {
                                                                    return AppLocalizations.of(context)!.nuber_error;
                                                                  }
                                                                  return null; // Retourner null si la validation réussit
                                                                },

                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:  EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                                              child: TextFormField(
                                                                controller: _passcodeController,
                                                                decoration: InputDecoration(
                                                                  border: OutlineInputBorder(),
                                                                  hintText: AppLocalizations.of(context)!.passCode,
                                                                ),
                                                                validator: (value) {
                                                                  if (value==null) {
                                                                    return AppLocalizations.of(context)!.passCodeinfo;
                                                                  }
                                                                  if (value.length != 4 ) {
                                                                    return AppLocalizations.of(context)!.passeCodeError;
                                                                  }
                                                                  return null; // Retourner null si la validation réussit
                                                                },

                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(context).size.width,
                                                              color: Colors.green ,
                                                              padding: EdgeInsets.all(20),

                                                              child: Center(
                                                                child: InkWell(

                                                                  onTap: () async{
                                                                    // Navigator.of(context).pop(selectedPaymentMethod); // Passez la valeur sélectionnée lors de la fermeture de la boîte de dialogue
                                                                    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                                                                      setState(() {
                                                                        iSLoading = true; // Activer la barre de progression
                                                                      });

                                                                      final phone = _codeController.text;
                                                                      final pass = _passcodeController.text;

                                                                      try {

                                                                        if (authManager.accessToken == null || authManager.isAccessTokenExpired()) {
                                                                          print("Apple de la fonction auth .");
                                                                          print("Toekn initialiser ... .");

                                                                          await authManager.performAuthentication();
                                                                        }

                                                                        if (authManager.accessToken != null && !authManager.isAccessTokenExpired()) {

                                                                          Map<String, dynamic> responseData = await AuthPageBankily.makePayment(
                                                                            '${authManager.accessToken}',
                                                                            phone,
                                                                            pass,
                                                                            '$price',
                                                                            'FR',
                                                                          );
                                                                          // Traitez la réponse de la transaction ici.
                                                                          print('++++++++++++++++++++++++++++++++');
                                                                          print(responseData);
                                                                          print(responseData['errorCode']);

                                                                          if (responseData['errorCode']==0) {
                                                                            final getDate = DateConverted.getDate(_currentDay);
                                                                            // final getDay = Day;
                                                                            final getDay = DateConverted.getDay(_currentDay.weekday);

                                                                            const getTime = '';
                                                                            final booking = await DioProvider().bookAppointment(
                                                                                getDate, getDay, getTime, doctor['id']['id'], token!);
                                                                            //if booking return status code 200, then redirect to success booking page
                                                                            if (booking == 200) {

                                                                              setState(() {
                                                                                isLoading = false;
                                                                              });
                                                                              MyApp.navigatorKey.currentState!
                                                                                  .pushNamed('success_booking');
                                                                              await DioProvider().createPayment(user['id'], clinique_id, doctor_id, price, getDate);


                                                                            }else{
                                                                              setState(() {
                                                                                iSLoading = true;
                                                                              });
                                                                              Fluttertoast.showToast(
                                                                                  msg: " Erreur Veuillez selectionner le jour du rendez-vous svp !",
                                                                                  toastLength: Toast.LENGTH_SHORT,
                                                                                  gravity: ToastGravity.BOTTOM_RIGHT,
                                                                                  timeInSecForIosWeb: 1,
                                                                                  backgroundColor: Colors.orange,
                                                                                  textColor: Colors.white,
                                                                                  fontSize: 16.0
                                                                              );
                                                                            }
                                                                          }else{
                                                                            // print('++++++++++++++++++++++++++++++++');
                                                                            // print(responseData);
                                                                            // print(responseData['errorCode']);


                                                                            if(responseData['errorCode']==1){
                                                                              Fluttertoast.showToast(
                                                                                  msg: "Les details du retrait specifies ne correspondent pas aux details presents dans le systeme",
                                                                                  toastLength: Toast.LENGTH_SHORT,
                                                                                  gravity: ToastGravity.BOTTOM_RIGHT,
                                                                                  timeInSecForIosWeb: 1,
                                                                                  backgroundColor: Colors.orange,
                                                                                  textColor: Colors.white,
                                                                                  fontSize: 16.0
                                                                              );
                                                                            }
                                                                            setState(() {
                                                                              iSLoading = false; // Désactiver la barre de progression en cas d'erreur
                                                                            });
                                                                          }


                                                                        } else {
                                                                          print('Authentication failed or access token expired.');
                                                                        }


                                                                      } catch (e) {
                                                                        setState(() {
                                                                          iSLoading = false; // Désactiver la barre de progression en cas d'erreur
                                                                        });
                                                                        print('Error: $e');
                                                                      }finally {
                                                                        // Désactiver la barre de progression après un court délai
                                                                        await Future.delayed(Duration(milliseconds: 300));
                                                                        setState(() {
                                                                          iSLoading = false;
                                                                        });
                                                                      }
                                                                    }

                                                                    final code = _codeController.text;
                                                                    final mont = _passcodeController.text;

                                                                  },
                                                                  child:iSLoading // Afficher le bouton ou la barre de progression en fonction de isLoading
                                                                      ? CircularProgressIndicator() // Afficher la barre de progression
                                                                      : Text(AppLocalizations.of(context)!.confirmer), // Afficher le texte du bouton
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [

                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }

                                      if (selectedPaymentMethod=='Masrivi') {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Center(
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width ,
                                                child: StatefulBuilder(
                                                  builder: (BuildContext context, StateSetter setState) {
                                                    return AlertDialog(
                                                      title: Text('Les information de paiement avec $selectedPaymentMethod'),
                                                      content: Form(
                                                        key: _formKey,
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                                              child: Container(
                                                                  child: Column(
                                                                    children: [
                                                                      Text('Total à payer ${price} MRU'),
                                                                      Text('View Masrivi'),
                                                                    ],
                                                                  )
                                                              ),

                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                                                              child: TextFormField(
                                                                controller: _codeController,
                                                                decoration: InputDecoration(
                                                                  border: OutlineInputBorder(),
                                                                  hintText: 'Votre numero Bankily',
                                                                ),
                                                                validator: (value) {
                                                                  if (value ==null) {
                                                                    return 'Veuillez entrer vorte numero bankily';
                                                                  }
                                                                  if (value.length != 8) {
                                                                    return 'Le numero doit avoir 8 chiffre';
                                                                  }
                                                                  return null; // Retourner null si la validation réussit
                                                                },

                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:  EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                                                              child: TextFormField(
                                                                controller: _passcodeController,
                                                                decoration: InputDecoration(
                                                                  border: OutlineInputBorder(),
                                                                  hintText: 'Entrer le passcode de paiement ',
                                                                ),
                                                                validator: (value) {
                                                                  if (value==null) {
                                                                    return 'Veillez entrer le passcode de paiement !';
                                                                  }
                                                                  if (value.length != 4 ) {
                                                                    return 'Le passcode doit etre 4 chiffre';
                                                                  }
                                                                  return null; // Retourner null si la validation réussit
                                                                },

                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () async{
                                                                // Navigator.of(context).pop(selectedPaymentMethod); // Passez la valeur sélectionnée lors de la fermeture de la boîte de dialogue

                                                                if (_formKey.currentState != null && _formKey.currentState!.validate()) {

                                                                  final phone = _codeController.text;
                                                                  final pass = _passcodeController.text;

                                                                  try {
                                                                    // String tokebB = await AuthPageBankily.performAuthentication() ;

                                                                    // Map<String, dynamic> responseData = await AuthPageBankily.makePayment(
                                                                    //   tokebB,
                                                                    //   phone,
                                                                    //   pass,
                                                                    //   '${price}',
                                                                    //   'FR',
                                                                    // );
                                                                    // // Traitez la réponse de la transaction ici.
                                                                    //
                                                                    // print(responseData['errorCode']);
                                                                    // if (responseData['errorCode']==0) {
                                                                    //   final getDate = DateConverted.getDate(_currentDay);
                                                                    //   // final getDay = Day;
                                                                    //   final getDay = DateConverted.getDay(_currentDay.weekday);
                                                                    //   const getTime = '';
                                                                    //   final booking = await DioProvider().bookAppointment(
                                                                    //       getDate, getDay, getTime, doctor['id']['id'], token!);
                                                                    //   //if booking return status code 200, then redirect to success booking page
                                                                    //   if (booking == 200) {
                                                                    //     setState(() {
                                                                    //       isLoading = false;
                                                                    //     });
                                                                    //     MyApp.navigatorKey.currentState!
                                                                    //         .pushNamed('success_booking');
                                                                    //   }else{
                                                                    //
                                                                    //     setState(() {
                                                                    //       isLoading = true;
                                                                    //     });
                                                                    //     Fluttertoast.showToast(
                                                                    //         msg: " Erreur Veuillez selectionner le jour du rendez-vous svp !",
                                                                    //         toastLength: Toast.LENGTH_SHORT,
                                                                    //         gravity: ToastGravity.BOTTOM_RIGHT,
                                                                    //         timeInSecForIosWeb: 1,
                                                                    //         backgroundColor: Colors.orange,
                                                                    //         textColor: Colors.white,
                                                                    //         fontSize: 16.0
                                                                    //     );
                                                                    //   }
                                                                    // }else{
                                                                    //   Fluttertoast.showToast(
                                                                    //       msg: " Le code code B-PAY est  : 017028 et le  montant que vous devez paye est ${price} MRU",
                                                                    //       toastLength: Toast.LENGTH_SHORT,
                                                                    //       gravity: ToastGravity.BOTTOM_RIGHT,
                                                                    //       timeInSecForIosWeb: 1,
                                                                    //       backgroundColor: Colors.orange,
                                                                    //       textColor: Colors.white,
                                                                    //       fontSize: 16.0
                                                                    //   );
                                                                    // }

                                                                  } catch (e) {
                                                                    print('Error: $e');
                                                                  }

                                                                }
                                                                                                                                final code = _codeController.text;
                                                                final mont = _passcodeController.text;

                                                              },
                                                              child: Text('Confirmer'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [

                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }

                                    },
                                    child: Text(AppLocalizations.of(context)!.suivants),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ).then((selectedMethod) {
                    if (selectedMethod != null) {
                      setState(() {
                        print('Selected method: $selectedMethod');
                      });
                      // Utilisez la valeur de selectedMethod ici
                    } else {
                      print('Aucune méthode sélectionnée');
                    }
                  });
                },
                disable: _timeSelected && _dateSelected ? false : true,
              ),

            ),
          ),
        ],
      ),
    );
  }

  //table calendar
  Widget _tableCalendar() {
    return TableCalendar(
      locale: 'fr_FR',
      focusedDay: _focusDay,
      firstDay: DateTime.now(),
      lastDay: DateTime(2024, 12, 31),
      calendarFormat: _format,
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: const CalendarStyle(
        todayDecoration:
            BoxDecoration(color: Config.primaryColor, shape: BoxShape.circle),
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
      onDaySelected: ((selectedDay, focusedDay) {
        setState(() {
          _currentDay = selectedDay;
          _focusDay = focusedDay;
          _dateSelected = true;

          //check if weekend is selected
          if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
            _isWeekend = true;
            _timeSelected = false;
            _currentIndex = null;
          } else {
            _isWeekend = false;
          }
        });
      }),
    );
  }
}

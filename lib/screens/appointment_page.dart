import 'package:rdv/models/appointment.dart';
import 'package:rdv/providers/dio_provider.dart';
import 'package:rdv/screens/today_app.dart';
import 'package:rdv/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rdv/models/appointment.dart';

import '../models/clinique.dart';
import '../models/doctor.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

//enum for appointment status
enum FilterStatus { Tout }

class _AppointmentPageState extends State<AppointmentPage> {
  FilterStatus status = FilterStatus.Tout; //initial status
  Alignment _alignment = Alignment.centerLeft;
  List<dynamic> schedules = [];

  List<Appointment> todayApp = [];


  //get appointments details
  Future<void> getAppointments() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final appointment = await DioProvider().getAppointments(token);
    if (appointment != 'Error') {
      setState(() {
        schedules = json.decode(appointment);
      });
    }
  }


  Future<void> getTodayAppointments() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final tappointment = await DioProvider().getTodayApp(token);

    // Convertir les données en une liste d'objets Appointment
    final List<dynamic> decodedData = json.decode(tappointment);
    final List<Appointment> appointments = decodedData.map((data) {
      // Créer une instance de la classe Appointment en utilisant les données JSON
      return Appointment(
        id: data['id'],
        doctorId: data['doctor_id'],
        day: data['day'],
        app_number: data['app_number'],
        date: data['date'],
        status: data['status'],
        doctor: Doctor(
          id: data['doctor']['id'],
          name: data['doctor']['name'],
          lastName: data['doctor']['last_name'], sp:  data['doctor']['sp'], desc:  data['doctor']['desc'], image:  data['doctor']['image'],
          // Ajouter d'autres champs du médecin ici
        ),
        clinique: Clinique(
          id: data['clinique']['id'],
          name: data['clinique']['name'],
          address: data['clinique']['address'], image: data['clinique']['image'],
          // Ajouter d'autres champs de la clinique ici
        ),
        // Ajouter d'autres champs de l'appointment ici
      );
    }).toList();

    setState(() {
      todayApp = appointments;
    });
  }


  Future<void> generateReceiptPdf() async {
    final pdf = pw.Document();

    // Add the receipt content to the PDF document
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Center(
            child: pw.Text('Receipt PDF Content'),
          );
        },
      ),
    );

    // Save the PDF file locally
    final outputDir = await path_provider.getTemporaryDirectory();
    final outputFile = File('${outputDir.path}/receipt.pdf');
    final pdfBytes = await pdf.save();
    await outputFile.writeAsBytes(pdfBytes.toList());

    // Download the PDF file to the phone
    final taskId = await FlutterDownloader.enqueue(
      url: outputFile.path,
      savedDir: outputDir.path,
      fileName: 'receipt.pdf',
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  @override
  void initState() {
    getAppointments();
    super.initState();
    getTodayAppointments();
  }

  @override
  Widget build(BuildContext context) {


    List<dynamic> filteredSchedules = schedules.where((var schedule) {
      switch (schedule['status']) {
        case 'prochain':
          schedule['status'] = FilterStatus.Tout;

      }
      return schedule['status'] == status;
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
             Text(
              AppLocalizations.of(context)!.history_rdv,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Config.spaceSmall,
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:Text(""),
                ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedAlign(
                    alignment: _alignment,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 170,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Config.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.all_rdv,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedAlign(
                    alignment: _alignment,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 150,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Config.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: InkWell(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>  AppointmentsScreen(appointments:todayApp )),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.today,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              )


               
              ],
            ),
            Config.spaceSmall,

            schedules.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                itemCount: filteredSchedules.length,
                itemBuilder: ((context, index) {
                  var schedule = filteredSchedules[index];
                  bool isLastElement = filteredSchedules.length + 1 == index;
                  return

                    Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: !isLastElement
                        ? const EdgeInsets.only(bottom: 20)
                        : EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                // backgroundImage: AssetImage('assets/fb.jpeg'),
                                backgroundImage: NetworkImage(
                                    "${Config.baseUrlImage}${schedule['doctor']['image']}"),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    '${schedule['doctor']['name']}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Dr. ${schedule['doctor']['last_name']}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Container(
                          //   width: 100,
                          //   height: 40,
                          //   decoration: BoxDecoration(
                          //     color: Colors.grey[300],
                          //     borderRadius: BorderRadius.circular(10),
                          //   ),
                          //
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //
                          //       Text(
                          //         'Numero du rendez-vous',
                          //         style: const TextStyle(
                          //           color: Config.primaryColor,
                          //           fontSize: 18,
                          //           fontWeight: FontWeight.w600,
                          //         ),
                          //       ),
                          //       SizedBox(width: 12,),
                          //       Text(
                          //         '${schedule['app_number']}',
                          //         style: const TextStyle(
                          //           color: Colors.black,
                          //           fontSize: 18,
                          //           fontWeight: FontWeight.w600,
                          //         ),
                          //       ),
                          //
                          //     ],
                          //   ),
                          // ),
                          const SizedBox(
                            height: 15,
                          ),

                          Center(child: Text(AppLocalizations.of(context)!.rdv_info,style: TextStyle(
                            fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black
                          ),)),
                          const SizedBox(
                            height: 15,
                          ),
                          ScheduleCard(

                            day: schedule['day'],
                            date: schedule['date'],
                            time: '${schedule['app_number']}',
                          ),
                          const SizedBox(
                            height: 15,
                          ),


                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              // Expanded(
                              //   child: OutlinedButton(
                              //     style: OutlinedButton.styleFrom(
                              //       backgroundColor: Config.primaryColor,
                              //     ),
                              //     onPressed: () {},
                              //     child: const Text(
                              //       'Reprogrammer',
                              //       style: TextStyle(color: Colors.white),
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(
                              //   width: 20,
                              // ),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    generateReceiptPdf();
                                  },
                                  child:  Text(
                                    AppLocalizations.of(context)!.gererate_pdf,
                                    style:
                                    TextStyle(color: Config.primaryColor),
                                  ),
                                ),
                              ),


                            ],
                          ),

                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              // Expanded(
                              //   child: OutlinedButton(
                              //     style: OutlinedButton.styleFrom(
                              //       backgroundColor: Config.primaryColor,
                              //     ),
                              //     onPressed: () {},
                              //     child: const Text(
                              //       'Reprogrammer',
                              //       style: TextStyle(color: Colors.white),
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(
                              //   width: 20,
                              // ),


                              // Expanded(
                              //   child: OutlinedButton(
                              //     onPressed: () {},
                              //     child:  Text(
                              //       AppLocalizations.of(context)!.annuler,
                              //       style:
                              //       TextStyle(color: Colors.orangeAccent),
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(
                              //   width: 20,
                              // ),
                              // Expanded(
                              //   child: OutlinedButton(
                              //     onPressed: () {},
                              //     child: const Text(
                              //       'Annuler',
                              //       style:
                              //       TextStyle(color: Config.primaryColor),
                              //     ),
                              //   ),
                              // ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  )

                  ;
                }),
              ),
            )
           : CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard(
      {Key? key, required this.date, required this.day, required this.time})
      : super(key: key);
  final String date;
  final String day;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            ' $day',
            style: const TextStyle(
              color: Config.primaryColor,
            ),
          ),
          const SizedBox(
            width: 5,
          ),

          Text(
            '${AppLocalizations.of(context)!.le} $date',
            style: const TextStyle(
              color: Config.primaryColor,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          // const Icon(
          //   Icons.access_alarm,
          //   color: Config.primaryColor,
          //   size: 17,
          // ),
          const SizedBox(
            width: 5,
          ),
          Flexible(
              child: Text(
            '${AppLocalizations.of(context)!.nbr} $time',
            style: const TextStyle(
              color: Config.primaryColor,
            ),
          ))
        ],
      ),
    );
  }
}

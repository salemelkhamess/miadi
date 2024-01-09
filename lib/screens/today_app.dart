import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:path_provider/path_provider.dart';
import '../models/appointment.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppointmentsScreen extends StatelessWidget {
  final List<Appointment> appointments;

  AppointmentsScreen({required this.appointments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.today_rdv),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return AppointmentCard(appointment: appointments[index]);
        },
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  AppointmentCard({required this.appointment});

  Future<void> generatePDF() async {
    final pdf = pdfWidgets.Document();
    final appDocDir = await getExternalStorageDirectory(); // Obtenir le répertoire de stockage externe
    print('++++++++++++++++++++++++');
    print(appDocDir);
    final pdfPath = '${appDocDir!.path}/MyApp'; // Chemin du dossier de l'application
    print(pdfPath);

    final directory = Directory(pdfPath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true); // Créer le dossier si nécessaire
    }

    final file = File('$pdfPath/appointment.pdf'); // Chemin complet du fichier PDF

    pdf.addPage(
      pdfWidgets.Page(
        build: (context) => pdfWidgets.Column(
          children: [
            pdfWidgets.Text("Appointment Details", style: pdfWidgets.TextStyle(fontSize: 20, fontWeight: pdfWidgets.FontWeight.bold)),
            pdfWidgets.SizedBox(height: 20),
            pdfWidgets.Text("Day: ${appointment.day}"),
            pdfWidgets.Text("Date: ${appointment.date}"),
            pdfWidgets.Text("Doctor: ${appointment.doctor.name} ${appointment.doctor.lastName}"),
            pdfWidgets.Text("Specialty: ${appointment.doctor.sp}"),
            pdfWidgets.Text("Clinic: ${appointment.clinique.name}"),
            pdfWidgets.Text("Clinic Address: ${appointment.clinique.address}"),
          ],
        ),
      ),
    );

    await file.writeAsBytes(await pdf.save());
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(
         "${AppLocalizations.of(context)!.jour} : ${ appointment.day}",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 12),
            Text(
              "${AppLocalizations.of(context)!.rdv_number}: ${appointment.app_number}",
              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green,fontFamily: '',fontSize: 20),
            ),

            SizedBox(height: 12),
            Text(
              "${AppLocalizations.of(context)!.date}: ${appointment.date}",
              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green,fontFamily: '',fontSize: 14),
            ),
            SizedBox(height: 20),
            Text(
              "${AppLocalizations.of(context)!.clinique}: ${appointment.clinique.name}",
              style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),
            Text(
              "${AppLocalizations.of(context)!.docteur}: ${appointment.doctor.name} ${appointment.doctor.lastName}",
              style: TextStyle(fontSize: 18,fontFamily: '',fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              "${AppLocalizations.of(context)!.specialty}: ${appointment.doctor.sp}",
              style: TextStyle(fontSize: 14),
            ),


          ],
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            await generatePDF();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context)!.pdf_saved),
            ));
          },
          child: Text(AppLocalizations.of(context)!.pdf_gen),
        ),
      ),
    );
  }
}

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rdv/models/contact.dart';
import 'package:rdv/utils/config.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/custom_appbar.dart';

class ContactUsApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context);

    return MaterialApp(
      title: 'Contact Us',
      home: ContactUsPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green, // Change the primary color here
      ),
    );
  }
}

class ContactUsPage extends StatefulWidget {

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  static const colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  Future<List<Contact>> fetchContact() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/contact'));

    if (response.statusCode == 200) {
      Iterable jsonResponse = json.decode(response.body);
      return List<Contact>.from(jsonResponse.map((model) => Contact.fromJson(model)));
    } else {
      throw Exception('Failed to load patients');
    }
  }

  @override
  void initState() {
    fetchContact();
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // If the URL doesn't have a scheme, try adding 'https://' and try again
      final completeUrl = 'https://$url';

      if (await canLaunch(completeUrl)) {
        await launch(completeUrl);
      } else {
        throw 'Could not launch $url';
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        appTitle:'Contactez-nous',


      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:FutureBuilder<List<Contact>>(
          future: fetchContact(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  final patient = snapshot.data![index];

                  return Column(
                    children: [

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
                                    'Contactez-nous ',
                                    textStyle: TextStyle(
                                        fontSize: 22
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

                      Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.phone),
                          title: Text(
                            'Téléphone 1',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(patient.phone1),
                        ),
                      ),
                      Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.phone),
                          title: Text(
                            'Téléphone 2',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(patient.phone2),
                        ),
                      ),
                      InkWell(
                        onTap: () => _launchURL('${patient.fb}'), // Update the URL here
                        child: Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.facebook),
                            title: Text(
                              'Facebook',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(patient.fb),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _launchURL('${patient.wh}'), // Update the URL here

                        child: Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.whatshot),
                            title: Text(
                              'Whatsapp',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(patient.wh),
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () => _launchURL('${patient.sn}'), // Update the URL here

                        child: Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.snapchat),
                            title: Text(
                              'Snap chat',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(patient.fb),
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () => _launchURL('${patient.email}'), // Update the URL here

                        child: Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.email),
                            title: Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(patient.fb),
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () => _launchURL('${patient.ins}'), // Update the URL here

                        child: Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.phone),
                            title: Text(
                              'Instagrame',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(patient.fb),
                          ),
                        ),
                      ),

                    ],
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
            },
        ),
      ),
    );
  }
}

class ContactInfoField extends StatelessWidget {
  final String label;
  final String value;




  const ContactInfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {

    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(Icons.content_copy),
          onPressed: () {
            // Ajoutez ici la logique pour copier la valeur dans le presse-papiers
            // (par exemple, utilisez le package clipboard_manager)
          },
        ),
      ),
      controller: TextEditingController(text: value),
    );
  }
}

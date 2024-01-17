import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ContactUsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context);

    return MaterialApp(
      title: appLocalization?.contact_us ?? 'Contact Us',
      home: ContactUsPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green, // Change the primary color here
      ),
    );
  }
}

class ContactUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text( appLocalization?.contact_us ?? 'Contact Us',),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appLocalization?.contact_us ?? 'Contact Us',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            ContactInfoField(
              label: 'Numéro de téléphone',
              value: '+22232441802',
            ),
            ContactInfoField(
              label: 'E-mail',
              value: 'contact@rimdevtools.com',
            ),
            ContactInfoField(
              label: 'Facebook',
              value: 'facebook.com/miadi',
            ),
            ContactInfoField(
              label: 'Instagram',
              value: 'instagram.com/miadi',
            ),
            ContactInfoField(
              label: 'Snapchat',
              value: 'snapchat.com/add/miadi',
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Ajoutez ici la logique pour envoyer le message
                // (par exemple, une requête HTTP, un envoi de courrier électronique, etc.)
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Message envoyé'),
                      content: Text('Nous vous répondrons bientôt.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Fermer'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Envoyer'),
            ),
          ],
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

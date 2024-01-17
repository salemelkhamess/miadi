import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class YourContentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Your App Content Goes Here',
        style: TextStyle(fontSize: 18.0),
      ),
    );
  }
}

class WhatsAppFloatingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        launchWhatsApp();
      },
      child: Icon(Icons.chat),
    );
  }

  void launchWhatsApp() async {
    final phoneNumber = '+22232441802'; // Replace with the phone number you want to message
    final message = 'Hello from Flutter!'; // Replace with your message

    final whatsappUrl = "whatsapp://send?phone=$phoneNumber&text=$message";

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      print('Could not launch $whatsappUrl');
    }
  }
}
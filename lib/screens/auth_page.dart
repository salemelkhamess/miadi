import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:rdv/components/login_form.dart';
import 'package:rdv/components/sign_up_form.dart';
import 'package:rdv/components/social_button.dart';
import 'package:rdv/models/auth_model.dart';
import 'package:rdv/screens/home_page.dart';
import 'package:rdv/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../providers/dio_provider.dart';
import '../utils/config.dart';
import 'auth_manager.dart';
import 'package:http/http.dart' as http;

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isSignIn = true;

  @override
  void initState() {
    super.initState();
    // check();
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
          Navigator.pushReplacementNamed(context, 'main', arguments: data);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    //build login text field
    return Scaffold(
        body:
           Padding(
           padding: const EdgeInsets.symmetric(
          // horizontal: 15,
          // vertical: 15,
      ),
      child: SafeArea(

          child: ListView(
            scrollDirection: Axis.vertical,

            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Text(
              //   AppText.enText['welcome_text']!,
              //   style: const TextStyle(
              //     fontSize: 36,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // // SizedBox(height: 10,),
              // Config.spaceSmall,

          Container(
                  // padding: EdgeInsets.only(top: 20),
                  width: MediaQuery.of(context).size.width,
                  height: 450,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        spreadRadius: 7,
                        color: Colors.white54
                      )
                    ]
                  ),
                  child: Image.asset('assets/2.jpeg',fit: BoxFit.cover,),
                  // child: CachedNetworkImage(
                  //   imageUrl: '${Config.urlImage}/2.jpeg',
                  //   placeholder: (context, url) => CircularProgressIndicator(),
                  //   errorWidget: (context, url, error) => Icon(Icons.error),
                  //   fit: BoxFit.cover,
                  // ),
                ),

              // Config.spaceSmall,

              Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,

                decoration: BoxDecoration(
                  color: Colors.white, // Couleur de fond du conteneur
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      isSignIn
                          ? AppText.enText['signIn_text']!
                          : AppText.enText['register_text']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Couleur du texte
                      ),
                    ),
                    Config.spaceSmall,
                    isSignIn ? LoginForm() : SignUpForm(),
                    Config.spaceSmall,
                    isSignIn
                        ? Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          AppText.enText['forgot-password']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54, // Couleur du texte du bouton
                          ),
                        ),
                      ),
                    )
                        : Container(),
                    Config.spaceSmall,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          isSignIn
                              ? AppText.enText['signUp_text']!
                              : AppText.enText['registered_text']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade500, // Couleur du texte
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isSignIn = !isSignIn;
                            });
                          },
                          child: Text(
                            isSignIn ? 'S\'inscrire' : 'Se Connecter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              // Couleur du texte du bouton
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )

            ],
          ),
      ),
    ),

    );
  }
}
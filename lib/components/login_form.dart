import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:rdv/components/button.dart';
import 'package:rdv/main.dart';
import 'package:rdv/models/auth_model.dart';
import 'package:rdv/providers/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/config.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool obsecurePass = true;
  bool isLoading = false;

  String title ='Se connecter';
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.phone,
              cursorColor: Colors.black54,
              decoration: const InputDecoration(
                hintText: 'Numéro téléphone ',
                labelText: 'Numéro téléphone ',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.phone),
                prefixIconColor: Colors.black54,

              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le Champ numéro téléphone  est obligatoire !';
                }
                return null; // Retourner null si la validation réussit
              },
            ),
            Config.spaceSmall,
            // SizedBox(height: 10,),
            TextFormField(
              controller: _passController,
              keyboardType: TextInputType.visiblePassword,
              cursorColor: Colors.black54,
              obscureText: obsecurePass,
              decoration: InputDecoration(
                  hintText: 'Password',
                  labelText: 'Password',
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  prefixIconColor: Colors.black54,
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obsecurePass = !obsecurePass;
                        });
                      },
                      icon: obsecurePass
                          ? const Icon(
                              Icons.visibility_off_outlined,
                              color: Colors.black38,
                            )
                          : const Icon(
                              Icons.visibility_outlined,
                              color: Colors.black54,
                            ))),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le Champ Mot de pass est obligatoire !';
                }

                return null; // Retourner null si la validation réussit
              },
            ),
            Config.spaceSmall,
            Consumer<AuthModel>(
              builder: (context, auth, child) {
                return isLoading
                    ? CircularProgressIndicator()
                    : Button(
                  width: double.infinity,
                  title: title,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      //login here
                      final token = await DioProvider().getToken(
                        _emailController.text,
                        _passController.text,
                      );

                      if (token) {
                        setState(() {
                          isLoading = true; // Afficher la barre de progression
                        });

                        //grab user data here
                        final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                        final tokenValue = prefs.getString('token') ?? '';

                        if (tokenValue.isNotEmpty && tokenValue != '') {
                          //get user data
                          final response =
                          await DioProvider().getSites(tokenValue);
                          final cartiers =
                          await DioProvider().getCartiers(tokenValue);
                          final users = await DioProvider().getUser(tokenValue);

                          // print(response);
                          if (response != null) {
                            setState(() {
                              //json decode
                              isLoading = false; // Masquer la barre de progression

                              // final  appointment = json.decode(appts);

                              final site = json.decode(response);
                              final cartier = json.decode(cartiers);
                              final user = json.decode(users);

                              auth.loginSuccess(site, cartier, user);
                              MyApp.navigatorKey.currentState!
                                  .pushReplacementNamed('main');
                            });
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      } else {
                        Fluttertoast.showToast(
                          msg: "Erreur numéro téléphone ou mot de passe",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM_RIGHT,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.orange,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    }
                  },
                  disable: false,

                );
              },
            ),

          ],
        ),
      ),
    );
  }
}

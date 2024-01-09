import 'package:fluttertoast/fluttertoast.dart';
import 'package:rdv/components/button.dart';
import 'package:rdv/main.dart';
import 'package:rdv/models/auth_model.dart';
import 'package:rdv/providers/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/config.dart';

class SignUpForm extends StatefulWidget {
  SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _ageController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool obsecurePass = true;
  bool isLoading=false;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.text,
            cursorColor: Colors.black54,
            decoration: const InputDecoration(
              hintText: 'Username',
              labelText: 'Username',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.person_outlined),
              prefixIconColor: Colors.black54,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le champ Nom d\'utilisateur est obligatoire !';
              }
              return null;
            },
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _lastnameController,
            keyboardType: TextInputType.text,
            cursorColor: Colors.black54,
            decoration: const InputDecoration(
              hintText: 'Prenom',
              labelText: 'Prenom',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.person_outlined),
              prefixIconColor: Colors.black54,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le champ Prénom est obligatoire !';
              }
              return null;
            },
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.text,
            cursorColor: Colors.black54,
            decoration: const InputDecoration(
              hintText: 'Age',
              labelText: 'Age',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.supervised_user_circle_sharp),
              prefixIconColor: Colors.black54,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le champ Age est obligatoire !';
              }
              return null;
            },
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _mobileController,
            keyboardType: TextInputType.text,
            cursorColor: Colors.black54,
            decoration: const InputDecoration(
              hintText: 'Téléphone',
              labelText: 'Téléphone',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.phone),
              prefixIconColor: Colors.black54,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le champ Téléphone est obligatoire !';
              }
              return null;
            },
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _addressController,
            keyboardType: TextInputType.text,
            cursorColor: Colors.black54,
            decoration: const InputDecoration(
              hintText: 'Address',
              labelText: 'Address',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.home),
              prefixIconColor: Colors.black54,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le champ Adresse est obligatoire !';
              }
              return null;
            },
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Colors.black54,
            decoration: const InputDecoration(
              hintText: 'Email ',
              labelText: 'Email',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.email_outlined),
              prefixIconColor: Colors.black54,
            ),
/*            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le champ Email est obligatoire !';
              }
              return null;
            },*/
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _passController,
            keyboardType: TextInputType.visiblePassword,
            cursorColor:Colors.black54,
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
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le champ Mot de passe est obligatoire !';
              }
              return null;
            },
          ),
          Config.spaceSmall,
          Consumer<AuthModel>(
            builder: (context, auth, child) {
              return isLoading
                  ? CircularProgressIndicator()
                  : Button(
                width: double.infinity,
                title: isLoading ? 'Chargement....' : 'S\'inscrire',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true; // Afficher la barre de progression
                    });
                    final userRegistration =
                    await DioProvider().registerUser(
                      _nameController.text,
                      _emailController.text,
                      _passController.text,
                      _ageController.text,
                      _mobileController.text,
                      _addressController.text,
                      _lastnameController.text,
                    );

                    //if register success, proceed to login
                    if (userRegistration) {
                      final token = await DioProvider().getToken(
                          _mobileController.text, _passController.text);

                      print("++++++++++++++++++");
                      print(token);

                      if (token) {
                        isLoading = false;
                        auth.loginSuccess([], [], {}); //update login status
                        //rediret to main page
                        MyApp.navigatorKey.currentState!.pushNamed('/');
                      }else{
                        Fluttertoast.showToast(
                          msg: "Numero telephone deja existe ",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM_RIGHT,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.orange,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    } else {
                      print('register not successful');
                    }
                  }
                },
                disable: false,
              );
            },
          )
        ],
      ),
    );

  }
}

//now, let's get all doctor details and display on Mobile screen
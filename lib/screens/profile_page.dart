import "package:rdv/main.dart";
import "package:rdv/screens/settings.dart";
import "package:rdv/utils/config.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import "../models/auth_model.dart";
import "../providers/dio_provider.dart";
import 'package:provider/provider.dart';

import "contact.dart";

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Map<String, dynamic> user = {};

  bool isLoading = false;


  @override
    void initState() {
      super.initState();
    }


  @override
  Widget build(BuildContext context) {
    Config().init(context);
    user = Provider.of<AuthModel>(context, listen: false).getUser;
    // print("**************");
    // print(user);

    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            color: Config.primaryColor,
            child: Column(
              children:  <Widget>[
                SizedBox(
                  height: 80,
                ),
                CircleAvatar(
                  radius: 65.0,
                  backgroundImage: AssetImage('assets/user.jpeg'),
                  backgroundColor: Colors.white,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "${user['name']}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "${user['email']}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.grey[200],
            child: Center(
              child: Card(
                margin: const EdgeInsets.fromLTRB(0, 45, 0, 0),
                child: Container(
                  width: 300,
                  height: 270,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                         Text(
                          AppLocalizations.of(context)!.profile,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Divider(
                          color: Colors.grey[300],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.blueAccent[400],
                              size: 35,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            TextButton(
                              onPressed: () {
                         /*       Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>  SettingsPage()),
                                );*/
                              },
                              child:  Text(
                                AppLocalizations.of(context)!.profile,
                                style: TextStyle(
                                  color: Config.primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Config.spaceSmall,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.phone,
                              color: Colors.yellowAccent[400],
                              size: 35,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, 'contact');

                                    /*        Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>  ContactUsApp()),
                                );*/
                              },
                              child:  Text(
                                AppLocalizations.of(context)!.contact,
                                style: TextStyle(
                                  color: Config.primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Config.spaceSmall,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.logout_outlined,
                              color: Colors.lightGreen[400],
                              size: 35,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            TextButton(
                              onPressed: () async {
                                final SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                final token = prefs.getString('token') ?? '';

                                if (token.isNotEmpty && token != '') {
                                  //logout here
                                  final response =
                                      await DioProvider().logout(token);

                                  if (response == 200) {
                                    //if successfully delete access token
                                    //then delete token saved at Shared Preference as well
                                    await prefs.remove('token');
                                    setState(() {
                                      isLoading = true;
                                      //redirect to login page
                                      MyApp.navigatorKey.currentState!
                                          .pushReplacementNamed('/');
                                    });
                                  }
                                }
                              },
                              child: isLoading ? CircularProgressIndicator(): Text(
                                AppLocalizations.of(context)!.se_deconnecter,
                                style: TextStyle(
                                  color: Config.primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:rdv/main.dart';
import 'package:rdv/screens/doctor_details.dart';
import 'package:rdv/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    Key? key,
    required this.doctor,
    required this.isFav,
  }) : super(key: key);

  final Map<String, dynamic> doctor;
  final bool isFav;
  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: 150,
      child: GestureDetector(
        child: Card(
          elevation: 5,
          color: Colors.white,
          child: Row(
            children: [
              SizedBox(
                child:           CircleAvatar(
                  radius: 65.0,
                  backgroundImage: NetworkImage('${Config.baseUrlImage}${doctor['image']}'),
                  backgroundColor: Colors.white,
                ),
              ),
              Flexible(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Dr. ${doctor['name']}  ${doctor['last_name']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height:15,),
                      Text(
                        "Spécialité  ${doctor['sp']}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          //pass the details to detail page
          MyApp.navigatorKey.currentState!.push(MaterialPageRoute(
              builder: (_) => DoctorDetails(
                    doctor: doctor,
                    isFav: isFav,
                  )));
        },
      ),
    );
  }
}

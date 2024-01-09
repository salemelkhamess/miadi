import 'package:rdv/components/button.dart';
import 'package:rdv/models/auth_model.dart';
import 'package:rdv/providers/dio_provider.dart';
import 'package:rdv/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components//custom_appbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class DoctorDetails extends StatefulWidget {
   DoctorDetails({Key? key, required this.doctor, required this.isFav}){

  }

  final Map<String, dynamic> doctor;
  final bool isFav;

  @override
  State<DoctorDetails> createState() => _DoctorDetailsState();
}

class _DoctorDetailsState extends State<DoctorDetails> {
  Map<String, dynamic> doctor = {};
  bool isFav = false;

  @override
  void initState() {
    doctor = widget.doctor;
    isFav = widget.isFav;
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    // doctor = widget.doctor;
    // isFav = widget.isFav;

    return Scaffold(
      appBar: CustomAppBar(
        appTitle: AppLocalizations.of(context)!.dr_detail,
        icon: const FaIcon(Icons.arrow_back_ios),
        actions: [
          // Favarite Button
          IconButton(
            //press this button to add/remove favorite doctor
            onPressed: () async {
              //get latest favorite list from auth model
              final list =
                  Provider.of<AuthModel>(context, listen: false).getFav;

              //if doc id is already exist, mean remove the doc id
              if (list.contains(doctor['site_id'])) {
                list.removeWhere((id) => id == doctor['site_id']);
              } else {
                //else, add new doctor to favorite list
                list.add(doctor['site_id']);
              }

              //update the list into auth model and notify all widgets
              Provider.of<AuthModel>(context, listen: false).setFavList(list);

              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              final token = prefs.getString('token') ?? '';

              if (token.isNotEmpty && token != '') {
                //update the favorite list into database
                final response = await DioProvider().storeFavDoc(token, list);
                //if insert successfully, then change the favorite status

                if (response == 200) {
                  setState(() {
                    isFav = !isFav;
                  });
                }
              }
            },
            icon: FaIcon(
              isFav ? Icons.favorite_rounded : Icons.favorite_outline,
              color: Colors.red,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            AboutDoctor(
              doctor: doctor,
            ),
            DetailBody(
              doctor: doctor,
            ),
            // const Spacer(),
            Container(
              padding: EdgeInsets.all(10),
              child: Button(
                width: double.infinity,
                title: AppLocalizations.of(context)!.take_rdv,
                onPressed: () {
                  Navigator.of(context).pushNamed('booking_page',
                      arguments: {"id": doctor});
                },
                disable: false,
              ),
            ),

            // Padding(
            //   padding: const EdgeInsets.all(10),
            //   child: Expanded(
            //     child: Button(
            //       width: double.infinity,
            //       title: 'Prendre rendez-vous',
            //       onPressed: () {
            //         Navigator.of(context).pushNamed('booking_page',
            //             arguments: {"id": doctor['id']});
            //       },
            //       disable: false,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class AboutDoctor extends StatelessWidget {
  const AboutDoctor({Key? key, required this.doctor}) : super(key: key);

  final Map<dynamic, dynamic> doctor;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 65.0,
            backgroundImage: NetworkImage(
              "${Config.baseUrlImage}${doctor['image']}",
            ),
            // backgroundImage: AssetImage('assets/fb.jpeg'),
            backgroundColor: Colors.white,
          ),
          Config.spaceMedium,
          Text(
            "Dr. ${doctor['name']} ${doctor['last_name']}",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widthSize * 0.75,
            child:  Text(
              "${AppLocalizations.of(context)!.prenom} : ${doctor['last_name']}  \n ${AppLocalizations.of(context)!.specialty} : ${doctor['sp']}",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widthSize * 0.75,
            child:  Text(
              '${AppLocalizations.of(context)!.clinique}  ${doctor['clinique']['name']} ',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailBody extends StatelessWidget {
  const DetailBody({Key? key, required this.doctor}) : super(key: key);
  final Map<dynamic, dynamic> doctor;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Config.spaceSmall,
          DoctorInfo(
            durre: doctor['sp'],
            price: 3,
          ),
          Config.spaceMedium,
           Text(
            AppLocalizations.of(context)!.about_dr,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          // Config.spaceSmall,
          SizedBox(height: 5,),
          Text(
            '${AppLocalizations.of(context)!.dr} ${doctor['name']} \n ${doctor['desc']} ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            softWrap: true,
            textAlign: TextAlign.justify,
          ),

          SizedBox(height: 15,),
          
          Center(child: Text(AppLocalizations.of(context)!.dr_work_time,style: TextStyle(fontSize: 22),)),

          DoctorHorrorWidget(horror: doctor["horror"],)



        ],
      ),
    );
  }
}

class DoctorInfo extends StatelessWidget {
  const DoctorInfo({Key? key, required this.durre, required this.price})
      : super(key: key);

  final String durre;
  final int price;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        InfoCard(
          label: AppLocalizations.of(context)!.specialty,
          value: '$durre',
        ),
        const SizedBox(
          width: 15,
        ),
        // InfoCard(
        //   label: 'Nombre ',
        //   value: '$price ',
        // ),
        const SizedBox(
          width: 15,
        ),
         InfoCard(
          label: AppLocalizations.of(context)!.rating,
          value: '',
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({Key? key, required this.label, required this.value})
      : super(key: key);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Config.primaryColor,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 15,
        ),
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 7,
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class DoctorHoror extends StatelessWidget {
  const DoctorHoror({Key? key, required this.horor})
      : super(key: key);

  final List<dynamic> horor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[


      ],
    );
  }
}


class DoctorHorrorWidget extends StatelessWidget {
  final List<dynamic> horror;

  DoctorHorrorWidget({required this.horror});

  @override
  Widget build(BuildContext context) {
    return  Card(
      elevation: 2, // Niveau d'élévation de la Card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Bord arrondi de la Card
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: horror.map((horrorItem) {
            String day = horrorItem['day'];
            String beginningHour = horrorItem['beginning_hour'];
            String endHour = horrorItem['end_hour'];

            return ListTile(
              title: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                '$beginningHour - $endHour',
                style: TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
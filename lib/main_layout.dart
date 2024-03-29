import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:rdv/screens/appointment_page.dart';
import 'package:rdv/screens/fav_page.dart';
import 'package:rdv/screens/home_page.dart';
import 'package:rdv/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  //variable declaration
  int currentPage = 0;
  final PageController _page = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _page,
        onPageChanged: ((value) {
          setState(() {
            currentPage = value;
          });
        }),
        children: <Widget>[
          const HomePage(),
          // FavPage(),
          const AppointmentPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: FloatingNavbar(
        margin: EdgeInsets.all( 0.0),
        padding: EdgeInsets.only(bottom:3.0,top: 3),

      currentIndex: currentPage,
        onTap: (page) {
          setState(() {
            currentPage = page;
            _page.animateToPage(
              page,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          });
        },
        items: [
          FloatingNavbarItem(icon: Icons.home, title: AppLocalizations.of(context)!.accueil),
          FloatingNavbarItem(icon: Icons.explore, title: AppLocalizations.of(context)!.rdv),
          FloatingNavbarItem(icon: Icons.supervised_user_circle_sharp, title: AppLocalizations.of(context)!.profile),
        ],
        backgroundColor: Colors.green,
      ),

      /* bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (page) {
          setState(() {
            currentPage = page;
            _page.animateToPage(
              page,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          });
        },
        items:  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.houseChimneyMedical),
            label:  AppLocalizations.of(context)!.accueil,

          ),
          // BottomNavigationBarItem(
          //   icon: FaIcon(FontAwesomeIcons.solidHeart),
          //   label: 'Préférée',
          // ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.solidCalendarCheck),
            label: AppLocalizations.of(context)!.rdv,
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.solidUser),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
      ),*/
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthModel extends ChangeNotifier {
  bool _isLogout = true;

  bool _isLogin = false;

  Map<String, dynamic> user = {}; //update user details when login
  Map<String,dynamic> appointment =
  {}; //update upcoming appointment when login
  List<Map<String, dynamic>> favDoc = []; //get latest favorite doctor
  List<dynamic> _fav = []; //get all fav doctor id in list

  List<dynamic> sites = []; //update user details when login
  List<dynamic> cartiers = []; //update user details when login

  List<dynamic> sitesBy = []; //update user details when login

  bool get isLogin {
    return _isLogin;
  }

  bool get isLogout {
    return _isLogout;
  }

  List<dynamic> get getFav {
    return _fav;
  }

  Map<String, dynamic> get getUser {
    return user;
  }

  List<dynamic> get getSite {
    return sites;
  }

 void set getSites(st) {
    sites = st;
  }



  List<dynamic> get getSiteBy {
    return sitesBy;
  }

  List<dynamic> get getCartier{
    return cartiers;
  }

  Map<String,dynamic> get getAppointment {
    return appointment;
  }

//this is to update latest favorite list and notify all widgets
  void setFavList(List<dynamic> list) {
    _fav = list;
    notifyListeners();
  }

//and this is to return latest favorite doctor list
  List<Map<String, dynamic>> get getFavDoc {
    favDoc.clear(); //clear all previous record before get latest list

    //list out doctor list according to favorite list
    for (var num in _fav) {
      for (var doc in user['doctor']) {
        if (num == doc['doc_id']) {
          favDoc.add(doc);
        }
      }
    }
    return favDoc;
  }



//when login success, update the status
  void loginSuccess(
      List<dynamic> siteData,
      List<dynamic> cartier,
      Map<String, dynamic> usr
      ) {
    _isLogout = true;

    //update all these data when login
    sites = siteData;
    cartiers = cartier;
    user = usr;

    notifyListeners();
  }

  Future<bool> checkLoginStatus() async {
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');
    if (token != null && token.isNotEmpty) {
      _isLogin = true;
      _isLogout = false;
      return true;
      // Effectuer d'autres opérations si nécessaire (ex: récupérer les données de l'utilisateur, les favoris, etc.)
    } else {
      _isLogin = false;
      _isLogout = true;
      return false;
    }

    notifyListeners();
  }



  // Méthode pour initialiser les données utilisateur
  void setUserData( Map<String, dynamic> userData) {
    user = userData;
    notifyListeners();
  }

  // Méthode pour initialiser les données de rendez-vous (doctors)
  void setAppointmentData(Map<String,dynamic> appointmentData) {
    appointment = appointmentData;
    notifyListeners();
  }

  // Méthode pour initialiser les données favorites
  void setFavData(List<Map<String, dynamic>> favData) {
    _fav = favData;
    notifyListeners();
  }

  // Méthode pour initialiser les données des sites
  void setSiteData(List<dynamic>  siteData) {
    sites = siteData;
    notifyListeners();
  }

  // Méthode pour initialiser les données des cartiers
  void setCartierData(List<dynamic>  cartierData) {
    cartiers = cartierData;
    notifyListeners();
  }

}
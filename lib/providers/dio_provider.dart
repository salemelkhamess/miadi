import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rdv/models/auth_model.dart';
import 'package:rdv/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DioProvider {

  Future<dynamic> getToken(String phone, String password) async {
    try {
      final response = await Dio().post(
        '${Config.baseUrl}/login',
        data: {'phone': phone, 'password': password},
      );

      if (response.statusCode == 200 && response.data != '') {
        final token = response.data['token'] as String;

              final SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('token', token);

              // Store the token securely using flutter_secure_storage
              final secureStorage = FlutterSecureStorage();
              await secureStorage.write(key: 'token', value: token);

              return true;
      } else {
        // ... Gérer les erreurs ...
        return false;
      }
    } catch (error) {
      print(error);
      return false;
    }
  }

  //get token
  // Future<dynamic> getToken(String email, String password) async {
  //   try {
  //     var response = await Dio().post('${Config.baseUrl}/login',
  //         data: {'email': email, 'password': password});
  //
  //     if (response.statusCode == 200 && response.data != '') {
  //       final SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('token', response.data);
  //
  //       // Store the token securely using flutter_secure_storage
  //       final secureStorage = FlutterSecureStorage();
  //       await secureStorage.write(key: 'token', value: response.data);
  //
  //       return true;
  //     } else {
  //       Fluttertoast.showToast(
  //           msg: "Erreur réseau ",
  //           toastLength: Toast.LENGTH_SHORT,
  //           gravity: ToastGravity.BOTTOM_RIGHT,
  //           timeInSecForIosWeb: 1,
  //           backgroundColor: Colors.orange,
  //           textColor: Colors.white,
  //           fontSize: 16.0
  //       );
  //       return false;
  //     }
  //   } catch (error) {
  //     Fluttertoast.showToast(
  //         msg: "Erreur email ou mot de pass ",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM_RIGHT,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.orange,
  //         textColor: Colors.white,
  //         fontSize: 16.0
  //     );
  //     return error;
  //   }
  // }

  //get user data
  Future<dynamic> getUser(String token) async {
    try {
      var user = await Dio().get('${Config.baseUrl}/user',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (user.statusCode == 200 && user.data != '') {
        return json.encode(user.data);
      }
    } catch (error) {
      return error;
    }
  }

  Future<dynamic> getCurrentUser(String token) async {
    try {
      var user = await Dio().get('${Config.baseUrl}/currentuser',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (user.statusCode == 200 && user.data != '') {
        return json.encode(user.data);
      }
    } catch (error) {
      return error;
    }
  }

  //register new user
  Future<dynamic> registerUser(
      String username, String email, String password, String age, String mobile, String address, String lastname,) async {
    try {
      var user = await Dio().post('${Config.baseUrl}/register',
          data: {
            'name': username,
            'email': email,
            'password': password,
            'lastname':lastname,
            'age':age,
            'mobile':mobile,
            'address':address
      });
      print('status code ');
      print(user.statusCode);
      if (user.statusCode == 201 && user.data != '') {
        return true;
      } else {
        print('status code ');
        print(user.statusCode);

        Fluttertoast.showToast(
          msg: "Numero telephone deja existe ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_RIGHT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return false;
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Numero telephone deja existe ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM_RIGHT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print('status code ');
      print(error);
      return error;
    }
  }

  //store booking details
  Future<dynamic> bookAppointment(
      String date, String day, String time, int site, String token) async {
    try {
      var response = await Dio().post('${Config.baseUrl}/book',
          data: {'date': date, 'day': day, 'time': time, 'site_id': site},
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (response.statusCode == 200 && response.data != '') {
        print('Status code');
        print(response.statusCode );
        return response.statusCode;
      } else {

        return 'Error';
      }
    } catch (error) {

      return error;
    }
  }

  //retrieve booking details
  Future<dynamic> getAppointments(String token) async {
    try {
      var response = await Dio().get('${Config.baseUrl}/appointments',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      print(error);
      return error;
    }
  }


  //retrieve booking details
  Future<dynamic> getSites(String token) async {
    try {
      var response = await Dio().get('${Config.baseUrl}/doctor',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {

        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }


  Future<dynamic> getDoctorsBySp(String token,String sp ) async {
    try {
      var response = await Dio().get('${Config.baseUrl}/doctors/specialite',
          data: {'specialty': sp,},
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {

        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      print(error);
      return error;
    }
  }


  Future<dynamic> getSitesByCartier(String token,int id) async {
    try {
      var response = await Dio().get('${Config.baseUrl}/doctor_by_clinique/${id}',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {

        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  Future<dynamic> getHoror(String token,int id) async {
    try {
      var response = await Dio().get('${Config.baseUrl}/hosror/${id}',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {

        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  Future<dynamic> getCartiers(String token) async {
    try {
      var response = await Dio().get('${Config.baseUrl}/clinique',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  //store rating details
  Future<dynamic> storeReviews(
      String reviews, double ratings, int id, int doctor, String token) async {
    try {
      var response = await Dio().post('${Config.baseUrl}/reviews',
          data: {
            'ratings': ratings,
            'reviews': reviews,
            'appointment_id': id,
            'doctor_id': doctor
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  //store fav doctor
  Future<dynamic> storeFavDoc(String token, List<dynamic> favList) async {
    try {
      var response = await Dio().post('${Config.baseUrl}/fav',
          data: {
            'favList': favList,
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
  // Future<void> saveLoginStatus(bool isLoggedIn) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool(isLoggedInKey, isLoggedIn);
  // }
//logout
  Future<dynamic> logout(String token) async {
    try {
      var response = await Dio().post('${Config.baseUrl}/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        // Supprimer le token des préférences partagées
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(token);
        // Supprimer le token de flutter_secure_storage
        final secureStorage = FlutterSecureStorage();
        await secureStorage.delete(key: 'token');

        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }


  Future<void> createPayment(int userId, int clinicId, int doctorId, int amount, String date) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/payments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'clinique_id': clinicId,
        'doctor_id': doctorId,
        'amount': amount,
        'date': date,
      }),
    );

    if (response.statusCode == 200) {
      // Le paiement a été créé avec succès
      final responseData = json.decode(response.body);
      // Traitez la réponse si nécessaire
      print('Payment created: $responseData');
    } else {
      print(response);
      // Gérer les erreurs en fonction du code de réponse
      print('Failed to create payment: ${response.statusCode}');
    }
  }


  Future<dynamic> getTodayApp(String token) async {
    try {
      var response = await Dio().get('${Config.baseUrl}/today',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {

        print(response.data);
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }



}

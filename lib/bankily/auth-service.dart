import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:math';

class AuthPageBankily  {
  static Future<Map<String, dynamic>> performAuthentication() async {
    final String url = 'https://ebankily.appspot.com/authentification';

    Map<String, String> headers = {
      'Content-type': 'application/x-www-form-urlencoded',
    };

    Map<String, String> body = {
      'grant_type': 'password',
      'username': 'MIADI',
      'password': '4a5c3e35-a027-4946-95dc-438c78ae950a',
      'client_id': 'ebankily',
    };

    http.Response response =
    await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      // Authentication successful
      Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      // Authentication failed
      print('Authentication failed. Status Code: ${response.statusCode}');
      return {};
    }
  }

  // static Future<Object> performAuthentication() async {
  //   final String url = 'https://ebankily.appspot.com/authentification';
  //
  //   Map<String, String> headers = {
  //     'Content-type': 'application/x-www-form-urlencoded',
  //   };
  //
  //   Map<String, String> body = {
  //     'grant_type': 'password',
  //     'username': 'MIADI',
  //     'password': '4a5c3e35-a027-4946-95dc-438c78ae950a',
  //     'client_id': 'ebankily',
  //   };
  //
  //   http.Response response =
  //   await http.post(Uri.parse(url), headers: headers, body: body);
  //
  //   if (response.statusCode == 200) {
  //     // Authentication successful
  //     Map<String, dynamic> data = jsonDecode(response.body);
  //     String accessToken = data['access_token'];
  //     return data;
  //     // You can store the access token or use it for further API calls
  //   } else {
  //     // Authentication failed
  //
  //     print('Authentication failed. Status Code: ${response.statusCode}');
  //     return '';
  //   }
  // }


  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final String url = 'https://ebankily-tst.appspot.com/authentification';
    final Map<String, String> headers = {'Content-type': 'application/x-www-form-urlencoded'};
    final Map<String, String> body = {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
      'client_id': 'ebankily',
    };

    final http.Response response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Token refresh failed');
    }
  }


  static String generateOperationId() {
    // Obtenir le temps actuel en millisecondes depuis l'époque Unix
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    // Générer une partie aléatoire
    int randomPart = Random().nextInt(1000000); // Utilisez une valeur adaptée à vos besoins

    // Combinez le timestamp et la partie aléatoire pour former l'identifiant
    String operationId = '$timestamp$randomPart';

    return operationId;
  }

  static const String baseURL = 'https://ebankily.appspot.com';

  static Future<Map<String, dynamic>> makePayment(String accessToken, String clientPhone, String passcode,  String amount, String language) async {
    final String url = '$baseURL/payment';

    final String operationId = generateOperationId();
    print("Transation ID $operationId");

    final Map<String, String> headers = {'Content-type': 'application/json', 'Authorization': 'Bearer $accessToken'};
    final Map<String, dynamic> body = {
      'clientPhone': clientPhone,
      'passcode': passcode,
      'operationId': generateOperationId(),
      'amount': amount,
      'language': language,
    };

    final http.Response response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));


    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Payment failed');
    }
  }


}


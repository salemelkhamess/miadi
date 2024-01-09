import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class AuthenticationManager {
  String? accessToken;
  int? accessTokenExpiresIn;
  String? refreshToken;
  int? refreshTokenExpiresIn;

  Future<void> performAuthentication() async {
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
      Map<String, dynamic> authData = jsonDecode(response.body);
      accessToken = authData['access_token'];
      accessTokenExpiresIn = int.parse(authData['expires_in']);
      refreshToken = authData['refresh_token'];
      refreshTokenExpiresIn = int.parse(authData['refresh_expires_in']);


      print("Authentication successful.");
    } else {
      print('Authentication failed. Status Code: ${response.statusCode}');
    }
  }

  bool isAccessTokenExpired() {
    if (accessToken == null || accessTokenExpiresIn == null) {
      return true;
    }

    DateTime expirationTime =
    DateTime.now().add(Duration(seconds: accessTokenExpiresIn!));
    return expirationTime.isBefore(DateTime.now());
  }
}
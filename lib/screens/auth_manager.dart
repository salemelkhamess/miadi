import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String isLoggedInKey = 'isLoggedIn';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, value);
  }

  static Future<void> clearLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(isLoggedInKey);
  }
}

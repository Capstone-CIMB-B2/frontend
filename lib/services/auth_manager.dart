import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String _tokenKey = 'access_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static const String _lastUsernameKey = 'last_username';

  static Future<void> saveLastUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUsernameKey, username);
  }

  static Future<String?> getLastUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUsernameKey);
  }

  static Future<void> clearLastUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastUsernameKey);
  }
}

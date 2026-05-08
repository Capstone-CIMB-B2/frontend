import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/promo_response.dart';
import 'auth_manager.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  // 1. Register
  static Future<bool> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email_address': email,
        'password': password,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // 2. Login
  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['access_token'];
      await AuthManager.saveToken(token);
      return true;
    }
    return false;
  }

  // 3. Create Profile
  static Future<bool> createProfile(Map<String, dynamic> profileData) async {
    final token = await AuthManager.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profileData),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // 4. Get Recommendation
  static Future<PromoResponse?> getRecommendation() async {
    final token = await AuthManager.getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/recommendation'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return PromoResponse.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // 5. Get Profile
  static Future<Map<String, dynamic>?> getProfile() async {
    final token = await AuthManager.getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<bool> updateConsent(bool consent) async {
  final token = await AuthManager.getToken();
  if (token == null) return false;

  final response = await http.patch(
    Uri.parse('$baseUrl/profile/consent'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'consent_personalization': consent}),
  );
  return response.statusCode == 200;
}
}

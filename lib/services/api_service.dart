import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/promo_response.dart';

class ApiService {
  // TODO: Ganti dengan URL backend capstone yang sebenarnya nanti
  static const String baseUrl = 'http://localhost:8000'; 

  // Tambahkan parameter token jika API membutuhkan autentikasi (opsional)
  Future<PromoResponse?> getRecommendation(String userId, {String? token}) async {
    try {
      // 1. Setup headers
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      // 2. Jika ada token (user sudah login), masukkan ke header Authorization
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // 3. Kirim request beserta headers-nya
      final response = await http.get(
        Uri.parse('$baseUrl/recommendation/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        return PromoResponse.fromJson(jsonMap);
      } else {
        print('Gagal mengambil data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Terjadi error jaringan: $e');
      return null;
    }
  }
}

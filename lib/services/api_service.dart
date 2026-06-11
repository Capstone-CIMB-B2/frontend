import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/promo_response.dart';
import '../models/transaction_response.dart';
import 'auth_manager.dart';

class ApiService {
  static String get baseUrl {
    return 'https://capstone-backend.up.railway.app';
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

  static Future<Map<String, dynamic>?> transfer({
    required String recipientName,
    required String recipientBank,
    required String recipientAccount,
    required double amount,
    required String notes,
    required String pin,
  }) async {
    final token = await AuthManager.getToken();
    if (token == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transfer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'recipient_name': recipientName,
          'recipient_bank': recipientBank,
          'recipient_account': recipientAccount,
          'amount': amount,
          'notes': notes,
          'pin': pin,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'new_balance': responseData['new_balance'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Terjadi kesalahan saat transfer',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menghubungkan ke server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>?> createTransaction({
    required String category,
    required String merchantName,
    required String transactionMethod,
    required double amount,
    required String notes,
    required String pin,
    String? recipientBank,
    String? recipientAccount,
  }) async {
    final token = await AuthManager.getToken();
    if (token == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transaction'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'category': category,
          'merchant_name': merchantName,
          'transaction_method': transactionMethod,
          'amount': amount,
          'notes': notes,
          'pin': pin,
          'recipient_bank': recipientBank,
          'recipient_account': recipientAccount,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'new_balance': responseData['new_balance'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Terjadi kesalahan saat memproses transaksi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menghubungkan ke server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>?> decodeQr(String payload) async {
    final token = await AuthManager.getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/qr/decode/$payload'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // silent fail
    }
    return null;
  }



  static Future<Map<String, dynamic>?> validateAccount({
    required String bankName,
    required String accountNumber,
  }) async {
    final token = await AuthManager.getToken();
    if (token == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate-account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'bank_name': bankName,
          'account_number': accountNumber,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'account_name': responseData['account_name'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Nomor rekening tidak ditemukan!',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menghubungkan ke server: $e',
      };
    }
  }

  // 6. Get Recent Transactions
  static Future<List<TransactionResponse>?> getRecentTransactions({
    int limit = 5,
    String? transactionMethod,
    String? category,
    String? excludeMethod,
    String? excludeCategory,
  }) async {
    final token = await AuthManager.getToken();
    if (token == null) return null;

    try {
      var url = '$baseUrl/transactions/recent?limit=$limit';
      if (transactionMethod != null) url += '&transaction_method=$transactionMethod';
      if (category != null) url += '&category=$category';
      if (excludeMethod != null) url += '&exclude_method=$excludeMethod';
      if (excludeCategory != null) url += '&exclude_category=$excludeCategory';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic>? trxList = responseData['transactions'];
        if (trxList != null) {
          return trxList.map((x) => TransactionResponse.fromJson(x)).toList();
        }
      }
    } catch (e) {
      // Silent error fallback
    }
    return null;
  }

  // 6b. Get Saved Contacts
  static Future<List<dynamic>?> getSavedContacts({
    String? category,
    String? excludeCategory,
  }) async {
    final token = await AuthManager.getToken();
    if (token == null) return null;

    try {
      var url = '$baseUrl/api/v1/saved-contacts';
      final params = <String>[];
      if (category != null) params.add('category=$category');
      if (excludeCategory != null) params.add('exclude_category=$excludeCategory');
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
    } catch (e) {
      // silent fail
    }
    return null;
  }

  // 6c. Add Saved Contact
  static Future<Map<String, dynamic>?> addSavedContact({
    required String name,
    required String accountNumber,
    String? bankName,
    required String category,
  }) async {
    final token = await AuthManager.getToken();
    if (token == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/saved-contacts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'account_number': accountNumber,
          'bank_name': bankName,
          'category': category,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'data': responseData};
      } else {
        return {'success': false, 'message': responseData['detail'] ?? 'Gagal menyimpan kontak'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghubungkan ke server: $e'};
    }
  }

  // 6d. Delete Saved Contact
  static Future<bool> deleteSavedContact(int contactId) async {
    final token = await AuthManager.getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/v1/saved-contacts/$contactId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static int? _sessionId;
  static int get sessionId {
    _sessionId ??= 100000 + DateTime.now().millisecond + (DateTime.now().microsecond % 900000);
    return _sessionId!;
  }

  // 7. Track User Interaction
  static Future<bool> trackInteraction({
    required String featureAccessed,
    required String action,
    String? interactionType,
  }) async {
    try {
      final profile = await getProfile();
      final int? userId = profile != null ? profile['user_id'] : null;

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/track'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'session_id': sessionId.toString(),
          'feature_accessed': featureAccessed,
          'action': action,
          'interaction_type': interactionType,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      // silent fail
    }
    return false;
  }
}


import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'http://192.168.0.132/hotel_bengkalis/api/login/';

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String phone, // Tambahkan parameter phone
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}register_user.php'),
        body: {
          'username': username,
          'email': email,
          'password': password,
          'phone': phone, // Kirimkan nomor HP ke server
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);   
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}login_user.php'),
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);   
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Network error: ${e.toString()}'
      };
    }
  }
}

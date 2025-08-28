import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://192.168.1.3/nindo/login_mobile.php';

  static Future<Map<String, dynamic>> loginUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Pastikan response body adalah JSON dan valid
        try {
          return json.decode(response.body);
        } catch (e) {
          return {'status': 'error', 'message': 'Response tidak valid JSON: $e'};
        }
      } else {
        return {'status': 'error', 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Terjadi error: $e'};
    }
  }
}

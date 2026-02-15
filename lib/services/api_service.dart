// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://api.vulcainvpn.com/api'; // e.g., 'https://your-api.com'

  static Future<Map<String, dynamic>> fetchStatus(String jwt) async {
    final response = await http.get(
      Uri.parse('$baseUrl/status'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load status');
    }
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';

class IpService {
  static Future<String> getPublicIp() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ipify.org?format=json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ip'] ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      print('Error fetching IP: $e');
      return 'Unknown';
    }
  }
}

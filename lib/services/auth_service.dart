import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inventory_apps/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<bool> login(String username, String password) async {
    final url = "${ApiConfig.baseUrl}/login";
    print(" Menembak ke Url : $url");
    print("Data  yang di kirim = username : $username, password : $password");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'COntent-type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      print("Status Code dari server = ${response.statusCode}");
      print("Respon Body = ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String token = responseData['data']['token'];
        final String name = responseData['data']['data']['name'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setString("name", name);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('eror login = $e');
      return false;
    }
  }
}   

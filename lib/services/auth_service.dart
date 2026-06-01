import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inventory_apps/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<bool> login(String email, String password) async {
    final url = "${ApiConfig.baseUrl}/auth/login";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Ambil token dari response
        final String token =
            responseData['data']?['token'] ?? responseData['token'] ?? '';

        // Ambil user data
        final int userId = responseData['data']?['user']?['id'] ?? 0;

        final String name =
            responseData['data']?['user']?['name'] ??
            responseData['data']?['name'] ??
            responseData['name'] ??
            'User';

        // Ambil role user dari response.data.user.role
        final String role =
            responseData['data']?['user']?['role'] ??
            responseData['data']?['role'] ??
            responseData['role'] ??
            'user';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setInt("user_id", userId);
        await prefs.setString("name", name);
        await prefs.setString("role", role);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final url = "${ApiConfig.baseUrl}/auth/register";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("user_id");
    await prefs.remove("name");
    await prefs.remove("role");
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return token != null && token.isNotEmpty;
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("name") ?? "User";
  }

  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role") ?? "user";
  }
}

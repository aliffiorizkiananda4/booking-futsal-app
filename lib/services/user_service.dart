import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inventory_apps/config/api_config.dart';
import 'package:inventory_apps/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<UserModel>> getUsers() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> dataList = responseData['data'] ?? [];
        return dataList.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<bool> deleteUser(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/$id');
    try {
      final headers = await _getHeaders();
      final response = await http.delete(url, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_id");
  }
}

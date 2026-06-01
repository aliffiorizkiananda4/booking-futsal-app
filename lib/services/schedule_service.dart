import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inventory_apps/config/api_config.dart';
import 'package:inventory_apps/models/schedule_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<ScheduleModel>> getSchedules({int? fieldId}) async {
    String url = '${ApiConfig.baseUrl}/schedules';
    if (fieldId != null) {
      url += '?field_id=$fieldId';
    }

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> dataList = responseData['data'] ?? [];
        return dataList.map((json) => ScheduleModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat jadwal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<bool> createSchedule(ScheduleModel schedule) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/schedules');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(schedule.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateSchedule(int id, ScheduleModel schedule) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/schedules/$id');
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(schedule.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSchedule(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/schedules/$id');
    try {
      final headers = await _getHeaders();
      final response = await http.delete(url, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

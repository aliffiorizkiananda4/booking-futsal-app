import 'dart:convert';

import 'package:inventory_apps/config/api_config.dart';
import 'package:inventory_apps/models/booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BookingService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>?> fetchBookings({
    int page = 1,
    int limit = 10,
  }) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/bookings?page=$page&limit=$limit",
    );
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final paginationData = decoded['data'];
        List<dynamic> rawData = paginationData['data'] ?? paginationData;
        List<BookingModel> bookings = rawData
            .map((e) => BookingModel.fromJson(e))
            .toList();
        return {
          'bookings': bookings,
          'totalPage': paginationData['totalPage'] ?? 1,
          'totalData': paginationData['total'] ?? bookings.length,
        };
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> createBooking({
    required int fieldId,
    required int scheduleId,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/bookings");
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'field_id': fieldId, 'schedule_id': scheduleId}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBookingStatus(int id, String status) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/bookings/$id");
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

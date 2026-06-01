import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:inventory_apps/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  Future<Map<String, String>> _getAuthHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    return {'Authorization': 'Bearer $token'};
  }

  Future<Map<String, String>> _getJsonHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Map<String, dynamic>>> getPayments() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/payments');
    final headers = await _getJsonHeaders();

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> dataList = responseData['data'] ?? [];
        return dataList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Gagal memuat pembayaran');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<bool> uploadPaymentProof({
    required int bookingId,
    required File paymentProof,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/payments');
    final headers = await _getAuthHeader();

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      request.fields['booking_id'] = bookingId.toString();

      // Tambahkan file gambar
      final bytes = await paymentProof.readAsBytes();
      final fileName = paymentProof.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'png' : 'jpeg';

      request.files.add(
        http.MultipartFile.fromBytes(
          'payment_proof',
          bytes,
          filename: fileName,
          contentType: MediaType('image', mimeType),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePaymentStatus(int id, String status) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/payments/$id');
    final headers = await _getJsonHeaders();

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

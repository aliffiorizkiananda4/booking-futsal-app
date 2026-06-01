import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_apps/config/api_config.dart';
import 'package:inventory_apps/models/field_model.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class FieldService {
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

  Future<List<FieldModel>> getFields() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/fields');
    final headers = await _getJsonHeaders();

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> dataList = responseData['data'] ?? [];
        return dataList.map((json) => FieldModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data lapangan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<FieldModel> getFieldById(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/fields/$id');
    final headers = await _getJsonHeaders();

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return FieldModel.fromJson(responseData['data']);
      } else {
        throw Exception('Gagal memuat detail lapangan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<bool> postField(
    String name,
    String type,
    String price,
    String description,
    XFile? image,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/fields');
    final headers = await _getAuthHeader();

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      request.fields['name'] = name;
      request.fields['type'] = type;
      request.fields['price'] = price;
      request.fields['description'] = description;

      if (image != null) {
        final bytes = await image.readAsBytes();
        final ext = path.extension(image.name).toLowerCase();
        final mimeType = ext == '.png' ? 'png' : 'jpeg';

        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: image.name,
            contentType: MediaType('image', mimeType),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateField(
    int id,
    String name,
    String type,
    String price,
    String description,
    XFile? image,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/fields/$id');
    final headers = await _getAuthHeader();

    try {
      final request = http.MultipartRequest('PUT', url);
      request.headers.addAll(headers);
      request.fields['name'] = name;
      request.fields['type'] = type;
      request.fields['price'] = price;
      request.fields['description'] = description;

      if (image != null) {
        final bytes = await image.readAsBytes();
        final ext = path.extension(image.name).toLowerCase();
        final mimeType = ext == '.png' ? 'png' : 'jpeg';

        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: image.name,
            contentType: MediaType('image', mimeType),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteField(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/fields/$id');
    final headers = await _getJsonHeaders();

    try {
      final response = await http.delete(url, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

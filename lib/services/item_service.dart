import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_apps/config/api_config.dart';
import 'package:inventory_apps/models/item_model.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class ItemService {
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

  Future<List<ItemModel>> getItems() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/items');
    final headers = await _getJsonHeaders();

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> dataList = responseData['data'] ?? [];
        return dataList.map((json) => ItemModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data barang: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> postItem(
    String nama,
    String stok,
    XFile? image, // <-- XFile bukan File
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/items');
    final headers = await _getAuthHeader();

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      request.fields['name'] = nama;
      request.fields['stock'] = stok;

      if (image != null) {
        final bytes = await image.readAsBytes(); // support web & mobile
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        final body = json.decode(response.body);
        throw Exception(body['message'] ?? 'Gagal menambah barang');
      }
    } catch (e) {
      throw Exception('Gagal menambah barang: $e');
    }
  }

  Future<void> updateItem(
    int id,
    String nama,
    String stok,
    XFile? image,
    dynamic imageFile, // <-- XFile bukan File
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/items/$id');
    final headers = await _getAuthHeader();

    try {
      final request = http.MultipartRequest('PUT', url);
      request.headers.addAll(headers);
      request.fields['name'] = nama;
      request.fields['stock'] = stok;

      if (image != null) {
        final bytes = await image.readAsBytes();
        request.files.add(
            http.MultipartFile.fromBytes("image",bytes,filename: imageFile.name)
        );// support web & mobile
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

      if (response.statusCode != 200) {
        final body = json.decode(response.body);
        throw Exception(body['message'] ?? 'Gagal memperbarui barang');
      }
    } catch (e) {
      throw Exception('Gagal memperbarui barang: $e');
    }
  }

  Future<void> deleteItem(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/items/$id');
    final headers = await _getJsonHeaders();

    try {
      final response = await http.delete(url, headers: headers);
      if (response.statusCode != 200) {
        final body = json.decode(response.body);
        throw Exception(body['message'] ?? 'Gagal menghapus barang');
      }
    } catch (e) {
      throw Exception('Gagal menghapus barang: $e');
    }
  }
}

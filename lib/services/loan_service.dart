import 'dart:convert';

import 'package:inventory_apps/config/api_config.dart';
import 'package:inventory_apps/models/loan_model.dart';
import 'package:inventory_apps/widgets/button/custom_button.dart';
import 'package:inventory_apps/widgets/card/stat_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoanService {
    Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future <Map<String, dynamic>?> fetchLoan ({
    int page = 1,
    int limit = 5,
  })async {
    final url = Uri.parse("${ApiConfig.baseUrl}/loans?page=$page&limit");
    try {
        final CustomHeader = await _getHeaders();
        final response = await http.get(url, headers:CustomHeader);
        if (response.statusCode == 200) {
            final decoded = jsonDecode(response.body);
            final paginationData = decoded['data'];
            //mebgubah array dari json menjadi list menggunakan LoanModel
            List<dynamic>rawData = paginationData['data'];
            List<LoanModel> loans = rawData.map((e) => LoanModel.fromJson(e)).toList();
            return {
                'loans' : loans,
                'totalpage': paginationData['totalPage'],
                'totalData': paginationData['total'],
            };
        }else {
            print("Gagal fetch loan : ${response.statusCode}");
            return null;
        }
    }catch (e){
       Exception("Error fecth loan : $e");
       return null;
    }
  }
}

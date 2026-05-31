
import 'package:inventory_apps/config/api_config.dart';

class ItemModel {
  final int id;
  final String name;
  final int stock;
  final String? imageurl;

  ItemModel({
    required this.id,
    required this.name,
    required this.stock,
    this.imageurl,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    String? rawImageUrl = json['image'];
    if (rawImageUrl != null) {
      rawImageUrl = rawImageUrl.replaceAll(
        "http://localhost:3000", ApiConfig.baseUrl,
      );
      rawImageUrl = rawImageUrl.replaceAll(
        "http://localhost:5000", ApiConfig.baseUrl,
      );
    }
    return ItemModel(
      id: json['id'],
      name: json['name'],
      stock: json['stock'],
      imageurl: rawImageUrl,
    );
  }
}

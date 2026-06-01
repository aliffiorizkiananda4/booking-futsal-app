import 'package:inventory_apps/config/api_config.dart';

class FieldModel {
  final int id;
  final String name;
  final String type;
  final int price;
  final String? description;
  final String? image;

  FieldModel({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    this.description,
    this.image,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    String? rawImageUrl = json['image'];

    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
      // Jika sudah berupa URL lengkap, gunakan langsung
      if (rawImageUrl.startsWith('http://') ||
          rawImageUrl.startsWith('https://')) {
        imageUrl = rawImageUrl
            .replaceAll("http://localhost:3000", ApiConfig.baseUrl)
            .replaceAll("http://localhost:9000", ApiConfig.baseUrl);
      } else {
        // Jika hanya nama file, tambahkan base URL
        imageUrl = '${ApiConfig.baseUrl}/uploads/$rawImageUrl';
      }
    }

    return FieldModel(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      price: json['price'] ?? 0,
      description: json['description'],
      image: imageUrl,
    );
  }
}

import 'package:inventory_apps/models/item_model.dart';

class LoanModel {
    final int id;
    final String name;
    final int totalItem;
    final String date;
    final ItemModel? item;

    LoanModel({
        required this.id,
        required this.name,
        required this.totalItem,
        required this.date,
        this.item
    });

    factory LoanModel.fromJson(Map<String, dynamic> json) {
        String formattedDate = '';
        if (json['date'] != null) {
            DateTime parseDate = DateTime.parse(json['date']);
            formattedDate = "${parseDate.month.toString().padLeft(2, '0')}-${parseDate.year}";
        }

        return LoanModel(id: json['id'] ?? 0, name: json['name'] ?? "tanpa nama", totalItem: json['totalItem'] , date: formattedDate, item: json['item'] !=null ? ItemModel.fromJson(json['item']) : null,
        );
    }
}

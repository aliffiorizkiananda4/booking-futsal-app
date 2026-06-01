import 'package:inventory_apps/models/field_model.dart';

class BookingModel {
  final int id;
  final int userId;
  final int fieldId;
  final int scheduleId;
  final String status;
  final String? date;
  final FieldModel? field;

  BookingModel({
    required this.id,
    required this.userId,
    required this.fieldId,
    required this.scheduleId,
    required this.status,
    this.date,
    this.field,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String formattedDate = '';
    if (json['createdAt'] != null) {
      DateTime parseDate = DateTime.parse(json['createdAt']);
      formattedDate =
          "${parseDate.day.toString().padLeft(2, '0')}-${parseDate.month.toString().padLeft(2, '0')}-${parseDate.year}";
    }

    return BookingModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      fieldId: json['field_id'] ?? 0,
      scheduleId: json['schedule_id'] ?? 0,
      status: json['status'] ?? 'pending',
      date: formattedDate,
      field: json['field'] != null ? FieldModel.fromJson(json['field']) : null,
    );
  }
}

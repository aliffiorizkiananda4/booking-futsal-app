class ScheduleModel {
  final int id;
  final int fieldId;
  final String date;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final String? fieldName;

  ScheduleModel({
    required this.id,
    required this.fieldId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.fieldName,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? 0,
      fieldId: json['field_id'] ?? 0,
      date: json['date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
      fieldName: json['field']?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field_id': fieldId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'is_available': isAvailable ? 1 : 0,
    };
  }
}

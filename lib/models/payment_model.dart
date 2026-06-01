class PaymentModel {
  final int id;
  final int bookingId;
  final String? paymentProof;
  final String status;
  final String? createdAt;

  PaymentModel({
    required this.id,
    required this.bookingId,
    this.paymentProof,
    required this.status,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      paymentProof: json['payment_proof'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'],
    );
  }
}

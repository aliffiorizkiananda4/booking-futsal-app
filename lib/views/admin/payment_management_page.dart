import 'package:flutter/material.dart';
import 'package:inventory_apps/config/api_config.dart';
import 'package:inventory_apps/services/payment_service.dart';

class PaymentManagementPage extends StatefulWidget {
  const PaymentManagementPage({super.key});

  @override
  State<PaymentManagementPage> createState() => _PaymentManagementPageState();
}

class _PaymentManagementPageState extends State<PaymentManagementPage> {
  final PaymentService _paymentService = PaymentService();
  late Future<List<Map<String, dynamic>>> _paymentsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _paymentsFuture = _paymentService.getPayments();
    });
  }

  void _verifyPayment(int id, String status) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Konfirmasi ${status == 'verified' ? 'Verifikasi' : 'Tolak'}',
        ),
        content: Text(
          'Yakin ingin ${status == 'verified' ? 'memverifikasi' : 'menolak'} pembayaran ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await _paymentService.updatePaymentStatus(
                id,
                status,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Pembayaran berhasil di${status == 'verified' ? 'verifikasi' : 'tolak'}'
                          : 'Gagal mengupdate pembayaran',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success) _refreshData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'verified' ? Colors.green : Colors.red,
            ),
            child: Text(status == 'verified' ? 'Verifikasi' : 'Tolak'),
          ),
        ],
      ),
    );
  }

  void _showPaymentProof(String? paymentProof) {
    if (paymentProof == null || paymentProof.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bukti pembayaran tidak tersedia')),
      );
      return;
    }

    String imageUrl = paymentProof;
    if (!paymentProof.startsWith('http')) {
      imageUrl = '${ApiConfig.baseUrl}/uploads/$paymentProof';
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Bukti Pembayaran'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Image.network(
                imageUrl,
                errorBuilder: (_, __, ___) => const Column(
                  children: [
                    Icon(Icons.broken_image, size: 64),
                    Text('Gagal memuat gambar'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'Terverifikasi';
      case 'pending':
        return 'Menunggu';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Kelola Pembayaran',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _paymentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final payments = snapshot.data ?? [];

          if (payments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada pembayaran'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              final isPending =
                  (payment['status'] ?? '').toString().toLowerCase() ==
                  'pending';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking ID: ${payment['booking_id']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (payment['booking'] != null) ...[
                                  Text(
                                    payment['booking']['field']?['name'] ??
                                        'Lapangan',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                payment['status'] ?? 'pending',
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusText(payment['status'] ?? 'pending'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(
                                  payment['status'] ?? 'pending',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _showPaymentProof(payment['payment_proof']),
                        icon: const Icon(Icons.image, size: 18),
                        label: const Text('Lihat Bukti Pembayaran'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      if (isPending) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _verifyPayment(payment['id'], 'verified'),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Verifikasi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _verifyPayment(payment['id'], 'rejected'),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Tolak'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

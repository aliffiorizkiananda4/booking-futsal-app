import 'package:flutter/material.dart';
import 'package:inventory_apps/models/field_model.dart';
import 'package:inventory_apps/services/field_service.dart';
import 'package:inventory_apps/views/field_detail_page.dart';

class FieldPage extends StatefulWidget {
  const FieldPage({super.key});

  @override
  State<FieldPage> createState() => _FieldPageState();
}

class _FieldPageState extends State<FieldPage> {
  final FieldService _fieldService = FieldService();
  late Future<List<FieldModel>> _fieldFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Refresh data when the page becomes visible again
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This ensures data is refreshed when navigating back to this page
  }

  void _refreshData() {
    setState(() {
      _fieldFuture = _fieldService.getFields();
    });
  }

  Future<void> _onRefresh() async {
    try {
      final fields = await _fieldService.getFields();
      if (mounted) {
        setState(() {
          _fieldFuture = Future.value(fields);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Lapangan Futsal',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF22C55E)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _onRefresh();
        },
        color: const Color(0xFF22C55E),
        child: FutureBuilder<List<FieldModel>>(
        future: _fieldFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF22C55E)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 64,
                    color: Color(0xFFCBD5E1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _refreshData,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final fields = snapshot.data ?? [];

          if (fields.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.sports_soccer_outlined,
                      size: 40,
                      color: Color(0xFF22C55E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada lapangan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lapangan akan segera tersedia',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fields.length,
            itemBuilder: (context, index) => _buildFieldCard(fields[index]),
          );
        },
      ),
      ),
    );
  }

  Widget _buildFieldCard(FieldModel field) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FieldDetailPage(fieldId: field.id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: field.image != null
                  ? Image.network(
                      field.image!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 180,
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Color(0xFF94A3B8),
                          size: 48,
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 180,
                      color: const Color(0xFFDCFCE7),
                      child: const Icon(
                        Icons.sports_soccer_outlined,
                        color: Color(0xFF22C55E),
                        size: 64,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          field.type,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Rp ${field.price.toString()}/jam',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

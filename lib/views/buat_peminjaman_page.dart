import 'package:flutter/material.dart';
import 'package:inventory_apps/widgets/form/build_form_field.dart';

class BuatPeminjamanPage extends StatefulWidget {
  const BuatPeminjamanPage({super.key});
  @override
  State<BuatPeminjamanPage> createState() => _BuatPeminjamanPageState();
}

class _BuatPeminjamanPageState extends State<BuatPeminjamanPage> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final jumlahController = TextEditingController();

  // Data barang dari API (simulasi GET /items)
  final List<Map<String, dynamic>> _itemList = [
    {'id': 1, 'name': 'Laptop Dell XPS 15'},
    {'id': 2, 'name': 'Proyektor Epson EB-X51'},
    {'id': 3, 'name': 'Kamera Canon EOS M50'},
    {'id': 4, 'name': 'Tripod Profesional'},
    {'id': 5, 'name': 'Mic Wireless Boya'},
    {'id': 6, 'name': 'Speaker JBL Portable'},
    {'id': 7, 'name': 'Whiteboard 120x240'},
    {'id': 8, 'name': 'Mouse Logitech MX'},
  ];

  int? _selectedItemId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    namaController.dispose();
    jumlahController.dispose();
    super.dispose();
  }

  /// Membuka Date Picker untuk memilih tanggal peminjaman
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Format tanggal untuk ditampilkan
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  /// Format tanggal untuk API (yyyy-MM-dd)
  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Mengirim data peminjaman dan menampilkan dialog sukses
  void _submitPeminjaman() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Pilih barang terlebih dahulu!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Data yang siap dikirim ke API
    final apiData = {
      'item_id': _selectedItemId,
      'qty': int.tryParse(jumlahController.text) ?? 0,
      'date': _formatDateForApi(_selectedDate),
    };

    debugPrint('API Data: $apiData');

    // Nama barang untuk ditampilkan di dialog sukses
    final selectedItemName = _itemList.firstWhere(
      (item) => item['id'] == _selectedItemId,
    )['name'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Peminjaman Berhasil!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              '$selectedItemName berhasil dipinjamkan kepada ${namaController.text}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Kembali ke Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF475569)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Buat Peminjaman',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header illustration
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Form Peminjaman Baru',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Isi data di bawah untuk mencatat peminjaman barang',
                                    style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Form fields
                      const Text(
                        'Informasi Peminjam',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 14),

                      // Nama Peminjam
                      buildFormField(
                        controller: namaController,
                        label: 'Nama Peminjam',
                        icon: Icons.person_outline_rounded,
                        validator: (value) => value == null || value.isEmpty ? 'Nama peminjam wajib diisi' : null,
                      ),
                      const SizedBox(height: 14),

                      // Dropdown Nama Barang (item_id)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x08000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedItemId,
                          decoration: InputDecoration(
                            labelText: 'Pilih Barang',
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 14, right: 10),
                              child: Icon(Icons.inventory_2_outlined, color: Color(0xFF94A3B8), size: 22),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFEF4444)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) => value == null ? 'Pilih barang wajib diisi' : null,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          items: _itemList.map((item) {
                            return DropdownMenuItem<int>(
                              value: item['id'] as int,
                              child: Text(
                                item['name'] as String,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedItemId = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Jumlah Unit
                      buildFormField(
                        controller: jumlahController,
                        label: 'Jumlah Unit',
                        icon: Icons.numbers,
                        isNumber: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Jumlah wajib diisi';
                          if (int.tryParse(value) == null) return 'Masukkan angka yang valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Tanggal Peminjaman (Date Picker)
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x08000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(Icons.calendar_month_rounded, color: Color(0xFF94A3B8), size: 22),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tanggal Peminjaman',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(_selectedDate),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Ubah',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _submitPeminjaman,
                          icon: const Icon(Icons.send_rounded),
                          label: const Text(
                            'Kirim Peminjaman',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

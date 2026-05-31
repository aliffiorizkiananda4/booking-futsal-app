import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_apps/models/item_model.dart';
import 'package:inventory_apps/services/item_service.dart';
import 'package:inventory_apps/widgets/form/build_text_field.dart';

class DataBarangPage extends StatefulWidget {
  const DataBarangPage({super.key});

  @override
  State<DataBarangPage> createState() => _DataBarangPageState();
}

class _DataBarangPageState extends State<DataBarangPage> {
  final ImagePicker _picker = ImagePicker();
  final ItemService _apiService = ItemService();

  int _totalItem = 0;
  late Future<List<ItemModel>> _itemFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _itemFuture = _apiService.getItems().then((items) {
        setState(() => _totalItem = items.length);
        return items;
      });
    });
  }

  void _showBarangFormDialog({ItemModel? barang}) {
    final isEdit = barang != null;

    final namaController = TextEditingController(text: barang?.name ?? '');
    final stokController = TextEditingController(text: barang?.stock.toString() ?? '');

    XFile? selectedImage; // <-- XFile bukan File atau String
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (bottomSheetContext, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isEdit ? 'Edit Barang' : 'Tambah Barang',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  buildTextField(namaController, 'Nama Barang *', Icons.inventory_2_outlined),
                  const SizedBox(height: 14),
                  buildTextField(stokController, 'Jumlah Stok *', Icons.numbers, isNumber: true),
                  const SizedBox(height: 14),

                  // Image picker
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await _picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1024,
                        maxHeight: 1024,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setModalState(() => selectedImage = image);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selectedImage != null
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
                          width: selectedImage != null ? 2 : 1,
                        ),
                      ),
                      child: selectedImage != null
                          // Preview gambar baru yang dipilih
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  kIsWeb
                                      ? Image.network(selectedImage!.path, fit: BoxFit.cover)
                                      : Image.file(File(selectedImage!.path), fit: BoxFit.cover),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          // Preview dari URL jika edit dan belum pilih gambar baru
                          : (isEdit && barang.imageurl != null)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        barang.imageurl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.broken_image_outlined,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.add_photo_alternate_outlined,
                                        color: Color(0xFF2563EB),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Pilih Gambar dari Galeri *',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'JPG, PNG (Maks 1MB)',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                    ),
                                  ],
                                ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (namaController.text.trim().isEmpty) {
                          _showValidationSnackBar(context, 'Nama barang wajib diisi!');
                          return;
                        }
                        if (stokController.text.trim().isEmpty ||
                            int.tryParse(stokController.text.trim()) == null) {
                          _showValidationSnackBar(context, 'Jumlah stok wajib diisi dengan angka!');
                          return;
                        }
                        if (!isEdit && selectedImage == null) {
                          _showValidationSnackBar(context, 'Gambar wajib dipilih!');
                          return;
                        }

                        try {
                          if (isEdit) {
                            await _apiService.updateItem(
                              barang.id,
                              namaController.text.trim(),
                              stokController.text.trim(),
                              selectedImage,
                              barang.imageurl,
                            );
                          } else {
                            await _apiService.postItem(
                              namaController.text.trim(),
                              stokController.text.trim(),
                              selectedImage, // <-- XFile? langsung, TANPA as File?
                            );
                          }

                          if (context.mounted) {
                            Navigator.pop(bottomSheetContext);
                            _refreshData();
                            _showSuccessSnackBar(
                              context,
                              isEdit ? 'Barang berhasil diperbarui!' : 'Barang berhasil ditambahkan!',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(bottomSheetContext);
                            _showValidationSnackBar(context, 'Gagal: ${e.toString()}');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        isEdit ? 'Simpan Perubahan' : 'Tambah Barang',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(ItemModel item) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hapus Barang?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              Text(
                'Barang "${item.name}" akan dihapus permanen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        try {
                          await _apiService.deleteItem(item.id);
                          _refreshData();
                          if (context.mounted) {
                            _showSuccessSnackBar(context, 'Barang berhasil dihapus!');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            _showValidationSnackBar(context, 'Gagal menghapus: ${e.toString()}');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showValidationSnackBar(BuildContext ctx, String message) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext ctx, String message) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Data Barang',
          style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B), fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2563EB)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBarangFormDialog(),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Barang', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<List<ItemModel>>(
        future: _itemFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 64, color: Color(0xFFCBD5E1)),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat data',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
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
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.inventory_2_outlined, size: 40, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada barang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap tombol + untuk menambah barang',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                color: Colors.white,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2_rounded, size: 14, color: Color(0xFF2563EB)),
                          const SizedBox(width: 6),
                          Text(
                            '$_totalItem Barang',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _refreshData,
                      child: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B), size: 20),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _buildItemCard(items[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItemCard(ItemModel item) {
    final isStokHabis = item.stock == 0;
    final isStokRendah = item.stock > 0 && item.stock <= 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageurl != null
                  ? Image.network(
                      item.imageurl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 70,
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(Icons.broken_image_outlined, color: Color(0xFF94A3B8)),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: const Color(0xFFEFF6FF),
                      child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF2563EB), size: 30),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isStokHabis
                              ? const Color(0xFFFEE2E2)
                              : isStokRendah
                                  ? const Color(0xFFFEF3C7)
                                  : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isStokHabis ? 'Habis' : isStokRendah ? 'Stok Rendah' : 'Tersedia',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isStokHabis
                                ? const Color(0xFFEF4444)
                                : isStokRendah
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF22C55E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Stok: ${item.stock}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () => _showBarangFormDialog(barang: item),
                  icon: const Icon(Icons.edit_rounded, color: Color(0xFF2563EB), size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFEFF6FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 6),
                IconButton(
                  onPressed: () => _showDeleteDialog(item),
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE2E2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

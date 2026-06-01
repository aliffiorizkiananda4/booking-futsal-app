import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_apps/models/field_model.dart';
import 'package:inventory_apps/services/field_service.dart';

class FieldManagementPage extends StatefulWidget {
  const FieldManagementPage({super.key});

  @override
  State<FieldManagementPage> createState() => _FieldManagementPageState();
}

class _FieldManagementPageState extends State<FieldManagementPage> {
  final FieldService _fieldService = FieldService();
  late Future<List<FieldModel>> _fieldsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Refresh data when the page becomes visible again
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Force refresh when navigating back to this page
    // This ensures new data from database is shown
  }

  void _refreshData() {
    setState(() {
      _fieldsFuture = _fieldService.getFields();
    });
  }

  Future<void> _onRefresh() async {
    try {
      final fields = await _fieldService.getFields();
      if (mounted) {
        setState(() {
          _fieldsFuture = Future.value(fields);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  void _showAddEditDialog({FieldModel? field}) {
    final isEdit = field != null;
    final nameController = TextEditingController(text: field?.name ?? '');
    final typeController = TextEditingController(text: field?.type ?? '');
    final priceController = TextEditingController(
      text: field?.price.toString() ?? '',
    );
    final descController = TextEditingController(
      text: field?.description ?? '',
    );
    XFile? selectedImage;
    Uint8List? imageBytes;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Lapangan' : 'Tambah Lapangan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lapangan',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Tipe (Vinyl/Rumput Sintetis/Parket)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga per Jam',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (imageBytes != null)
                  Image.memory(imageBytes!, height: 100, fit: BoxFit.cover),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      final bytes = await image.readAsBytes();
                      setDialogState(() {
                        selectedImage = image;
                        imageBytes = bytes;
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Pilih Gambar'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    typeController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua field wajib diisi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                bool success;
                if (isEdit) {
                  success = await _fieldService.updateField(
                    field.id,
                    nameController.text,
                    typeController.text,
                    priceController.text,
                    descController.text,
                    selectedImage,
                  );
                } else {
                  success = await _fieldService.postField(
                    nameController.text,
                    typeController.text,
                    priceController.text,
                    descController.text,
                    selectedImage,
                  );
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? isEdit
                                  ? 'Lapangan berhasil diupdate'
                                  : 'Lapangan berhasil ditambahkan'
                            : 'Gagal menyimpan lapangan',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                  if (success) _refreshData();
                }
              },
              child: Text(isEdit ? 'Update' : 'Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(FieldModel field) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus ${field.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await _fieldService.deleteField(field.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Lapangan berhasil dihapus'
                          : 'Gagal menghapus lapangan',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success) _refreshData();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Kelola Lapangan',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFFEF4444),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFFEF4444),
        child: FutureBuilder<List<FieldModel>>(
          future: _fieldsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFEF4444)),
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

            final fields = snapshot.data ?? [];

            if (fields.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Belum ada lapangan'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Lapangan'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: fields.length,
              itemBuilder: (context, index) {
                final field = fields[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: field.image != null
                        ? Image.network(
                            field.image!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.sports_soccer, size: 40),
                          )
                        : const Icon(Icons.sports_soccer, size: 40),
                    title: Text(
                      field.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${field.type} - Rp ${field.price}/jam'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddEditDialog(field: field),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(field),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFFEF4444),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

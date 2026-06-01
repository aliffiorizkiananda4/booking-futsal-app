import 'package:flutter/material.dart';
import 'package:inventory_apps/models/field_model.dart';
import 'package:inventory_apps/models/schedule_model.dart';
import 'package:inventory_apps/services/field_service.dart';
import 'package:inventory_apps/services/schedule_service.dart';

class ScheduleManagementPage extends StatefulWidget {
  const ScheduleManagementPage({super.key});

  @override
  State<ScheduleManagementPage> createState() => _ScheduleManagementPageState();
}

class _ScheduleManagementPageState extends State<ScheduleManagementPage> {
  final ScheduleService _scheduleService = ScheduleService();
  final FieldService _fieldService = FieldService();
  late Future<List<ScheduleModel>> _schedulesFuture;
  List<FieldModel> _fields = [];

  @override
  void initState() {
    super.initState();
    _loadFields();
    _refreshData();
  }

  // Refresh data when the page becomes visible again
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Force refresh when navigating back to this page
    // This ensures new data from database is shown
  }

  Future<void> _loadFields() async {
    try {
      final fields = await _fieldService.getFields();
      setState(() {
        _fields = fields;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _refreshData() {
    setState(() {
      _schedulesFuture = _scheduleService.getSchedules();
    });
  }

  Future<void> _onRefresh() async {
    try {
      final schedules = await _scheduleService.getSchedules();
      if (mounted) {
        setState(() {
          _schedulesFuture = Future.value(schedules);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  void _showAddEditDialog({ScheduleModel? schedule}) {
    final isEdit = schedule != null;
    int? selectedFieldId = schedule?.fieldId;
    DateTime selectedDate = schedule != null
        ? DateTime.parse(schedule.date)
        : DateTime.now();
    TimeOfDay startTime = schedule != null
        ? TimeOfDay(
            hour: int.parse(schedule.startTime.split(':')[0]),
            minute: int.parse(schedule.startTime.split(':')[1]),
          )
        : const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = schedule != null
        ? TimeOfDay(
            hour: int.parse(schedule.endTime.split(':')[0]),
            minute: int.parse(schedule.endTime.split(':')[1]),
          )
        : const TimeOfDay(hour: 10, minute: 0);
    bool isAvailable = schedule?.isAvailable ?? true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Jadwal' : 'Tambah Jadwal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedFieldId,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Lapangan',
                    border: OutlineInputBorder(),
                  ),
                  items: _fields.map((field) {
                    return DropdownMenuItem(
                      value: field.id,
                      child: Text(field.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedFieldId = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Tanggal'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Jam Mulai'),
                  subtitle: Text(startTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (time != null) {
                      setDialogState(() {
                        startTime = time;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Jam Selesai'),
                  subtitle: Text(endTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (time != null) {
                      setDialogState(() {
                        endTime = time;
                      });
                    }
                  },
                ),
                SwitchListTile(
                  title: const Text('Tersedia'),
                  value: isAvailable,
                  onChanged: (value) {
                    setDialogState(() {
                      isAvailable = value;
                    });
                  },
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
                if (selectedFieldId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pilih lapangan terlebih dahulu'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                final newSchedule = ScheduleModel(
                  id: schedule?.id ?? 0,
                  fieldId: selectedFieldId!,
                  date:
                      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                  startTime:
                      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                  endTime:
                      '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                  isAvailable: isAvailable,
                );

                bool success;
                if (isEdit) {
                  success = await _scheduleService.updateSchedule(
                    schedule.id,
                    newSchedule,
                  );
                } else {
                  success = await _scheduleService.createSchedule(newSchedule);
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? isEdit
                                  ? 'Jadwal berhasil diupdate'
                                  : 'Jadwal berhasil ditambahkan'
                            : 'Gagal menyimpan jadwal',
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

  void _confirmDelete(ScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus jadwal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await _scheduleService.deleteSchedule(
                schedule.id,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Jadwal berhasil dihapus'
                          : 'Gagal menghapus jadwal',
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
          'Kelola Jadwal',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFF0EA5E9),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF0EA5E9),
        child: FutureBuilder<List<ScheduleModel>>(
          future: _schedulesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
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

            final schedules = snapshot.data ?? [];

            if (schedules.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Belum ada jadwal'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Jadwal'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: schedule.isAvailable
                          ? Colors.green
                          : Colors.grey,
                      child: Icon(
                        schedule.isAvailable ? Icons.check : Icons.close,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      schedule.fieldName ?? 'Lapangan #${schedule.fieldId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${schedule.date}\n${schedule.startTime} - ${schedule.endTime}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddEditDialog(schedule: schedule),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(schedule),
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
        backgroundColor: const Color(0xFF0EA5E9),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

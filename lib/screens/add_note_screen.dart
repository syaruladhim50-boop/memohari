import 'dart:io';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../database/database_helper.dart';
import '../utils/notification_service.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note;
  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();

  DateTime? _selectedReminderTime;
  bool _hasReminder = false;

  @override
  void initState() {
    super.initState();
    _notificationService.init();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedReminderTime = widget.note!.reminderTime;
      _hasReminder = widget.note!.reminderTime != null;
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedReminderTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedReminderTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedReminderTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _hasReminder = true;
        });
      }
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tidak boleh kosong')),
      );
      return;
    }

    int? notificationId;
    if (_hasReminder && _selectedReminderTime != null) {
      notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      try {
        await _notificationService.scheduleNotification(
          id: notificationId,
          title: 'Reminder: ${_titleController.text}',
          body: _contentController.text.isNotEmpty
              ? _contentController.text
              : 'Waktunya mengingat catatan Anda',
          scheduledTime: _selectedReminderTime!,
        );
        
        // Tampilkan pesan sukses di Windows
        if (Platform.isWindows) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengingat disimpan (notifikasi hanya berjalan di HP)')),
          );
        }
      } catch (e) {
        print('Error schedule notification: $e');
      }
    }

    final note = Note(
      id: widget.note?.id,
      title: _titleController.text,
      content: _contentController.text,
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      reminderTime: _hasReminder ? _selectedReminderTime : null,
      notificationId: notificationId,
    );

    if (widget.note == null) {
      int newId = await _dbHelper.insertNote(note);
      if (notificationId != null) {
        await _dbHelper.updateNotificationId(newId, notificationId);
      }
    } else {
      await _dbHelper.updateNote(note);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Tambah Catatan' : 'Edit Catatan'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul',
                hintText: 'Masukkan judul catatan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Isi Catatan',
                hintText: 'Tulis sesuatu...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: SwitchListTile(
                title: const Text('Setel Pengingat'),
                subtitle: _hasReminder && _selectedReminderTime != null
                    ? Text('${_selectedReminderTime!.day}/${_selectedReminderTime!.month}/${_selectedReminderTime!.year} ${_selectedReminderTime!.hour}:${_selectedReminderTime!.minute.toString().padLeft(2, '0')}')
                    : const Text('Belum ada pengingat'),
                value: _hasReminder,
                onChanged: (value) {
                  if (value && _selectedReminderTime == null) {
                    _selectDateTime();
                  } else if (!value) {
                    setState(() {
                      _hasReminder = false;
                      _selectedReminderTime = null;
                    });
                  } else {
                    _selectDateTime();
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveNote,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
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
  String _selectedTag = 'General';

  @override
  void initState() {
    super.initState();
    _notificationService.init();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedReminderTime = widget.note!.reminderTime;
      _hasReminder = widget.note!.reminderTime != null;
      _selectedTag = widget.note!.tag;
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedReminderTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00FF88), // header background color
              onPrimary: Colors.black, // header text color
              surface: Color(0xFF151515), // background of dialog
              onSurface: Color(0xFFF5F5F5), // body text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedReminderTime ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF00FF88),
                onPrimary: Colors.black,
                surface: Color(0xFF151515),
                onSurface: Color(0xFFF5F5F5),
              ),
            ),
            child: child!,
          );
        },
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
        const SnackBar(
          content: Text('Judul tidak boleh kosong'),
          backgroundColor: Color(0xFFCF6679),
        ),
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
        
        if (Platform.isWindows) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Pengingat disimpan (notifikasi hanya berjalan di HP)',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Color(0xFF00FF88),
            ),
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
      tag: _selectedTag,
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
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: Text(
          widget.note == null ? 'TAMBAH CATATAN' : 'EDIT CATATAN',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Color(0xFFF5F5F5), fontSize: 16),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Judul',
                labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                hintText: 'Masukkan judul catatan',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF151515),
                prefixIcon: const Icon(Icons.title_rounded, color: Color(0xFF00FF88)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content Input
            TextField(
              controller: _contentController,
              style: const TextStyle(color: Color(0xFFF5F5F5), fontSize: 16),
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Isi Catatan',
                alignLabelWithHint: true,
                labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                hintText: 'Tulis sesuatu yang menarik hari ini...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF151515),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 120),
                  child: Icon(Icons.description_rounded, color: Color(0xFF00FF88)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tag Selector Section
            const Text(
              'Pilih Tag / Folder',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['General', 'Work', 'Personal', 'Ideas'].map((tag) {
                  final isSelected = _selectedTag == tag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        tag,
                        style: TextStyle(
                          color: isSelected ? Colors.black : const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedTag = tag;
                          });
                        }
                      },
                      selectedColor: const Color(0xFF00FF88),
                      backgroundColor: const Color(0xFF151515),
                      checkmarkColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF00FF88) : Colors.white.withOpacity(0.04),
                          width: 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Reminder Switch Card
            Card(
              color: const Color(0xFF151515),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.04),
                  width: 1,
                ),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SwitchListTile(
                  activeColor: const Color(0xFF00FF88),
                  activeTrackColor: const Color(0xFF00FF88).withOpacity(0.3),
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade800,
                  title: const Text(
                    'Setel Pengingat',
                    style: TextStyle(
                      color: Color(0xFFF5F5F5),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: _hasReminder && _selectedReminderTime != null
                      ? Text(
                          '${_selectedReminderTime!.day}/${_selectedReminderTime!.month}/${_selectedReminderTime!.year} ${_selectedReminderTime!.hour}:${_selectedReminderTime!.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.w600),
                        )
                      : const Text(
                          'Belum ada pengingat aktif',
                          style: TextStyle(color: Color(0xFF9CA3AF)),
                        ),
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
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _saveNote,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: const Color(0xFF00FF88),
                foregroundColor: Colors.black,
                shadowColor: const Color(0xFF00FF88).withOpacity(0.3),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_rounded, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(
                    widget.note == null ? 'Simpan Catatan' : 'Simpan Perubahan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
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
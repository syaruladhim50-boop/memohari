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
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Theme(
          data: theme.copyWith(
            colorScheme: isDark 
                ? const ColorScheme.dark(
                    primary: Color(0xFF00FF88), // header background color
                    onPrimary: Colors.black, // header text color
                    surface: Color(0xFF151515), // background of dialog
                    onSurface: Color(0xFFF5F5F5), // body text color
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF1DB954), // header background color
                    onPrimary: Colors.white, // header text color
                    surface: Colors.white, // background of dialog
                    onSurface: Color(0xFF1F1F1F), // body text color
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
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          return Theme(
            data: theme.copyWith(
              colorScheme: isDark
                  ? const ColorScheme.dark(
                      primary: Color(0xFF00FF88),
                      onPrimary: Colors.black,
                      surface: Color(0xFF151515),
                      onSurface: Color(0xFFF5F5F5),
                    )
                  : const ColorScheme.light(
                      primary: Color(0xFF1DB954),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Color(0xFF1F1F1F),
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
        SnackBar(
          content: const Text('Judul tidak boleh kosong'),
          backgroundColor: Theme.of(context).colorScheme.error,
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
            SnackBar(
              content: Text(
                'Pengingat disimpan (notifikasi hanya berjalan di HP)',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
              style: TextStyle(color: isDark ? const Color(0xFFF5F5F5) : Colors.black87, fontSize: 16),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Judul',
                labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.black54),
                hintText: 'Masukkan judul catatan',
                hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
                filled: true,
                fillColor: theme.colorScheme.surface,
                prefixIcon: Icon(Icons.title_rounded, color: theme.colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content Input
            TextField(
              controller: _contentController,
              style: TextStyle(color: isDark ? const Color(0xFFF5F5F5) : Colors.black87, fontSize: 16),
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Isi Catatan',
                alignLabelWithHint: true,
                labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.black54),
                hintText: 'Tulis sesuatu yang menarik hari ini...',
                hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
                filled: true,
                fillColor: theme.colorScheme.surface,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Icon(Icons.description_rounded, color: theme.colorScheme.primary),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tag Selector Section
            Text(
              'Pilih Tag / Folder',
              style: TextStyle(
                color: isDark ? const Color(0xFF9CA3AF) : Colors.black54,
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
                          color: isSelected 
                              ? (isDark ? Colors.black : Colors.white) 
                              : (isDark ? const Color(0xFF9CA3AF) : Colors.black54),
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
                      selectedColor: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.surface,
                      checkmarkColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected 
                              ? theme.colorScheme.primary 
                              : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04)),
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
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                  width: 1,
                ),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SwitchListTile(
                  activeColor: theme.colorScheme.primary,
                  activeTrackColor: theme.colorScheme.primary.withOpacity(0.3),
                  inactiveThumbColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  inactiveTrackColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  title: Text(
                    'Setel Pengingat',
                    style: TextStyle(
                      color: isDark ? const Color(0xFFF5F5F5) : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: _hasReminder && _selectedReminderTime != null
                      ? Text(
                          '${_selectedReminderTime!.day}/${_selectedReminderTime!.month}/${_selectedReminderTime!.year} ${_selectedReminderTime!.hour}:${_selectedReminderTime!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                        )
                      : Text(
                          'Belum ada pengingat aktif',
                          style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.black54),
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
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shadowColor: theme.colorScheme.primary.withOpacity(0.3),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, color: theme.colorScheme.onPrimary),
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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/note.dart';
import 'add_note_screen.dart';
import '../utils/settings_manager.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm');
  
  Map<String, List<Note>> _notesByTag = {
    'General': [],
    'Work': [],
    'Personal': [],
    'Ideas': [],
  };
  
  String? _selectedTagFilter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await _dbHelper.getNotes();
    
    // Group notes by tags
    final Map<String, List<Note>> grouped = {
      'General': [],
      'Work': [],
      'Personal': [],
      'Ideas': [],
    };

    for (var note in notes) {
      if (grouped.containsKey(note.tag)) {
        grouped[note.tag]!.add(note);
      } else {
        // Safe fallback for tags not in preset list
        grouped[note.tag] = [note];
      }
    }

    setState(() {
      _notesByTag = grouped;
      _isLoading = false;
    });
  }

  Future<void> _deleteNote(int id) async {
    await _dbHelper.deleteNote(id);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    // Determine which notes to display
    List<Note> displayedNotes = [];
    if (_selectedTagFilter != null) {
      displayedNotes = _notesByTag[_selectedTagFilter] ?? [];
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _selectedTagFilter == null ? 'FOLDER & TAGS' : 'TAG: ${_selectedTagFilter!.toUpperCase()}',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 2.0,
            color: theme.colorScheme.primary,
          ),
        ),
        leading: _selectedTagFilter != null
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87, size: 20),
                onPressed: () {
                  setState(() {
                    _selectedTagFilter = null;
                  });
                },
              )
            : null,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : RefreshIndicator(
              onRefresh: _loadNotes,
              color: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surface,
              strokeWidth: 2.5,
              child: _selectedTagFilter == null
                  ? _buildFolderGrid()
                  : _buildFilteredNoteList(displayedNotes),
            ),
    );
  }

  Widget _buildFolderGrid() {
    final tags = ['General', 'Work', 'Personal', 'Ideas'];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Icon mapping for each tag
    final Map<String, IconData> tagIcons = {
      'General': Icons.folder_rounded,
      'Work': Icons.work_outline_rounded,
      'Personal': Icons.person_outline_rounded,
      'Ideas': Icons.lightbulb_outline_rounded,
    };

    // Color indicators
    final Map<String, Color> tagColors = {
      'General': theme.colorScheme.primary,
      'Work': const Color(0xFF1DB954),
      'Personal': Colors.purpleAccent,
      'Ideas': Colors.amberAccent,
    };

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori Catatan',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kelola catatan berdasarkan folder dan tag.',
            style: TextStyle(
              color: isDark ? const Color(0xFF9CA3AF) : Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              final count = _notesByTag[tag]?.length ?? 0;
              final color = tagColors[tag]!;
              final icon = tagIcons[tag]!;

              final settings = SettingsManager.instance;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedTagFilter = tag;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                      width: 1,
                    ),
                    boxShadow: settings.glowEffects && isDark
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tag,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$count Catatan',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF9CA3AF) : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredNoteList(List<Note> notes) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 48,
                color: isDark ? const Color(0xFF9CA3AF) : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Folder Kosong',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada catatan dengan tag ini.',
              style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.black54, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final hasReminder = note.reminderTime != null;
        
        final settings = SettingsManager.instance;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
              width: 1,
            ),
            boxShadow: settings.glowEffects && isDark
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 6,
                    color: theme.colorScheme.primary,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddNoteScreen(note: note),
                          ),
                        ).then((_) => _loadNotes());
                      },
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Expanded(
                                    child: Text(
                                      note.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: isDark ? const Color(0xFFF5F5F5) : Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: theme.colorScheme.surface,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            title: Text('Hapus Catatan', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                                            content: Text('Apakah Anda yakin ingin menghapus catatan ini?', style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.black54)),
                                            actions: [
                                              TextButton(
                                                child: Text('Batal', style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.black54)),
                                                onPressed: () => Navigator.of(context).pop(),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: theme.colorScheme.error,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  _deleteNote(note.id!);
                                                },
                                                child: const Text('Hapus'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              note.content,
                              style: TextStyle(
                                color: isDark ? const Color(0xFF9CA3AF) : Colors.black54,
                                fontSize: 14,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            Divider(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06), height: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: isDark ? const Color(0xFF9CA3AF) : Colors.black54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _dateFormat.format(note.createdAt),
                                      style: TextStyle(
                                        color: isDark ? const Color(0xFF9CA3AF) : Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                if (hasReminder)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.colorScheme.primary.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.notifications_active_outlined,
                                          size: 12,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Pengingat',
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

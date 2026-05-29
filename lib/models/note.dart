class Note {
  int? id;
  String title;
  String content;
  DateTime createdAt;
  DateTime? reminderTime;
  int? notificationId;
  String tag; // e.g., 'General', 'Work', 'Personal', 'Ideas'

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.reminderTime,
    this.notificationId,
    this.tag = 'General',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(),
      'notificationId': notificationId,
      'tag': tag,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      reminderTime: map['reminderTime'] != null
          ? DateTime.parse(map['reminderTime'])
          : null,
      notificationId: map['notificationId'],
      tag: map['tag'] ?? 'General',
    );
  }
}
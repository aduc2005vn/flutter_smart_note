import 'dart:convert';

class Note {
  String id;
  String title;
  String content;
  DateTime updatedAt;

  Note({required this.id, required this.title, required this.content, required this.updatedAt});

  factory Note.empty() => Note(id: DateTime.now().millisecondsSinceEpoch.toString(), title: '', content: '', updatedAt: DateTime.now());

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'updatedAt': updatedAt.toIso8601String(),
      };

  static List<Note> listFromJson(String jsonStr) {
    final d = jsonDecode(jsonStr) as List<dynamic>;
    return d.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<Note> notes) => jsonEncode(notes.map((e) => e.toJson()).toList());
}

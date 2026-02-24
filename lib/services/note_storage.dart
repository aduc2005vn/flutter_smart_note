import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteStorage {
  static const _kNotesKey = 'notes';

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_kNotesKey);
    if (data == null) return [];
    try {
      return Note.listFromJson(data);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final json = Note.listToJson(notes);
    await prefs.setString(_kNotesKey, json);
  }
}

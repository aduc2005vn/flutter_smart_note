import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_smart_note/models/note.dart';
import 'package:flutter_smart_note/services/note_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('save and load notes persist across simulated restart', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = NoteStorage();

    final note = Note(id: '1', title: 'Test', content: 'abc', updatedAt: DateTime.now());
    await storage.saveNotes([note]);

    // simulate restart by reading again from SharedPreferences
    final loaded = await storage.loadNotes();
    expect(loaded.length, 1);
    expect(loaded.first.title, 'Test');
  });
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/note_storage.dart';

class EditScreen extends StatefulWidget {
  final Note? note;

  const EditScreen({Key? key, this.note}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late Note _note;
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _storage = NoteStorage();

  @override
  void initState() {
    super.initState();
    _note = widget.note ?? Note.empty();
    _titleCtrl.text = _note.title;
    _contentCtrl.text = _note.content;
  }

  Future<void> _saveAndExit() async {
    _note.title = _titleCtrl.text.trim();
    _note.content = _contentCtrl.text.trim();
    _note.updatedAt = DateTime.now();

    final notes = await _storage.loadNotes();
    final index = notes.indexWhere((n) => n.id == _note.id);
    if (index >= 0) {
      notes[index] = _note;
    } else {
      notes.insert(0, _note);
    }
    await _storage.saveNotes(notes);
  }

  Future<bool> _onWillPop() async {
    await _saveAndExit();
    Navigator.of(context).pop(true);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Soạn ghi chú'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleCtrl,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Tiêu đề',
                  border: InputBorder.none,
                ),
                maxLines: 1,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(_note.updatedAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: _contentCtrl,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Nội dung ghi chú...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

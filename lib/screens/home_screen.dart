import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/note.dart';
import '../services/note_storage.dart';
import 'edit_screen.dart';

class HomeScreen extends StatefulWidget {
  final String studentName;
  final String studentId;

  const HomeScreen({Key? key, required this.studentName, required this.studentId}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = NoteStorage();
  List<Note> _notes = [];
  List<Note> _filtered = [];
  final _searchCtrl = TextEditingController();
  final List<Color> _cardColors = [
    Colors.white,
    Colors.amberAccent.shade100,
    Colors.lightBlue.shade50,
    Colors.greenAccent.shade100,
    Colors.pinkAccent.shade100,
    Colors.orange.shade50,
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(() {
      _applyFilter(_searchCtrl.text);
    });
  }

  Future<void> _load() async {
    final notes = await _storage.loadNotes();
    setState(() {
      _notes = notes;
      _applyFilter(_searchCtrl.text);
    });
  }

  void _applyFilter(String q) {
    setState(() {
      if (q.trim().isEmpty) {
        _filtered = List.from(_notes);
      } else {
        final qq = q.toLowerCase();
        _filtered = _notes.where((n) => n.title.toLowerCase().contains(qq)).toList();
      }
    });
  }

  Future<bool> _confirmDelete(Note note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
        ],
      ),
    );
    return ok == true;
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/empty.svg', width: 160, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text('Bạn chưa có ghi chú nào, hãy tạo mới nhé!', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Smart Note - ${widget.studentName} - ${widget.studentId}';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Tìm kiếm theo tiêu đề...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty ? _buildEmpty() : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final note = _filtered[index];
                  return Dismissible(
                    key: Key(note.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      return await _confirmDelete(note);
                    },
                    onDismissed: (_) async {
                      _notes.removeWhere((n) => n.id == note.id);
                      await _storage.saveNotes(_notes);
                      _applyFilter(_searchCtrl.text);
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditScreen(note: note)));
                        if (res == true) await _load();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _cardColors[note.id.hashCode % _cardColors.length],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(note.title.isEmpty ? '(Không có tiêu đề)' : note.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Text(note.content, style: TextStyle(color: Colors.grey[800]), maxLines: 3, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 12),
                              Align(alignment: Alignment.bottomRight, child: Text(DateFormat('dd/MM/yyyy HH:mm').format(note.updatedAt), style: TextStyle(fontSize: 11, color: Colors.grey[600]))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditScreen()));
          if (res == true) await _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

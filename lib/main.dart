import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(const SmartNoteApp());
}

class SmartNoteApp extends StatelessWidget {
  const SmartNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Note - Vũ Anh Đức - 2351060432',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      home: HomeScreen(studentName: 'Vũ Anh Đức', studentId: '2351060432'),
    );
  }
}

// --- MODEL ---
class Note {
  String id;
  String title;
  String content;
  DateTime modifiedTime;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.modifiedTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'modifiedTime': modifiedTime.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        modifiedTime: DateTime.parse(json['modifiedTime']),
      );
}

// --- MÀN HÌNH CHÍNH ---
class HomeScreen extends StatefulWidget {
  final String studentName;
  final String studentId;

  const HomeScreen({super.key, required this.studentName, required this.studentId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> allNotes = [];
  List<Note> filteredNotes = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Đọc dữ liệu từ SharedPreferences
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList('smart_notes');
    if (jsonList != null) {
      setState(() {
        allNotes = jsonList.map((item) => Note.fromJson(jsonDecode(item))).toList();
        // Sắp xếp ghi chú mới nhất lên đầu
        allNotes.sort((a, b) => b.modifiedTime.compareTo(a.modifiedTime));
        filteredNotes = allNotes;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  // Lưu dữ liệu
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = allNotes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList('smart_notes', jsonList);
  }

  // Bộ lọc tìm kiếm
  void _onSearchChanged(String query) {
    setState(() {
      filteredNotes = allNotes
          .where((note) => note.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Xóa ghi chú
  void _deleteNote(int index) {
    setState(() {
      allNotes.removeWhere((element) => element.id == filteredNotes[index].id);
      filteredNotes.removeAt(index);
    });
    _saveToStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Smart Note',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.studentName} - ${widget.studentId}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Tìm kiếm ghi chú...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Danh sách Ghi chú
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredNotes.isEmpty
                    ? _buildEmptyState()
                    : _buildNoteGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteDetail(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            "Bạn chưa có ghi chú nào, hãy tạo mới nhé!",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          return Dismissible(
            key: Key(note.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) => _confirmDelete(context),
            onDismissed: (_) => _deleteNote(index),
            background: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: GestureDetector(
              onTap: () => _openNoteDetail(note),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title.isEmpty ? "Không có tiêu đề" : note.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        note.content,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(note.modifiedTime),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa ghi chú này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("HỦY")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("XÓA", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _openNoteDetail(Note? note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(note: note)),
    );
    _loadNotes(); // Reload lại sau khi quay về
  }
}

// --- MÀN HÌNH CHI TIẾT / SOẠN THẢO ---
class DetailScreen extends StatefulWidget {
  final Note? note;
  const DetailScreen({super.key, this.note});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String originalTitle;
  late String originalContent;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? "");
    _contentController = TextEditingController(text: widget.note?.content ?? "");
    originalTitle = _titleController.text;
    originalContent = _contentController.text;
  }

  // Hàm tự động lưu
  Future<void> _autoSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Nếu không có thay đổi hoặc trắng cả 2 thì không lưu
    if (title == originalTitle && content == originalContent) return;
    if (title.isEmpty && content.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('smart_notes') ?? [];
    List<Note> notes = jsonList.map((item) => Note.fromJson(jsonDecode(item))).toList();

    if (widget.note == null) {
      // Tạo mới
      notes.add(Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        modifiedTime: DateTime.now(),
      ));
    } else {
      // Cập nhật
      int index = notes.indexWhere((element) => element.id == widget.note!.id);
      if (index != -1) {
        notes[index].title = title;
        notes[index].content = content;
        notes[index].modifiedTime = DateTime.now();
      }
    }

    final newJsonList = notes.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList('smart_notes', newJsonList);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) await _autoSave();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.note == null ? 'Tạo ghi chú mới' : 'Chỉnh sửa ghi chú'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: "Tiêu đề",
                  border: InputBorder.none,
                ),
              ),
              const Divider(),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: "Bắt đầu viết...",
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

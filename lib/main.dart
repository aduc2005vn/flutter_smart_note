import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SmartNoteApp());
}

class SmartNoteApp extends StatelessWidget {
  const SmartNoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Note',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(studentName: 'Vũ Anh Đức', studentId: '2351060432'),
    );
  }
}

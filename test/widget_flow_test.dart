import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_smart_note/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('create note, persist and delete with confirmation', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartNoteApp());
    await tester.pumpAndSettle();

    // Tap FAB to create
    final fab = find.byIcon(Icons.add);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Enter title and content
    final titleField = find.byType(TextField).at(0);
    final contentField = find.byType(TextField).at(1);
    await tester.enterText(titleField, 'Ghi chú test');
    await tester.enterText(contentField, 'Nội dung test');

    // Simulate Back to trigger auto-save
    await tester.pageBack();
    await tester.pumpAndSettle();

    // The note should appear on home screen
    expect(find.text('Ghi chú test'), findsOneWidget);

    // Restart app (simulate app restart) and ensure persistence
    await tester.pumpWidget(Container());
    await tester.pumpWidget(const SmartNoteApp());
    await tester.pumpAndSettle();
    expect(find.text('Ghi chú test'), findsOneWidget);

    // Delete the note by swiping left (Dismissible)
    final noteTitle = find.text('Ghi chú test');
    expect(noteTitle, findsOneWidget);
    final dismissible = find.ancestor(of: noteTitle, matching: find.byType(Dismissible));
    expect(dismissible, findsOneWidget);

    // perform drag to reveal delete and trigger confirm dialog
    await tester.drag(dismissible, const Offset(-400, 0));
    await tester.pumpAndSettle();

    // Confirm dialog appears
    expect(find.text('Bạn có chắc chắn muốn xóa ghi chú này không?'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Note should be removed
    expect(find.text('Ghi chú test'), findsNothing);
  });
}

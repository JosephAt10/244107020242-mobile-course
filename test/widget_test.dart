import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 1. Double check that this path accurately points to your main.dart file
import '../lib/main.dart'; 

void main() {
  testWidgets('Student Profile UI Smoke Test', (WidgetTester tester) async {
    // 2. Build our actual Student Profile App widget instead of MyApp
    await tester.pumpWidget(const StudentProfileApp());

    // 3. Verify that your specific student profile details render correctly
    expect(find.text('Name: Joseph'), findsOneWidget);
    expect(find.textContaining('Student ID:'), findsOneWidget);
    expect(find.textContaining('Major:'), findsOneWidget);
    
    // 4. Verify that the placeholder counter UI elements are gone
    expect(find.text('0'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
  });
}


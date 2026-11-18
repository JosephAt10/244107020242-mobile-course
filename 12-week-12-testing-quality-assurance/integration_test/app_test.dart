import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:week12_testing_quality_assurance/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user creates a note and opens its detail page', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final title = 'Integration note ${DateTime.now().millisecondsSinceEpoch}';
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('note-title-field')), title);
    await tester.enterText(
      find.byKey(const Key('note-body-field')),
      'Created by the integration test',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text(title), findsOneWidget);
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
    expect(find.text('Note details'), findsOneWidget);
    expect(find.text('Created by the integration test'), findsOneWidget);
  });
}

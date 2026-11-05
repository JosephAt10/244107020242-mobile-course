import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week10_ai_feature_integration/features/notes/presentation/widgets/no_search_results.dart';

void main() {
  testWidgets('no-match state explains the result and can clear search', (
    tester,
  ) async {
    var cleared = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoSearchResults(
            query: 'missing',
            onClear: () => cleared = true,
          ),
        ),
      ),
    );

    expect(find.text('No notes match "missing".'), findsOneWidget);
    await tester.tap(find.text('Clear search'));
    expect(cleared, isTrue);
  });
}

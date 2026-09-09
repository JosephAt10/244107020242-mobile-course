import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_dashboard/main.dart';

void main() {
  testWidgets('Dashboard shows one column on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    final cards = find.byType(Card);
    expect(cards, findsNWidgets(6));
    expect(find.byKey(const Key('narrow-layout')), findsOneWidget);
    expect(tester.getSize(cards.first).width, lessThan(700));
  });

  testWidgets('Dashboard shows two columns on a wide screen', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    final cards = find.byType(Card);
    expect(cards, findsNWidgets(6));
    expect(find.byKey(const Key('wide-layout')), findsOneWidget);
    expect(tester.getSize(cards.first).width, greaterThan(500));
  });

  testWidgets('Theme toggle changes to dark mode', (tester) async {
    await tester.pumpWidget(const DashboardApp());

    await tester.tap(find.byKey(themeToggleKey));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });
}

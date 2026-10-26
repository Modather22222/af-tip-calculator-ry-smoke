import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tip_calculator/main.dart';

void main() {
  testWidgets('renders the tip calculator with live split controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TipCalculatorApp());

    expect(find.text('Tip Calculator'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('Each person pays'), findsOneWidget);
    expect(find.text('Who pays?'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('SmartBudget app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartBudgetApp());

    // Проверяем, что экран регистрации загрузился
    expect(find.text('Регистрация'), findsOneWidget);
  });
}

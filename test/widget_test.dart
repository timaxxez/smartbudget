import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_budget_app/main.dart';
import 'package:smart_budget_app/providers/budget_provider.dart';

void main() {
  testWidgets('SmartBudget smoke test', (WidgetTester tester) async {
    // Собираем наше приложение внутри теста
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BudgetProvider(),
        child: const SmartBudgetApp(),
      ),
    );

    // Проверяем, что заголовок отображается
    expect(find.text('Общий расход (RUB)'), findsOneWidget);

    // Проверяем наличие кнопки добавления
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
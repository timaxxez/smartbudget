enum ExpenseCategory { transport, housing, food, clothing, other }

class Expense {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  String get categoryName {
    switch (category) {
      case ExpenseCategory.transport: return 'Транспорт';
      case ExpenseCategory.housing: return 'Жильё';
      case ExpenseCategory.food: return 'Еда';
      case ExpenseCategory.clothing: return 'Одежда';
      case ExpenseCategory.other: return 'Другое';
    }
  }
}
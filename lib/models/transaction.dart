import 'package:flutter/material.dart';

enum TransactionCategory { food, transport, housing, entertainment, clothing, other }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionCategory category;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  static IconData getIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food: return Icons.fastfood_rounded;
      case TransactionCategory.transport: return Icons.directions_car_rounded;
      case TransactionCategory.housing: return Icons.home_work_rounded;
      case TransactionCategory.entertainment: return Icons.sports_esports_rounded;
      case TransactionCategory.clothing: return Icons.checkroom_rounded;
      case TransactionCategory.other: return Icons.payments_rounded;
    }
  }

  static Color getColor(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food: return Colors.orangeAccent;
      case TransactionCategory.transport: return Colors.blueAccent;
      case TransactionCategory.housing: return Colors.purpleAccent;
      case TransactionCategory.entertainment: return Colors.pinkAccent;
      case TransactionCategory.clothing: return Colors.tealAccent.shade700;
      case TransactionCategory.other: return Colors.grey;
    }
  }

  static String getLabel(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food: return 'Еда';
      case TransactionCategory.transport: return 'Транспорт';
      case TransactionCategory.housing: return 'Жильё';
      case TransactionCategory.entertainment: return 'Досуг';
      case TransactionCategory.clothing: return 'Одежда';
      case TransactionCategory.other: return 'Другое';
    }
  }
}
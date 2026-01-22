import 'package:flutter/material.dart';

class Expense {
  final String title;
  final double amount;
  final String category;
  final IconData icon;

  Expense({
    required this.title,
    required this.amount,
    required this.category,
    required this.icon,
  });
}

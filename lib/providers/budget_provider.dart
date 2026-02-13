import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../services/currency_service.dart';
import '../services/notification_service.dart';

class BudgetProvider with ChangeNotifier {
  String? userName;
  String? userSurname;
  String? userPhone;
  bool get isUserRegistered => userName != null && userName!.isNotEmpty;

  final List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  final CurrencyService _currencyService = CurrencyService();
  final NotificationService _notificationService = NotificationService();

  String _selectedCurrency = 'KZT';
  Map<String, double> _rates = {'KZT': 1.0, 'RUB': 0.2, 'USD': 0.0022, 'EUR': 0.002};

  String get selectedCurrency => _selectedCurrency;

  BudgetProvider() {
    refreshRates();
  }

  Future<void> refreshRates() async {
    final newRates = await _currencyService.getRates();
    _rates = newRates;
    notifyListeners();
  }

  void registerUser(String name, String surname, String phone) {
    userName = name;
    userSurname = surname;
    userPhone = phone;
    notifyListeners();
  }

  void logout() {
    userName = null;
    userSurname = null;
    userPhone = null;
    _expenses.clear();
    _notificationService.cancelAll();
    notifyListeners();
  }

  void addExpense(String title, double amount, ExpenseCategory category) {
    // 1. Создаем
    final newExpense = Expense(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      category: category,
      date: DateTime.now(),
    );
    // 2. Добавляем
    _expenses.insert(0, newExpense);
    
    // 3. Уведомляем (показываем сумму в выбранной валюте)
    final displayAmount = convertAmount(amount);
    final amountString = '${displayAmount.toStringAsFixed(0)} $_selectedCurrency';
    
    _notificationService.showExpenseNotification(title, amountString);

    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void editExpense(String id, String newTitle, double newAmount, ExpenseCategory newCategory) {
    final index = _expenses.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _expenses[index] = Expense(
        id: id,
        title: newTitle,
        amount: newAmount,
        category: newCategory,
        date: _expenses[index].date,
      );
      notifyListeners();
    }
  }

  void setCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  double get totalSpending {
    double totalInKZT = _expenses.fold(0.0, (sum, item) => sum + item.amount);
    double rate = _rates[_selectedCurrency] ?? 1.0;
    return totalInKZT * rate;
  }
  
  double convertAmount(double amountInKzt) {
     double rate = _rates[_selectedCurrency] ?? 1.0;
     return amountInKzt * rate;
  }
}
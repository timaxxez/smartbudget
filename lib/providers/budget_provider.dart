import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/user_model.dart';
import '../services/currency_service.dart';

class BudgetProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  UserModel? _user;
  String _selectedCurrency = 'RUB';
  Map<String, dynamic> _rates = {};
  TransactionCategory? _filterCategory;

  final CurrencyService _currencyService = CurrencyService();

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  String get selectedCurrency => _selectedCurrency;
  TransactionCategory? get filterCategory => _filterCategory;
  final Map<String, String> currencySymbols = {'RUB': '₽', 'KZT': '₸', 'USD': '\$', 'EUR': '€'};

  List<Transaction> get transactions {
    if (_filterCategory == null) return _transactions;
    return _transactions.where((t) => t.category == _filterCategory).toList();
  }

  double get totalExpenses => _transactions.fold(0, (sum, item) => sum + item.amount);

  void register(String fName, String lName, String phone) {
    _user = UserModel(firstName: fName, lastName: lName, phone: phone);
    notifyListeners();
  }

  void logout() {
    _user = null;
    _transactions = [];
    notifyListeners();
  }

  void addTransaction(String title, double amount, TransactionCategory category) {
    _transactions.insert(0, Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: category,
    ));
    notifyListeners();
  }

  // НОВЫЙ МЕТОД: Обновление существующей записи
  void updateTransaction(String id, String newTitle, double newAmount, TransactionCategory newCategory) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _transactions[index] = Transaction(
        id: id,
        title: newTitle,
        amount: newAmount,
        date: _transactions[index].date, // Оставляем оригинальную дату
        category: newCategory,
      );
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void setFilter(TransactionCategory? category) {
    _filterCategory = category;
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    _selectedCurrency = code;
    await updateRates();
    notifyListeners();
  }

  Future<void> updateRates() async {
    _rates = await _currencyService.getAllRates(_selectedCurrency);
    notifyListeners();
  }
}
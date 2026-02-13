import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../providers/budget_provider.dart';
import 'edit_expense_screen.dart';
import 'registration_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = Provider.of<BudgetProvider>(context);
    final theme = Theme.of(context);
    
    if (!budget.isUserRegistered) {
      Future.delayed(Duration.zero, () {
         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RegistrationScreen()));
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            
            // === НОВОЕ МЕСТО: СЛЕВА (LEADING) ===
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // Полупрозрачный фон
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white70, size: 20),
                  tooltip: 'Выйти',
                  onPressed: () => _confirmLogout(context, budget),
                ),
              ),
            ),
            // =====================================

            // Убираем actions справа, чтобы было чисто (или можно оставить там что-то другое)
            actions: const [], 

            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      const Color(0xFF5C6BC0),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Привет, ${budget.userName}', 
                                style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              const Text('Твои расходы', 
                                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          // Переключатель валют справа в теле хедера
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: budget.selectedCurrency,
                                dropdownColor: theme.colorScheme.primary,
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                items: ['KZT', 'USD', 'EUR', 'RUB'].map((val) {
                                  return DropdownMenuItem(value: val, child: Text(val));
                                }).toList(),
                                onChanged: (v) => budget.setCurrency(v!),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${budget.totalSpending.toStringAsFixed(0)} ${budget.selectedCurrency}',
                        style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Список транзакций
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: budget.expenses.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.savings_outlined, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('Пока пусто', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = budget.expenses[index];
                      return _buildExpenseItem(context, expense, budget);
                    },
                    childCount: budget.expenses.length,
                  ),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditExpenseScreen())),
        label: const Text('Добавить', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildExpenseItem(BuildContext context, Expense expense, BudgetProvider budget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(expense.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 28),
        ),
        onDismissed: (_) {
          budget.deleteExpense(expense.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Запись удалена'), duration: Duration(seconds: 1)),
          );
        },
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditExpenseScreen(expense: expense))),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_getCategoryIcon(expense.category), color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(expense.title, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d MMMM, HH:mm').format(expense.date),
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '-${budget.convertAmount(expense.amount).toStringAsFixed(0)} ${budget.selectedCurrency}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, BudgetProvider budget) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы точно хотите выйти?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              budget.logout();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const RegistrationScreen()), (r) => false);
            },
            child: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.transport: return Icons.directions_car_filled_rounded;
      case ExpenseCategory.housing: return Icons.home_rounded;
      case ExpenseCategory.food: return Icons.fastfood_rounded;
      case ExpenseCategory.clothing: return Icons.checkroom_rounded;
      case ExpenseCategory.other: return Icons.shopping_bag_rounded;
    }
  }
}

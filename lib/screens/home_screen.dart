import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Expense> expenses = [];

  double get total =>
      expenses.fold(0, (sum, item) => sum + item.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartBudget', style: TextStyle(fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Итого за месяц: ${total.toStringAsFixed(2)} ₸',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: expenses.isEmpty
                ? const Center(
                    child: Text(
                      'Расходов пока нет',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final e = expenses[index];
                      return Dismissible(
                        key: ValueKey(e),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child:
                              const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          setState(() {
                            expenses.removeAt(index);
                          });
                        },
                        child: ListTile(
                          leading: Icon(e.icon, size: 32),
                          title: Text(e.title,
                              style: const TextStyle(fontSize: 20)),
                          subtitle: Text(e.category,
                              style: const TextStyle(fontSize: 16)),
                          trailing: Text(
                            '${e.amount} ₸',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, size: 30),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddExpenseScreen(),
            ),
          );

          if (result != null) {
            setState(() {
              expenses.add(result);
            });
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  String category = 'Еда';
  IconData selectedIcon = Icons.fastfood;

  final icons = {
    'Еда': Icons.fastfood,
    'Транспорт': Icons.directions_bus,
    'Развлечения': Icons.movie,
    'Покупки': Icons.shopping_cart,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Добавить расход', style: TextStyle(fontSize: 22)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration:
                  const InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Сумма'),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: category,
              isExpanded: true,
              items: icons.keys
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, style: const TextStyle(fontSize: 18)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  category = value!;
                  selectedIcon = icons[value]!;
                });
              },
            ),
            const SizedBox(height: 20),
            Icon(selectedIcon, size: 50),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    amountController.text.isEmpty) return;

                Navigator.pop(
                  context,
                  Expense(
                    title: titleController.text,
                    amount: double.parse(amountController.text),
                    category: category,
                    icon: selectedIcon,
                  ),
                );
              },
              child:
                  const Text('Сохранить', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../providers/budget_provider.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense? expense;
  const EditExpenseScreen({super.key, this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  ExpenseCategory _selectedCategory = ExpenseCategory.other;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense?.title ?? '');
    _amountController = TextEditingController(text: widget.expense?.amount.toString() ?? '');
    if (widget.expense != null) {
      _selectedCategory = widget.expense!.category;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    if (amount <= 0) return;

    final provider = Provider.of<BudgetProvider>(context, listen: false);
    if (widget.expense == null) {
      provider.addExpense(title, amount, _selectedCategory);
    } else {
      provider.editExpense(widget.expense!.id, title, amount, _selectedCategory);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Новая запись' : 'Изменить'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'На что потратили?',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
                validator: (val) => val!.isEmpty ? 'Введите название' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Сумма (KZT)',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (val) => val!.isEmpty ? 'Введите сумму' : null,
              ),
              const SizedBox(height: 32),
              const Text('Категория', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ExpenseCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(_getCategoryName(cat)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                    backgroundColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryName(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.transport: return 'Транспорт';
      case ExpenseCategory.housing: return 'Жильё';
      case ExpenseCategory.food: return 'Еда';
      case ExpenseCategory.clothing: return 'Одежда';
      case ExpenseCategory.other: return 'Другое';
    }
  }
}
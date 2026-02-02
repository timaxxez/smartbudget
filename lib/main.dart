import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Импорты твоих файлов (убедись, что названия папок совпадают)
import 'providers/budget_provider.dart';
import 'models/transaction.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BudgetProvider()..updateRates(),
      child: const SmartBudgetApp(),
    ),
  );
}

class SmartBudgetApp extends StatelessWidget {
  const SmartBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartBudget',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorSchemeSeed: Colors.deepPurple,
      ),
      // Проверка: если пользователь есть — идем на Главный, если нет — на Регистрацию
      home: Consumer<BudgetProvider>(
        builder: (context, budget, _) => budget.isAuthenticated 
          ? const HomeScreen() 
          : const RegistrationScreen(),
      ),
    );
  }
}

// --- ЭКРАН РЕГИСТРАЦИИ ---
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _fNameController = TextEditingController();
  final _lNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wallet_rounded, size: 100, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  "SmartBudget",
                  style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                ),
                const Text(
                  "Твой бюджет под контролем",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 50),
                _buildField(_fNameController, "Имя", Icons.person_rounded),
                const SizedBox(height: 15),
                _buildField(_lNameController, "Фамилия", Icons.person_outline_rounded),
                const SizedBox(height: 15),
                _buildField(_phoneController, "Телефон", Icons.phone_android_rounded, keyboard: TextInputType.phone),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 5,
                    ),
                    onPressed: () {
                      if (_fNameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                        context.read<BudgetProvider>().register(
                          _fNameController.text, 
                          _lNameController.text, 
                          _phoneController.text
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Заполните имя и телефон")),
                        );
                      }
                    },
                    child: const Text("СОЗДАТЬ АККАУНТ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.white, width: 2)),
      ),
    );
  }
}

// --- ГЛАВНЫЙ ЭКРАН ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 252, 252),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildFancyAppBar(context, budget),
          _buildFilterBar(budget),
          budget.transactions.isEmpty
              ? const SliverToBoxAdapter(child: _EmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _DismissibleTransaction(transaction: budget.transactions[i], budget: budget),
                    childCount: budget.transactions.length,
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Добавить расход'),
      ),
    );
  }

  Widget _buildFancyAppBar(BuildContext context, BudgetProvider budget) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(Icons.person_rounded, color: Colors.white),
        ),
        onPressed: () => _showProfileDialog(context, budget),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.currency_exchange_rounded, color: Colors.white),
          onPressed: () => _showCurrencyPicker(context, budget),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ПРИВЕТ, ${budget.user?.firstName.toUpperCase() ?? 'ГОСТЬ'}!', 
                style: const TextStyle(color: Colors.white60, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                '${budget.totalExpenses.toStringAsFixed(0)} ${budget.currencySymbols[budget.selectedCurrency]}',
                style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
              ),
              const Text('всего потрачено', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(BudgetProvider budget) {
    return SliverToBoxAdapter(
      child: Container(
        height: 75,
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          children: [
            _FilterChip(label: 'Все', isSelected: budget.filterCategory == null, onTap: () => budget.setFilter(null)),
            ...TransactionCategory.values.map((cat) => _FilterChip(
              label: Transaction.getLabel(cat),
              isSelected: budget.filterCategory == cat,
              onTap: () => budget.setFilter(cat),
            )),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, BudgetProvider budget) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Личный кабинет"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Colors.deepPurple),
              title: Text("${budget.user?.firstName} ${budget.user?.lastName}"),
              subtitle: const Text("Пользователь"),
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.deepPurple),
              title: Text(budget.user?.phone ?? "-"),
            ),
            const Divider(),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                budget.logout();
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text("Выйти из аккаунта", style: TextStyle(color: Colors.red)),
            )
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, BudgetProvider budget) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Выберите основную валюту", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ...budget.currencySymbols.keys.map((code) => ListTile(
              title: Text(code),
              trailing: budget.selectedCurrency == code ? const Icon(Icons.check_circle, color: Colors.green) : null,
              onTap: () {
                budget.setCurrency(code);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    TransactionCategory tempCat = TransactionCategory.other;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 25, right: 25, top: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Новый расход', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: titleCtrl, decoration: _inputStyle('Что купили?')),
              const SizedBox(height: 15),
              TextField(controller: amountCtrl, decoration: _inputStyle('Сумма'), keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              const Align(alignment: Alignment.centerLeft, child: Text("Категория:")),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TransactionCategory.values.map((cat) => ChoiceChip(
                  label: Text(Transaction.getLabel(cat)),
                  selected: tempCat == cat,
                  onSelected: (s) => setModalState(() => tempCat = cat),
                )).toList(),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () {
                    if (titleCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                      context.read<BudgetProvider>().addTransaction(titleCtrl.text, double.parse(amountCtrl.text), tempCat);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('СОХРАНИТЬ'),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
  );
}

// --- ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ ---

class _DismissibleTransaction extends StatelessWidget {
  final Transaction transaction;
  final BudgetProvider budget;
  const _DismissibleTransaction({required this.transaction, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: Colors.redAccent.shade100, borderRadius: BorderRadius.circular(22)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 35),
      ),
      onDismissed: (_) => budget.deleteTransaction(transaction.id),
      child: _TransactionCard(transaction: transaction, symbol: budget.currencySymbols[budget.selectedCurrency]!),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String symbol;
  const _TransactionCard({required this.transaction, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Transaction.getColor(transaction.category).withOpacity(0.12), borderRadius: BorderRadius.circular(18)),
            child: Icon(Transaction.getIcon(transaction.category), color: Transaction.getColor(transaction.category)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                Text(Transaction.getLabel(transaction.category), style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),
          Text('-${transaction.amount.toStringAsFixed(0)} $symbol', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.redAccent, fontSize: 18)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 25),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))] : [],
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 80),
          Icon(Icons.receipt_long_rounded, size: 100, color: const Color.fromARGB(255, 114, 114, 114)),
          const SizedBox(height: 20),
          Text('История трат пуста', style: TextStyle(color: Colors.grey.shade400, fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import 'home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Provider.of<BudgetProvider>(context, listen: false).registerUser(
        _nameController.text,
        _surnameController.text,
        _phoneController.text,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.pie_chart_rounded, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 20),
              Text('SmartBudget', 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              const Text('Контролируй свои расходы', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInput(_nameController, 'Имя', Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildInput(_surnameController, 'Фамилия', Icons.badge_outlined),
                    const SizedBox(height: 16),
                    _buildInput(_phoneController, 'Телефон', Icons.phone_android_rounded, isPhone: true),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Войти в приложение'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, {bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
      ),
      validator: (v) => v!.isEmpty ? 'Заполните поле' : null,
    );
  }
}
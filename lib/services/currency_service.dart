import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // Получаем актуальные курсы валют относительно выбранной базы
  Future<Map<String, dynamic>> getAllRates(String baseCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/$baseCurrency')
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['rates'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print('Ошибка API: $e');
      return {};
    }
  }
}
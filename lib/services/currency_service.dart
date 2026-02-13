import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  final String _apiUrl = 'https://api.exchangerate-api.com/v4/latest/KZT';

  Future<Map<String, double>> getRates() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'];
        return {
          'KZT': 1.0,
          'USD': (rates['USD'] ?? 0.0).toDouble(),
          'EUR': (rates['EUR'] ?? 0.0).toDouble(),
          'RUB': (rates['RUB'] ?? 0.0).toDouble(),
        };
      } else {
        throw Exception('Ошибка API');
      }
    } catch (e) {
      print('Ошибка валют: $e');
      return {
        'KZT': 1.0,
        'USD': 0.0022,
        'EUR': 0.0020,
        'RUB': 0.20,
      };
    }
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyProvider extends ChangeNotifier {
  double? _eurRate;
  bool _isLoading = true;

  double? get eurRate => _eurRate;
  bool get isLoading => _isLoading;

  /// Fetch EUR rate based on RSD
  Future<void> fetchEurRate() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/RSD'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _eurRate = data['rates']['EUR']?.toDouble();
      }
    } catch (e) {
      debugPrint('Currency API error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Optional: convert RSD to EUR
  double? convertToEur(double amountRsd) {
    if (_eurRate == null) return null;
    return amountRsd * _eurRate!;
  }
}

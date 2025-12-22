import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<UserOrder> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  // GETTERS
  List<UserOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ===============================
  // CREATE ORDER
  // ===============================
  Future<void> createOrder(UserOrder order) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderService.createOrder(order);
      _orders.add(order);
    } catch (e) {
      _errorMessage = 'Greška pri kreiranju porudžbine';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===============================
  // FETCH ALL ORDERS (ADMIN)
  // ===============================
  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.getAllOrders();
    } catch (e) {
      _errorMessage = 'Greška pri učitavanju porudžbina';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===============================
  // FETCH ORDERS BY USER
  // ===============================
  Future<void> fetchOrdersByUser(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.getOrdersByUser(userId.toString());
    } catch (e) {
      _errorMessage = 'Greška pri učitavanju porudžbina korisnika';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===============================
  // UPDATE ORDER (STATUS)
  // ===============================
  Future<void> updateOrder(UserOrder order) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderService.updateOrder(order);

      final index =
      _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _orders[index] = order;
      }
    } catch (e) {
      _errorMessage = 'Greška pri izmeni porudžbine';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===============================
  // DELETE ORDER
  // ===============================
  Future<void> deleteOrder(int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderService.deleteOrder(orderId.toString());
      _orders.removeWhere((o) => o.id == orderId);
    } catch (e) {
      _errorMessage = 'Greška pri brisanju porudžbine';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===============================
  // CLEAR ORDERS (optional)
  // ===============================
  void clearOrders() {
    _orders = [];
    notifyListeners();
  }
}

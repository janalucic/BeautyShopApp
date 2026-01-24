import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'name': product.name,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'price': product.price,
      'quantity': quantity,
      'popular': product.popular,
      'categoryId': product.categoryId,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product(
        id: json['productId'],
        name: json['name'],
        description: json['description'] ?? '',
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'],
        popular: json['popular'] ?? false,
        categoryId: json['categoryId'],
      ),
      quantity: json['quantity'] ?? 1,
    );
  }
}

class CartProvider extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  List<CartItem> _items = [];
  bool _isLoading = false;

  // ==============================
  // GETTERS
  // ==============================
  List<CartItem> get cartItems => _items;

  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  bool get isLoading => _isLoading;

  // ==============================
  // KONSTRUKTOR
  // ==============================
  CartProvider() {
    if (_uid != null) {
      loadCart();
    }
  }

  String get _cartPath => 'Carts/$_uid/items';

  // ==============================
  // UCITAVANJE KORPE
  // ==============================
  Future<void> loadCart() async {
    if (_uid == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _dbRef.child(_cartPath).get();
      if (!snapshot.exists) {
        _items = [];
      } else {
        final List<dynamic> data = List<dynamic>.from(snapshot.value as List<dynamic>);
        _items = data
            .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==============================
  // DODAVANJE U KORPU
  // ==============================
  Future<void> addToCart(Product product, int quantity) async {
    if (_uid == null) return;

    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }

    await _saveCartToFirebase();
    notifyListeners();
  }

  // ==============================
  // UKLANJANJE IZ KORPE
  // ==============================
  Future<void> removeFromCart(int productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    await _saveCartToFirebase();
    notifyListeners();
  }

  // ==============================
  // AZURIRANJE KOLICINE
  // ==============================
  Future<void> increaseQuantity(Product product) async {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += 1;
      await _saveCartToFirebase();
      notifyListeners();
    }
  }

  Future<void> decreaseQuantity(Product product) async {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0 && _items[index].quantity > 1) {
      _items[index].quantity -= 1;
      await _saveCartToFirebase();
      notifyListeners();
    }
  }

  // ==============================
  // PRAZNJENJE KORPE
  // ==============================
  Future<void> clearCart() async {
    _items.clear();
    if (_uid != null) {
      await _dbRef.child(_cartPath).remove();
    }
    notifyListeners();
  }

  // ==============================
  // CUvanje u Firebase
  // ==============================
  Future<void> _saveCartToFirebase() async {
    if (_uid == null) return;
    final data = _items.map((item) => item.toJson()).toList();
    await _dbRef.child(_cartPath).set(data);
  }
}

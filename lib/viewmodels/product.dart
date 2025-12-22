import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  // GETTERS (za UI)
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ===============================
  // FETCH ALL PRODUCTS
  // ===============================
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productService.getProducts();
    } catch (e) {
      _errorMessage = 'Greška pri učitavanju proizvoda';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===============================
  // GET PRODUCT BY ID
  // ===============================
  Future<Product?> getProductById(int id) async {
    try {
      return await _productService.getProductById(id.toString());
    } catch (e) {
      _errorMessage = 'Greška pri dohvatu proizvoda';
      notifyListeners();
      return null;
    }
  }

  // ===============================
  // ADD PRODUCT
  // ===============================
  Future<void> addProduct(Product product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productService.addProduct(product);
      _products.add(product);
    } catch (e) {
      _errorMessage = 'Greška pri dodavanju proizvoda';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===============================
  // UPDATE PRODUCT
  // ===============================
  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productService.updateProduct(product);

      final index =
      _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
      }
    } catch (e) {
      _errorMessage = 'Greška pri izmeni proizvoda';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===============================
  // DELETE PRODUCT
  // ===============================
  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productService.deleteProduct(id.toString());
      _products.removeWhere((p) => p.id == id);
    } catch (e) {
      _errorMessage = 'Greška pri brisanju proizvoda';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

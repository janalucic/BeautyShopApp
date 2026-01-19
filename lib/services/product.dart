import 'package:firebase_database/firebase_database.dart';
import '../models/product.dart';

class ProductService {
  final DatabaseReference _productsRef =
  FirebaseDatabase.instance.ref('Products');

  // ===============================
  // GET ALL PRODUCTS
  // ===============================
  Future<List<Product>> getProducts() async {
    final snapshot = await _productsRef.get();

    if (!snapshot.exists) return [];

    final Map data = snapshot.value as Map;

    return data.entries.map((entry) {
      return Product.fromJson(
        Map<String, dynamic>.from(entry.value),
      );
    }).toList();
  }

  // ===============================
  // GET PRODUCT BY ID
  // ===============================
  Future<Product?> getProductById(int id) async {
    final snapshot = await _productsRef.child(id.toString()).get();

    if (!snapshot.exists) return null;

    return Product.fromJson(
      Map<String, dynamic>.from(snapshot.value as Map),
    );
  }

  // ===============================
  // GET POPULAR PRODUCTS
  // ===============================
  Future<List<Product>> getPopularProducts() async {
    final products = await getProducts();
    return products.where((p) => p.popular).toList();
  }

  // ===============================
  // ADD PRODUCT
  // ===============================
  Future<void> addProduct(Product product) async {
    await _productsRef
        .child(product.id.toString())
        .set(product.toJson());
  }

  // ===============================
  // UPDATE PRODUCT
  // ===============================
  Future<void> updateProduct(Product product) async {
    await _productsRef
        .child(product.id.toString())
        .update(product.toJson());
  }

  // ===============================
  // DELETE PRODUCT
  // ===============================
  Future<void> deleteProduct(int id) async {
    await _productsRef.child(id.toString()).remove();
  }
}

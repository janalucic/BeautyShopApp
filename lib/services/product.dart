import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final CollectionReference productsCollection =
  FirebaseFirestore.instance.collection('products');

  // Prikaz svih proizvoda
  Future<List<Product>> getProducts() async {
    var snapshot = await productsCollection.get();
    return snapshot.docs
        .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Prikaz proizvoda po ID-u
  Future<Product?> getProductById(String id) async {
    var doc = await productsCollection.doc(id).get();
    if (doc.exists) {
      return Product.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Dodavanje proizvoda
  Future<void> addProduct(Product product) async {
    await productsCollection.doc(product.id.toString()).set(product.toJson());
  }

  // Ažuriranje proizvoda
  Future<void> updateProduct(Product product) async {
    await productsCollection.doc(product.id.toString()).update(product.toJson());
  }

  // Brisanje proizvoda
  Future<void> deleteProduct(String id) async {
    await productsCollection.doc(id).delete();
  }
}

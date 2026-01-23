import 'package:firebase_database/firebase_database.dart';
import '../models/category.dart';

class CategoryService {
  final DatabaseReference categoriesRef =
  FirebaseDatabase.instance.ref('Categories');

  Future<List<Category>> getCategories() async {
    final snapshot = await categoriesRef.get();

    if (!snapshot.exists) return [];

    // Firebase vraća List<dynamic> jer je JSON lista
    final List data = snapshot.value as List;

    return data
        .where((e) => e != null)
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

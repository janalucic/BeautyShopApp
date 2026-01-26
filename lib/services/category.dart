import 'package:firebase_database/firebase_database.dart';
import '../models/category.dart';

class CategoryService {
  final DatabaseReference categoriesRef =
  FirebaseDatabase.instance.ref('Categories');

  /// Učitaj kategorije (LISTA)
  Future<List<Category>> getCategories() async {
    final snapshot = await categoriesRef.get();
    if (!snapshot.exists) return [];

    final List list = snapshot.value as List;

    return list
        .where((e) => e != null)
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Dodaj novu kategoriju NA KRAJ LISTE
  Future<void> addCategory(String name) async {
    final snapshot = await categoriesRef.get();

    int newIndex = 0;
    if (snapshot.exists) {
      final List list = snapshot.value as List;
      newIndex = list.length;
    }

    await categoriesRef.child(newIndex.toString()).set({
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': name,
    });
  }

  /// Izmeni kategoriju po ID-u
  Future<void> updateCategory(int id, String newName) async {
    final snapshot = await categoriesRef.get();
    if (!snapshot.exists) return;

    final List list = snapshot.value as List;

    for (int i = 0; i < list.length; i++) {
      final value = Map<String, dynamic>.from(list[i]);
      if (value['id'] == id) {
        await categoriesRef.child(i.toString()).update({
          'name': newName,
        });
        break;
      }
    }
  }

  /// Obriši kategoriju
  Future<void> deleteCategory(int id) async {
    final snapshot = await categoriesRef.get();
    if (!snapshot.exists) return;

    final List list = snapshot.value as List;

    for (int i = 0; i < list.length; i++) {
      final value = Map<String, dynamic>.from(list[i]);
      if (value['id'] == id) {
        await categoriesRef.child(i.toString()).remove();
        break;
      }
    }
  }
}

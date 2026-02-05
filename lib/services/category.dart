import 'package:firebase_database/firebase_database.dart';
import '../models/category.dart';

class CategoryService {
  final DatabaseReference categoriesRef =
  FirebaseDatabase.instance.ref('Categories');

  // ================= GET =================
  Future<List<Category>> getCategories() async {
    final snapshot = await categoriesRef.get();
    if (!snapshot.exists) return [];

    final Map<String, dynamic> map =
    Map<String, dynamic>.from(snapshot.value as Map);

    return map.values
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
 //ADD
  Future<void> addCategory(String name) async {
    // Kreira novi jedinstveni key u Firebase
    final newRef = categoriesRef.push();

    // Postavlja podatke za novu kategoriju
    await newRef.set({
      'id': DateTime.now().millisecondsSinceEpoch, // jedinstveni ID
      'name': name,
    });
  }

  // ================= UPDATE =================
  Future<void> updateCategory(int id, String newName) async {
    final snapshot = await categoriesRef.get();
    if (!snapshot.exists) return;

    final Map<String, dynamic> map =
    Map<String, dynamic>.from(snapshot.value as Map);

    for (final entry in map.entries) {
      final value = Map<String, dynamic>.from(entry.value);
      if (value['id'] == id) {
        await categoriesRef.child(entry.key).update({
          'name': newName,
        });
        break;
      }
    }
  }

  // ================= DELETE =================
  Future<void> deleteCategory(int id) async {
    final snapshot = await categoriesRef.get();
    if (!snapshot.exists) return;

    final Map<String, dynamic> map =
    Map<String, dynamic>.from(snapshot.value as Map);

    for (final entry in map.entries) {
      final value = Map<String, dynamic>.from(entry.value);
      if (value['id'] == id) {
        await categoriesRef.child(entry.key).remove();
        break;
      }
    }
  }
}

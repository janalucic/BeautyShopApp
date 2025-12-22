import 'package:firebase_database/firebase_database.dart';
import '../models/category.dart';

class CategoryService {
  final DatabaseReference categoriesRef =
  FirebaseDatabase.instance.ref('Categories');

  Future<List<Category>> getCategories() async {
    final snapshot = await categoriesRef.get();
    if (snapshot.exists) {
      final Map data = snapshot.value as Map;
      return data.entries.map((e) {
        final value = e.value as Map;
        return Category(
          id: value['id'].toString(),
          name: value['name'].toString(),
        );
      }).toList();
    }
    return [];
  }
}

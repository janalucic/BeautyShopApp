import 'package:firebase_database/firebase_database.dart';
import '../models/category.dart';

class CategoryService {
  final DatabaseReference categoriesRef =
  FirebaseDatabase.instance.ref('Categories');

  Future<List<Category>> getCategories() async {
    final snapshot = await categoriesRef.get();

    if (snapshot.exists) {
      final Map data = snapshot.value as Map;

      // Filtriramo null vrednosti i mapiramo id kao int
      return data.entries
          .where((e) => e.value != null)
          .map((e) {
        final value = Map<String, dynamic>.from(e.value as Map);
        return Category(
          id: value['id'] is int
              ? value['id']
              : int.parse(value['id'].toString()),
          name: value['name'].toString(),
        );
      }).toList();
    }

    return [];
  }
}

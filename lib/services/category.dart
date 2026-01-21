import 'package:firebase_database/firebase_database.dart';
import '../models/category.dart';

class CategoryService {
  final DatabaseReference categoriesRef =
      FirebaseDatabase.instance.ref('Categories');

  Future<List<Category>> getCategories() async {
    final snapshot = await categoriesRef.get();

    final raw = snapshot.value;

    if (raw is List) {
      return raw.where((e) => e != null).map((e) {
        final value = Map<String, dynamic>.from(e as Map);

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

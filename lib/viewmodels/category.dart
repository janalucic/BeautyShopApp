import '../services/category.dart';
import '../models/category.dart';
import 'package:flutter/material.dart';

class CategoryViewModel {
  final CategoryService _service = CategoryService();

  final ValueNotifier<List<Category>> categories = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      final fetchedCategories = await _service.getCategories();
      categories.value = fetchedCategories;
    } catch (e) {
      categories.value = [];
      debugPrint("Error fetching categories: $e");
    }
    isLoading.value = false;
  }

  // Dodavanje nove kategorije
  Future<void> addCategory(String name) async {
    await _service.addCategory(name);
    await fetchCategories(); // OSVEŽAVANJE NAKON DODAVANJA
  }

  // Izmena kategorije
  Future<void> updateCategoryName(int id, String newName) async {
    await _service.updateCategory(id, newName);
    await fetchCategories(); // OSVEŽAVANJE NAKON IZMENE
  }

  // Brisanje kategorije
  Future<void> deleteCategory(int id) async {
    await _service.deleteCategory(id);
    await fetchCategories(); // OSVEŽAVANJE NAKON BRISANJA
  }
}
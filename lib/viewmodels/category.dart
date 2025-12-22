import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category.dart';

class CategoryViewModel {
  final CategoryService _service = CategoryService();

  // Notifieri za listu kategorija i loading state
  final ValueNotifier<List<Category>> categories = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<void> fetchCategories() async {
    isLoading.value = true; // prikazujemo loading indikator
    try {
      final fetchedCategories = await _service.getCategories();
      categories.value = fetchedCategories;
    } catch (e) {
      categories.value = []; // u slučaju greške lista je prazna
      debugPrint("Error fetching categories: $e");
    }
    isLoading.value = false; // sakrivamo loading indikator
  }
}

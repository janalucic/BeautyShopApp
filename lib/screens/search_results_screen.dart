import 'package:flutter/material.dart';
import 'dart:ui';
import 'product_detail_screen.dart';
import 'package:first_app_flutter/models/product.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;
  final List<Product> products;

  const SearchResultsScreen({
    super.key,
    required this.query,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final results = products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5E8E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E8E8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFD87F7F)),
        title: Text(
          'Rezultati za "$query"',
          style: const TextStyle(
            color: Color(0xFFD87F7F),
            fontFamily: 'Spinnaker',
          ),
        ),
      ),
      body: results.isEmpty
          ? const Center(
              child: Text(
                'Nema proizvoda za ovu pretragu',
                style: TextStyle(
                  fontFamily: 'Spinnaker',
                  fontSize: 16,
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final product = results[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          product: product,
                          isAdmin: true,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD87F7F).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              product.imageUrl,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              product.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Spinnaker',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${product.price.toStringAsFixed(2)} RSD',
                              style: const TextStyle(
                                color: Color(0xFFD87F7F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

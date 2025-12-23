import 'package:flutter/material.dart';
import 'dart:ui';
import 'comments_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isAdmin;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E8E8),
      body: Stack(
        children: [
          Container(color: const Color(0xFFF5E8E8)),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back dugme
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFFD87F7F)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Naziv proizvoda
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      product['name'],
                      style: const TextStyle(
                        fontFamily: 'Spinnaker',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD87F7F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Slika proizvoda
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD87F7F).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Image.asset(product['image'], fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Opis
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      product['description'],
                      style: const TextStyle(fontFamily: 'Spinnaker', fontSize: 16, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cena
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Cena: ${product['price'].toStringAsFixed(2)} RSD',
                      style: const TextStyle(
                        fontFamily: 'Spinnaker',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD87F7F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Dugmad
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommentsScreen(productId: product['id'], isAdmin: isAdmin),
                                ),
                              );
                            },
                            icon: const Icon(Icons.comment, color: Colors.white),
                            label: const Text(
                              'Vidi komentare',
                              style: TextStyle(color: Colors.white, fontFamily: 'Spinnaker'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD87F7F),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.shopping_cart, color: Colors.white),
                            label: const Text(
                              'Dodaj u korpu',
                              style: TextStyle(color: Colors.white, fontFamily: 'Spinnaker'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD87F7F),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

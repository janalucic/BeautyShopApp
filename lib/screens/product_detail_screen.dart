import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'comments_screen.dart';
import 'login_screen.dart';
import 'package:first_app_flutter/models/product.dart';
import '../providers/user_provider.dart'; // ← import UserProvider

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final bool isAdmin;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    // ← Čitamo status gosta iz Provider-a
    final bool isGuest = context.watch<UserProvider>().isGuest;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDE4E4), Color(0xFFFFF5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Scroll sadržaj
              Padding(
                padding: const EdgeInsets.only(bottom: 180),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back dugme
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Color(0xFFD87F7F)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Naziv proizvoda u belom okviru
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0.0, vertical: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            product.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Spinnaker',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD87F7F),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Slika proizvoda sa shadow i blur efektom
                      Center(
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: BackdropFilter(
                              filter:
                              ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                              child: Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.white.withOpacity(0.6),
                                  child: const Icon(Icons.image_not_supported,
                                      color: Color(0xFFD87F7F)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Opis proizvoda
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          product.description,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontFamily: 'Spinnaker',
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 200),
                    ],
                  ),
                ),
              ),

              // Donji fiksni panel
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(25)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Cena
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Cena: ${product.price.toStringAsFixed(2)} RSD',
                          style: const TextStyle(
                            fontFamily: 'Spinnaker',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD87F7F),
                          ),
                        ),
                      ),

                      // Dugmad sa gradientom
                      Row(
                        children: [
                          // Vidi komentare
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CommentsScreen(
                                        productId: product.id,
                                        isAdmin: isAdmin),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFD87F7F),
                                      Color(0xFFF5A9A9)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Vidi komentare',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Spinnaker',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Dodaj u korpu
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                if (isGuest) {
                                  // Ako je gost, otvori dijalog za prijavu/registraciju
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: const Color(0xFFFFC1CC), // svetlo roza
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      title: const Text(
                                        'Prijavite se',
                                        style: TextStyle(
                                          color: Color(0xFF800020), // bordo
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: const Text(
                                        'Morate se prijaviti da biste dodali proizvod u korpu.',
                                        style: TextStyle(
                                          color: Color(0xFF800020),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                            const Color(0xFF800020),
                                          ),
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Otkaži'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            const Color(0xFFD87F7F),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 12),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                  const LoginScreen()),
                                            );
                                          },
                                          child: const Text(
                                            'Prijavi se',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  // Ako nije gost, obaveštenje
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Proizvod dodat u korpu!')),
                                  );
                                }
                              },
                              child: Container(
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFD87F7F),
                                      Color(0xFFF5A9A9)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Dodaj u korpu',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Spinnaker',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

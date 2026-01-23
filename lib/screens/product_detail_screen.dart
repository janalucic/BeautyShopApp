import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'comments_screen.dart';
import 'login_screen.dart';
import 'package:first_app_flutter/models/product.dart';
import '../providers/user_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final bool isAdmin;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.isAdmin = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
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
                      // Fiksirani naziv + back dugme
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Color(0xFFD87F7F), size: 32),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: const TextStyle(
                                  fontFamily: 'Spinnaker',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD87F7F),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Slika proizvoda bez senki
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            widget.product.imageUrl,
                            width: 260,
                            height: 260,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.white.withOpacity(0.6),
                              child: const Icon(Icons.image_not_supported,
                                  color: Color(0xFFD87F7F)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Opis sa vidi više / vidi manje
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.description,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                fontFamily: 'Spinnaker',
                                fontSize: 16,
                                color: Color(0xFFD87F7F),
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                              maxLines:
                              _isDescriptionExpanded ? null : 3,
                              overflow: _isDescriptionExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isDescriptionExpanded =
                                  !_isDescriptionExpanded;
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isDescriptionExpanded
                                        ? 'Prikaži manje'
                                        : 'Vidi više',
                                    style: const TextStyle(
                                      color: Color(0xFF800020),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _isDescriptionExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: const Color(0xFF800020),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Kontrola količine
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Color(0xFFD87F7F), size: 30),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFD87F7F)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontFamily: 'Spinnaker',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD87F7F),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _quantity++),
                            icon: const Icon(Icons.add_circle_outline,
                                color: Color(0xFFD87F7F), size: 30),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Cena
                      Text(
                        'Cena: ${(widget.product.price * _quantity).toStringAsFixed(2)} RSD',
                        style: const TextStyle(
                          fontFamily: 'Spinnaker',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD87F7F),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Dugmad Vidi komentare i Dodaj u korpu
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CommentsScreen(
                                        productId: widget.product.id,
                                        isAdmin: widget.isAdmin),
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.comment, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'Vidi komentare',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Spinnaker',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                if (isGuest) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: const Color(0xFFFFC1CC),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      title: const Text(
                                        'Prijavite se',
                                        style: TextStyle(
                                          color: Color(0xFF800020),
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
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Otkaži'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                  const LoginScreen()),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            const Color(0xFFD87F7F),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(20),
                                            ),
                                          ),
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                        Text('Proizvod dodat u korpu!')),
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.shopping_cart,
                                        color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'Dodaj u korpu',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Spinnaker',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
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

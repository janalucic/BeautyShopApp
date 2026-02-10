import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../providers/cart_provider.dart';
import '../providers/currency_provider.dart';
import 'home_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, CurrencyProvider>(
      builder: (context, cartProvider, currencyProvider, _) {
        final cartItems = cartProvider.cartItems;

        final totalPriceRsd = cartItems.fold<double>(
          0,
              (sum, item) => sum + item.product.price * item.quantity,
        );

        final totalPriceEur = currencyProvider.convertToEur(totalPriceRsd);

        return Scaffold(
          body: Stack(
            children: [
              // POZADINSKA SLIKA
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/korpa5.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // OVERLAY
              Container(color: Colors.black.withOpacity(0.25)),

              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // NASLOV
                    const Text(
                      'Vaša korpa',
                      style: TextStyle(
                        fontFamily: 'Spinnaker',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // SADRŽAJ
                    Expanded(
                      child: cartItems.isEmpty
                          ? _EmptyCart(context)
                          : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            color: Colors.white.withOpacity(0.15),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // SLIKA
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.product.imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // TEKST, CENA I QUANTITY PICKER
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // NAZIV PROIZVODA
                                        Text(
                                          item.product.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ),
                                        const SizedBox(height: 4),

                                        // CENA
                                        Text(
                                          '${item.product.price.toStringAsFixed(2)} RSD',
                                          style: const TextStyle(color: Colors.white70),
                                        ),

                                        const SizedBox(height: 8),

                                        // QUANTITY PICKER
                                        Row(
                                          children: [
                                            // MINUS
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline,
                                                  color: Color(0xFFFF5DA2)),
                                              onPressed: () {
                                                cartProvider.decreaseQuantity(item.product);
                                              },
                                            ),
                                            // KOLICINA
                                            Text(
                                              item.quantity.toString(),
                                              style: const TextStyle(
                                                  color: Colors.white, fontSize: 16),
                                            ),
                                            // PLUS
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline,
                                                  color: Color(0xFFFF5DA2)),
                                              onPressed: () {
                                                cartProvider.increaseQuantity(item.product);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // DUGME ZA BRISANJE
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Color(0xFFFF5DA2)),
                                    onPressed: () {
                                      _showDeleteConfirmDialog(
                                        context,
                                        onConfirm: () {
                                          cartProvider.removeFromCart(item.product.id);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // DONJI PANEL – UKUPNO + ZAVRŠI KUPOVINU
                    if (cartItems.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // UKUPNO RSD
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Ukupno:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${totalPriceRsd.toStringAsFixed(2)} RSD',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // UKUPNO EUR
                            if (currencyProvider.isLoading)
                              const Text(
                                'Preračunavanje u EUR...',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              )
                            else if (totalPriceEur != null)
                              Text(
                                '≈ ${totalPriceEur.toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  color: Color(0xFFFF5DA2),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                            const SizedBox(height: 16),

                            // ZAVRŠI KUPOVINU
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final order = {
                                    'id': DateTime.now().millisecondsSinceEpoch,
                                    'items': cartItems
                                        .map((item) => {
                                      'productId': item.product.id,
                                      'price': item.product.price,
                                      'quantity': item.quantity,
                                    })
                                        .toList(),
                                    'status': 'obrađuje se',
                                    'totalPrice': totalPriceRsd,
                                    'userId': FirebaseAuth.instance.currentUser?.uid,
                                  };

                                  await FirebaseDatabase.instance
                                      .ref('Orders')
                                      .push()
                                      .set(order);

                                  await cartProvider.clearCart();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Vaša porudžbina je evidentirana!'),
                                      backgroundColor: Color(0xFFFF5DA2),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5DA2),
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                ),
                                child: const Text(
                                  'Završi kupovinu',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // PRAZNA KORPA
  Widget _EmptyCart(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 80, color: Color(0xFFFF5DA2)),
                const SizedBox(height: 24),
                const Text(
                  'Vaša korpa je trenutno prazna',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Spinnaker',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF5DA2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Dodajte proizvode i vratite se ovde',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.white70),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5DA2),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text(
                    'Nazad na kupovinu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
      BuildContext context, {
        required VoidCallback onConfirm,
      }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF0F5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        title: const Text(
          'Uklanjanje proizvoda',
          style: TextStyle(
            fontFamily: 'Spinnaker',
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF5DA2),
          ),
        ),
        content: const Text(
          'Da li ste sigurni da želite da uklonite ovaj proizvod iz korpe?',
          style: TextStyle(fontSize: 15, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Otkaži',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5DA2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text(
              'Ukloni',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

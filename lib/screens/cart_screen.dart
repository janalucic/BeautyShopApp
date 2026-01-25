import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../providers/cart_provider.dart';
import 'home_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final cartItems = cartProvider.cartItems;
        final totalPrice = cartItems.fold<double>(
          0,
              (sum, item) => sum + item.product.price * item.quantity,
        );

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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: Text(
                          'Vaša korpa',
                          style: TextStyle(
                            fontFamily: 'Spinnaker',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // SADRŽAJ
                    Expanded(
                      child: cartItems.isEmpty
                          ? Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                                sigmaX: 2, sigmaY: 2),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 40),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(
                                    255, 255, 255, 0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color:
                                  Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 80,
                                    color: Color(0xFFFF5DA2),
                                  ),
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
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 40),

                                  // 🔥 IZMENJENO DUGME
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                          const HomeScreen(),
                                        ),
                                            (route) => false,
                                      );
                                    },
                                    style:
                                    ElevatedButton.styleFrom(
                                      backgroundColor:
                                      const Color(0xFFFF5DA2),
                                      padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 40,
                                          vertical: 14),
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            25),
                                      ),
                                    ),
                                    child: const Text(
                                      'Nazad na kupovinu',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                        FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            color: Colors.white.withOpacity(0.15),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8),
                            child: ListTile(
                              leading: Image.network(
                                item.product.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                item.product.name,
                                style: const TextStyle(
                                    color: Colors.white),
                              ),
                              subtitle: Text(
                                '${item.product.price.toStringAsFixed(2)} RSD',
                                style: const TextStyle(
                                    color: Colors.white70),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Color(0xFFFF5DA2)),
                                onPressed: () {
                                  cartProvider.removeFromCart(
                                      item.product.id);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ZAVRŠI KUPOVINU
                    if (cartItems.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Ukupno:',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  '${totalPrice.toStringAsFixed(2)} RSD',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                final order = {
                                  'id': DateTime.now()
                                      .millisecondsSinceEpoch,
                                  'items': cartItems
                                      .map((item) => {
                                    'productId':
                                    item.product.id,
                                    'price':
                                    item.product.price,
                                    'quantity': item.quantity,
                                  })
                                      .toList(),
                                  'status': 'obrađuje se',
                                  'totalPrice': totalPrice,
                                  'userId': FirebaseAuth
                                      .instance.currentUser?.uid,
                                };

                                await FirebaseDatabase.instance
                                    .ref('Orders')
                                    .push()
                                    .set(order);

                                await cartProvider.clearCart();

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Vaša porudžbina je evidentirana!'),
                                    backgroundColor: Colors.pink,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFFFF5DA2),
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(25)),
                              ),
                              child: const Text(
                                'Završi kupovinu',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white),
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
}

import 'dart:ui';
import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //  POZADINSKA SLIKA
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/korpa5.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          //   OVERLAY
          Container(
            color: Colors.black.withOpacity(0.25),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // 🔙 BACK + NASLOV
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
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
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 🛒 GLAVNI GLASS CARD – potpuno proziran
                Expanded(
                  child: Center(
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
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 🛍 ICON
                              const Icon(
                                Icons.shopping_bag_outlined,
                                size: 80,
                                color: Color(0xFFFF5DA2),
                              ),

                              const SizedBox(height: 24),

                              // 💖 TEKST
                              const Text(
                                'Vaša korpa je trenutno prazna',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Spinnaker',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF5DA2), // Barbie pink
                                  letterSpacing: 0.6,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 6,
                                      color: Colors.black45,
                                      offset: Offset(1, 2),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                'Dodajte proizvode i vratite se ovde ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white70,
                                ),
                              ),

                              const SizedBox(height: 40),

                              // 🎀 DUGME
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5DA2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 8,
                                ),
                                child: const Text(
                                  'Nazad na kupovinu',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

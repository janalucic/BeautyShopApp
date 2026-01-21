import 'dart:ui';
import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pozadinska slika
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/boxes.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Tamniji overlay za bolju čitljivost
          Container(
            color: const Color(0x80000000),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40), // Malo više razmaka od vrha
                // Natpis "Porudžbine" sa shadow-om
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Porudžbine',
                    style: TextStyle(
                      fontFamily: 'Spinnaker',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Color.fromRGBO(0, 0, 0, 0.4),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Poluprovidni okvir sa frosted glass efektom
                Expanded(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Trenutno nema porudžbina.',
                              style: TextStyle(
                                fontFamily: 'Spinnaker',
                                fontSize: 20,
                                color: Color(0xFFD87F7F),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

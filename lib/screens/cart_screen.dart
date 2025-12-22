import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pozadinska slika
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/korpa.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Tamniji overlay da pozadina bude blaža
          Container(
            color: const Color(0x80000000), // tamnija pozadina
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Natpis "Vaša korpa"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Vaša korpa',
                    style: const TextStyle(
                      fontFamily: 'Spinnaker', // isti font kao u ostatku app
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Poluprovidni okvir za sadržaj korpe (može se kasnije popuniti proizvodima)
                Expanded(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                       color: const Color(0x80000000),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Text(
                          'Vaša korpa je trenutno prazna.',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

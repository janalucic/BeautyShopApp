import 'package:flutter/material.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pozadinska slika
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/users5.jpg'),
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

                // Natpis "Korisnici"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Korisnici',
                    style: const TextStyle(
                      fontFamily: 'Spinnaker', // isti font kao u ostatku app
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Poluprovidni okvir za listu korisnika (trenutno placeholder)
                Expanded(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xCCFFFFFF), // providni beli okvir
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Text(
                          'Trenutno nema korisnika.',
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

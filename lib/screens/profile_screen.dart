import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Statički podaci korisnika
  String userName = 'Ana Petrović';
  String userEmail = 'user@gmail.com';
  String userAddress = 'Bulevar Kralja Aleksandra 12';
  String userPhone = '+381 64 123 4567';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pozadinska slika
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/profilepic.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Poluprovidni overlay
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Dugme za povratak
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                const Spacer(),

                // Poluprovidni okvir sa podacima
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD87F7F),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFFBFA1A1),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userAddress,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFBFA1A1),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userPhone,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFBFA1A1),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            _showEditDialog(context);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(Color(0xFFD87F7F)),
                            padding: MaterialStatePropertyAll(
                              const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            ),
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Uredite svoj profil',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
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

  void _showEditDialog(BuildContext context) {
    String tempName = userName;
    String tempEmail = userEmail;
    String tempAddress = userAddress;
    String tempPhone = userPhone;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFB03A5B),
          title: const Text(
            'Izmeni profil',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Ime i prezime', tempName, (val) => tempName = val),
                _buildTextField('Email', tempEmail, (val) => tempEmail = val),
                _buildTextField('Adresa', tempAddress, (val) => tempAddress = val),
                _buildTextField('Broj telefona', tempPhone, (val) => tempPhone = val),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Odustani', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  userName = tempName;
                  userEmail = tempEmail;
                  userAddress = tempAddress;
                  userPhone = tempPhone;
                });
                Navigator.pop(context);
              },
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Color(0xFFFF85A2)),
              ),
              child: const Text(
                'Sačuvaj',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, String initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        controller: TextEditingController(text: initialValue),
        onChanged: onChanged,
      ),
    );
  }
}

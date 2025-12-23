import 'dart:ui';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true; // za sakrivanje/prikaz lozinke

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pozadina sa gradientom
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFC1CC), // svetlo roze
                  Color(0xFFF5E6DA), // bež
                  Color(0xFF800020), // bordo
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 50),

                    // Logo u kružiću
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withAlpha((0.3 * 255).toInt()),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/adora.jpg',
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Panel sa inputima i dugmadima
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                          decoration: BoxDecoration(
                            color: const Color(0xFF800020), // bordo panel
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((0.3 * 255).toInt()),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Email polje
                              TextField(
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: const TextStyle(color: Colors.white70),
                                  filled: true,
                                  fillColor: Colors.pink[100]?.withAlpha(50), // svetli roze okvir
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Password polje sa ikonicom oka
                              TextField(
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Lozinka',
                                  hintStyle: const TextStyle(color: Colors.white70),
                                  filled: true,
                                  fillColor: Colors.pink[100]?.withAlpha(50), // svetli roze okvir
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Prijavi se dugme (burgundi)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Ovde ide prava logika za login kasnije
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF800020),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text(
                                    'Prijavi se',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Registruj se dugme (belo dugme sa bordo slovima)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Otvaranje privremenog panela za registraciju
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        backgroundColor: const Color(0xFF800020), // bordo panel
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        title: const Text(
                                          'Registracija',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              style: const TextStyle(color: Colors.white),
                                              decoration: const InputDecoration(
                                                hintText: 'Ime i prezime',
                                                hintStyle: TextStyle(color: Colors.white70),
                                                filled: true,
                                                fillColor: Color.fromARGB(38, 255, 255, 255),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              style: const TextStyle(color: Colors.white),
                                              decoration: const InputDecoration(
                                                hintText: 'Email',
                                                hintStyle: TextStyle(color: Colors.white70),
                                                filled: true,
                                                fillColor: Color.fromARGB(38, 255, 255, 255),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              obscureText: true,
                                              style: const TextStyle(color: Colors.white),
                                              decoration: const InputDecoration(
                                                hintText: 'Lozinka',
                                                hintStyle: TextStyle(color: Colors.white70),
                                                filled: true,
                                                fillColor: Color.fromARGB(38, 255, 255, 255),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text(
                                              'Otkaži',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Registrovan (UI test)!')),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white, // belo dugme
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 14, horizontal: 20),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: const Text(
                                              'Registruj se',
                                              style: TextStyle(
                                                  color: Color(0xFF800020), // bordo slova
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white, // belo dugme
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text(
                                    'Registruj se',
                                    style: TextStyle(
                                      color: Color(0xFF800020), // bordo slova
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ✅ Dugme "Prijavi se kao gost" – sada izvan panela, uvek vidljivo
                    TextButton(
                      onPressed: () {
                        // Ovde ide logika za guest pristup
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Prijavljen kao gost (UI test)')),
                        );
                      },
                      child: const Text(
                        'Prijavi se kao gost',
                        style: TextStyle(
                          color: Colors.white, // svetla boja da se vidi
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

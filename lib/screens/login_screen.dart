import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _obscureRegisterPassword = true;

  // LOGIN
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // REGISTER
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regAddressController = TextEditingController();
  final _regPhoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFC1CC),
                  Color(0xFFF5E6DA),
                  Color(0xFF800020),
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
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/adora.jpg',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // GLASS CARD
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF800020),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('Email'),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(
                                  'Lozinka',
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
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

                              // PRIJAVA
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    const Color(0xFF5A0015),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final error =
                                    await userProvider.loginUser(
                                      email:
                                      _emailController.text.trim(),
                                      password:
                                      _passwordController.text.trim(),
                                    );

                                    if (error != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(error)),
                                      );
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                            const HomeScreen()),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Prijavi se',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // REGISTRACIJA
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    const Color(0xFFD87F7F),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {
                                    _showRegisterDialog(
                                        context, userProvider);
                                  },
                                  child: const Text(
                                    'Registruj se',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= REGISTER DIALOG =================
  void _showRegisterDialog(
      BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF800020),
        title: const Text(
          'Registracija',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _regField('Ime i prezime', _regNameController),
              _regField('Email', _regEmailController),
              _regField('Adresa', _regAddressController),
              _regField('Telefon', _regPhoneController),
              TextField(
                controller: _regPasswordController,
                obscureText: _obscureRegisterPassword,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  'Lozinka',
                  suffix: IconButton(
                    icon: Icon(
                      _obscureRegisterPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureRegisterPassword =
                        !_obscureRegisterPassword;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Otkaži',
                style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD87F7F),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final error = await userProvider.registerUser(
                name: _regNameController.text.trim(),
                email: _regEmailController.text.trim(),
                password: _regPasswordController.text.trim(),
                telefon: _regPhoneController.text.trim(),
                adresa: _regAddressController.text.trim(),
              );

              if (error != null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error)));
              } else {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HomeScreen()),
                );
              }
            },
            child: const Text('Registruj se'),
          ),
        ],
      ),
    );
  }

  Widget _regField(String hint, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(hint),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.15),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }
}

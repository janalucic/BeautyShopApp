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

  // Login kontroleri
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Registracija kontroleri
  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();

  // Validacija lozinke
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;
  bool _hasMinLength = false;

  void _validatePassword(String password) {
    setState(() {
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'\d'));
      _hasSpecial =
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasMinLength = password.length >= 8;
    });
  }

  bool _isValidPassword() {
    return _hasUppercase &&
        _hasNumber &&
        _hasSpecial &&
        _hasMinLength;
  }

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
                      backgroundColor:
                      Colors.white.withOpacity(0.3),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter:
                        ImageFilter.blur(sigmaX: 5, sigmaY: 5),
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
                                style:
                                const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('Email'),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style:
                                const TextStyle(color: Colors.white),
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
                                        _obscurePassword =
                                        !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final error =
                                    await userProvider.loginUser(
                                      email: _emailController.text.trim(),
                                      password:
                                      _passwordController.text.trim(),
                                    );

                                    if (error != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(error)),
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
                                  child: const Text('Prijavi se'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white),
                                  onPressed: () {
                                    _showRegisterDialog(context, userProvider);
                                  },
                                  child: const Text(
                                    'Registruj se',
                                    style: TextStyle(
                                        color: Color(0xFF800020)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  userProvider.loginAsGuest();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                        const HomeScreen()),
                                  );
                                },
                                child: const Text(
                                  'Prijavi se kao gost',
                                  style:
                                  TextStyle(color: Colors.white),
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

  // ================= VALIDATION ROW =================
  Widget _buildValidationRow(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green : Colors.red,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ================= REGISTER DIALOG =================
  void _showRegisterDialog(
      BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF800020),
        title: const Text('Registracija',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _regNameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Ime i prezime'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _regEmailController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _regPasswordController,
              obscureText: true,
              onChanged: _validatePassword,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Lozinka'),
            ),
            const SizedBox(height: 12),
            _buildValidationRow(
                'Bar jedno veliko slovo', _hasUppercase),
            _buildValidationRow('Bar jedan broj', _hasNumber),
            _buildValidationRow(
                'Bar jedan specijalni karakter', _hasSpecial),
            _buildValidationRow(
                'Najmanje 8 karaktera', _hasMinLength),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Otkaži',
                style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!_isValidPassword()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                      Text('Lozinka ne ispunjava uslove')),
                );
                return;
              }

              final error = await userProvider.registerUser(
                name: _regNameController.text.trim(),
                email: _regEmailController.text.trim(),
                password: _regPasswordController.text.trim(),
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

  InputDecoration _inputDecoration(String hint,
      {Widget? suffix}) {
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

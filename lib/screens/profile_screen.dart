import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.initUser();

    final user = userProvider.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _addressController.text = user.adresa ?? '';
      _phoneController.text = user.telefon ?? '';
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Pozadinska slika
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/profilepic.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD87F7F),
              ),
            )
                : Column(
              children: [
                // Gornja traka sa logout ikonom + tekst
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          userProvider.logout();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.logout, color: Colors.white, size: 28),
                            SizedBox(height: 4),
                            Text(
                              'Odjavi se',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userProvider.currentUser?.name ?? 'Nepoznat',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD87F7F),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userProvider.currentUser?.email ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFFBFA1A1),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userProvider.currentUser?.adresa ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFBFA1A1),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userProvider.currentUser?.telefon ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFBFA1A1),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () => _showEditDialog(context),
                          style: ButtonStyle(
                            backgroundColor: const MaterialStatePropertyAll(
                                Color(0xFFD87F7F)),
                            padding: const MaterialStatePropertyAll(
                              EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                            ),
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Uredite svoj profil',
                            style: TextStyle(
                                fontSize: 18, color: Colors.white),
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
                _buildTextField('Ime i prezime', _nameController),
                _buildTextField('Email', _emailController),
                _buildTextField('Adresa', _addressController),
                _buildTextField('Broj telefona', _phoneController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Odustani', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                final userProvider =
                Provider.of<UserProvider>(context, listen: false);
                final user = userProvider.currentUser;
                if (user == null) return;

                // Update u bazi
                try {
                  await userProvider.updateCurrentUser(
                    name: _nameController.text,
                    email: _emailController.text,
                    adresa: _addressController.text,
                    telefon: _phoneController.text,
                  );
                } catch (e) {
                  print('Greška pri update-u korisnika: $e');
                }

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

  Widget _buildTextField(String label, TextEditingController controller) {
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
        controller: controller,
      ),
    );
  }
}

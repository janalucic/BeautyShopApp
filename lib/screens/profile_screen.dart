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
  final _cityController = TextEditingController();
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
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.initUser();

    final user = userProvider.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _addressController.text = user.adresa ?? '';
      _cityController.text = user.grad ?? '';
      _phoneController.text = user.telefon ?? '';
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      body: Stack(
        children: [
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
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
                        children: const [
                          Icon(Icons.logout,
                              color: Colors.white, size: 28),
                          SizedBox(height: 4),
                          Text(
                            'Odjavi se',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.all(28),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userProvider.currentUser?.name ?? '',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB03A5B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _infoText(
                          userProvider.currentUser?.email ?? ''),
                      _infoText(
                          userProvider.currentUser?.adresa ?? ''),
                      _infoText(
                          userProvider.currentUser?.grad ?? ''),
                      _infoText(
                          userProvider.currentUser?.telefon ?? ''),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => _showEditDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFFB03A5B),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          'Uredite svoj profil',
                          style: TextStyle(
                              color: Colors.white, fontSize: 18),
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
  }

  Widget _infoText(String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF8B2C3E),
        ),
      ),
    );
  }

  // ===================== EDIT DIALOG =====================
  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF3C6CF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Izmeni profil',
          style: TextStyle(
            color: Color(0xFF8B2C3E),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(Icons.person, 'Ime i prezime', _nameController),
              _buildTextField(Icons.email, 'Email', _emailController),
              _buildTextField(
                  Icons.location_on, 'Adresa', _addressController),
              _buildTextField(
                  Icons.location_city, 'Grad', _cityController),
              _buildTextField(Icons.phone, 'Telefon', _phoneController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Odustani',
              style: TextStyle(color: Color(0xFF7A2435)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<UserProvider>().updateCurrentUser(
                name: _nameController.text,
                email: _emailController.text,
                adresa: _addressController.text,
                grad: _cityController.text,
                telefon: _phoneController.text,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB03A5B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Sačuvaj',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      IconData icon,
      String label,
      TextEditingController controller,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Color(0xFF7A2435)),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF9C3B4A)),
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF8B2C3E)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.75),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

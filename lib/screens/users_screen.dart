import 'dart:ui';
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final List<Map<String, String>> users = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Dijalog za dodavanje/izmenu korisnika
  void _showAddUserDialog({int? index}) {
    if (index != null) {
      final user = users[index];
      _nameController.text = user['name']!;
      _emailController.text = user['email']!;
      _addressController.text = user['address']!;
      _phoneController.text = user['phone']!;
    } else {
      _nameController.clear();
      _emailController.clear();
      _addressController.clear();
      _phoneController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF800020),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    index == null ? 'Dodaj korisnika' : 'Uredi korisnika',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_nameController, 'Ime', Icons.person),
                  const SizedBox(height: 10),
                  _buildTextField(_emailController, 'Email', Icons.email),
                  const SizedBox(height: 10),
                  _buildTextField(_addressController, 'Adresa', Icons.home),
                  const SizedBox(height: 10),
                  _buildTextField(_phoneController, 'Telefon', Icons.phone),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Otkaži', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF800020),
                        ),
                        onPressed: () {
                          if (_nameController.text.isNotEmpty &&
                              _emailController.text.isNotEmpty &&
                              _addressController.text.isNotEmpty &&
                              _phoneController.text.isNotEmpty) {
                            setState(() {
                              final newUser = {
                                'name': _nameController.text,
                                'email': _emailController.text,
                                'address': _addressController.text,
                                'phone': _phoneController.text,
                              };
                              if (index == null) {
                                users.add(newUser);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Korisnik uspešno dodat')),
                                );
                              } else {
                                users[index] = newUser;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Korisnik uspešno izmenjen')),
                                );
                              }
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: Text(index == null ? 'Dodaj' : 'Sačuvaj'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // TextField widget
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFFB03060).withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Confirm dijalog za brisanje korisnika
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF800020),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Da li ste sigurni?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Ova akcija će trajno obrisati korisnika.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Otkaži', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF800020),
                    ),
                    onPressed: () {
                      setState(() {
                        users.removeAt(index);
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Korisnik uspešno obrisan')),
                      );
                    },
                    child: const Text('Obriši'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pozadinska slika
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/cherry2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Tamniji overlay
          Container(color: const Color(0x80000000)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Korisnici',
                    style: TextStyle(
                      fontFamily: 'Spinnaker',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.6),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 255, 255, 0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: users.isEmpty
                              ? const Center(
                            child: Text(
                              'Trenutno nema korisnika.',
                              style: TextStyle(
                                fontFamily: 'Spinnaker',
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                              : ListView.separated(
                            itemCount: users.length,
                            separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return Card(
                                color: Colors.white.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  title: Text(
                                    user['name']!,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    '${user['email']}\n${user['address']}\n${user['phone']}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.white),
                                        onPressed: () =>
                                            _showAddUserDialog(index: index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Color(0xFF800020)), // burgundy
                                        onPressed: () =>
                                            _confirmDelete(index),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  right: 30,
                  child: FloatingActionButton(
                    backgroundColor: const Color(0xFF800020), // burgundy
                    foregroundColor: Colors.white,
                    onPressed: () => _showAddUserDialog(),
                    child: const Icon(Icons.add, size: 30),
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

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart'; // ispravno: user.dart

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _searchQuery = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    userProvider.fetchAllUsers();
  }

  // Dijalog za dodavanje/izmenu korisnika
  void _showAddUserDialog({UserModel? user}) {
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _addressController.text = user.adresa ?? '';
      _phoneController.text = user.telefon ?? '';
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
                    user == null ? 'Dodaj korisnika' : 'Uredi korisnika',
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
                        onPressed: () async {
                          final userProvider = context.read<UserProvider>();
                          if (_nameController.text.isNotEmpty &&
                              _emailController.text.isNotEmpty) {
                            if (user == null) {
                              // Dodavanje novog korisnika
                              await userProvider.registerUser(
                                name: _nameController.text,
                                email: _emailController.text,
                                password: 'default123',
                                adresa: _addressController.text,
                                telefon: _phoneController.text,
                              );
                            } else {
                              // Izmena postojećeg korisnika
                              await userProvider.updateUser(
                                UserModel(
                                  uid: user.uid,
                                  name: _nameController.text,
                                  email: _emailController.text,
                                  role: user.role,
                                  adresa: _addressController.text,
                                  telefon: _phoneController.text,
                                ),
                              );
                            }
                            Navigator.pop(context);
                          }
                        },
                        child: Text(user == null ? 'Dodaj' : 'Sačuvaj'),
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
  void _confirmDelete(UserModel user) {
    if (user.role == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ne možete obrisati drugog administratora')),
      );
      return;
    }

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
                    onPressed: () async {
                      final userProvider = context.read<UserProvider>();
                      await userProvider.deleteUser(user.uid);
                      Navigator.pop(context);
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
    final userProvider = context.watch<UserProvider>();
    final allUsers = userProvider.users;

    final filteredUsers = _searchQuery.isEmpty
        ? allUsers
        : allUsers
        .where((u) => u.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5E8E8),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Pretraži korisnike po imenu...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Card(
                    color: Colors.white.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      title: Text(user.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        '${user.email}\n${user.adresa ?? ''}\n${user.telefon ?? ''}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () => _showAddUserDialog(user: user),
                          ),
                          if (user.role != 'admin')
                            IconButton(
                              icon: const Icon(Icons.delete, color: Color(0xFF800020)),
                              onPressed: () => _confirmDelete(user),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF800020),
                foregroundColor: Colors.white,
                onPressed: () => _showAddUserDialog(),
                child: const Icon(Icons.add, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

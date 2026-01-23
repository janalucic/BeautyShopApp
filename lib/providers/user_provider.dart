import 'package:flutter/material.dart';

// Model korisnika
class User {
  final int id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

class UserProvider with ChangeNotifier {
  bool _isGuest = true; // po defaultu je gost
  int? _userId; // ID prijavljenog korisnika, null ako je guest

  // Lista korisnika (hardkodovana ili učitana iz baze)
  final List<User> _users = [
    User(id: 1, name: "Ana Petrović", email: "user@gmail.com", role: "user"),
    User(id: 2, name: "Administrator", email: "admin@beautyshop.com", role: "admin"),
  ];

  // =========================
  // GETTERS
  // =========================
  bool get isGuest => _isGuest;
  int? get userId => _userId;
  List<User> get users => _users;

  // Dohvati ime korisnika po ID
  String getUserNameById(int userId) {
    final user = _users.firstWhere(
          (u) => u.id == userId,
      orElse: () => User(id: 0, name: "Nepoznat", email: "", role: "user"),
    );
    return user.name;
  }

  // =========================
  // AUTH METODE
  // =========================
  void loginAsGuest() {
    _isGuest = true;
    _userId = null;
    notifyListeners();
  }

  void loginAsUser(int id) {
    _isGuest = false;
    _userId = id;
    notifyListeners();
  }

  void logout() {
    _isGuest = true;
    _userId = null;
    notifyListeners();
  }
}

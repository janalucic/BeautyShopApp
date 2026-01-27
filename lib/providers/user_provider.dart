import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user.dart'; // UserModel

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('Users');

  UserModel? _currentUser;
  bool _isGuest = true;
  bool _isLoading = false;

  // Lista svih korisnika
  List<UserModel> _users = [];

  // ===================== GETTERI =====================
  List<UserModel> get users => _users;
  UserModel? get currentUser => _currentUser;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;

  // ===================== INIT USER =====================
  Future<void> initUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      _currentUser = null;
      _isGuest = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _usersRef.child(firebaseUser.uid).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as dynamic);
        _currentUser = UserModel.fromMap(firebaseUser.uid, data);
        _isGuest = false;
      }
    } catch (e) {
      debugPrint('Greška initUser: $e');
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ===================== FETCH ALL USERS =====================
  Future<void> fetchAllUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _usersRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as dynamic);
        _users = data.entries.map((e) {
          final u = Map<dynamic, dynamic>.from(e.value);
          return UserModel.fromMap(e.key, u);
        }).toList();
      } else {
        _users = [];
      }
    } catch (e) {
      debugPrint('Greška fetchAllUsers: $e');
      _users = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ===================== DELETE USER =====================
  Future<void> deleteUser(String uid) async {
    try {
      await _usersRef.child(uid).remove();
      _users.removeWhere((u) => u.uid == uid);
      notifyListeners();
    } catch (e) {
      debugPrint('Greška deleteUser: $e');
    }
  }

  // ===================== UPDATE USER =====================
  Future<void> updateUser(UserModel user) async {
    try {
      await _usersRef.child(user.uid).update(user.toMap());
      final index = _users.indexWhere((u) => u.uid == user.uid);
      if (index != -1) _users[index] = user;
      notifyListeners();
    } catch (e) {
      debugPrint('Greška updateUser: $e');
    }
  }

  // ===================== REGISTER USER =====================
  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
    String role = 'user',
    String? telefon,
    String? adresa,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: role,
        telefon: telefon,
        adresa: adresa,
      );

      await _usersRef.child(uid).set(newUser.toMap());
      _currentUser = newUser;
      _isGuest = false;

      _users.add(newUser);
      notifyListeners();

      return null;
    } catch (e) {
      debugPrint('Greška registerUser: $e');
      return 'Registracija nije uspela.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===================== LOGIN USER =====================
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final snapshot = await _usersRef.child(uid).get();
      if (!snapshot.exists || snapshot.value == null) {
        return 'Korisnik postoji u Auth, ali nema zapis u bazi.';
      }

      final data = Map<dynamic, dynamic>.from(snapshot.value as dynamic);
      _currentUser = UserModel.fromMap(uid, data);
      _isGuest = false;

      return null;
    } catch (e) {
      debugPrint('Greška loginUser: $e');
      return 'Neispravni kredencijali.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===================== UPDATE CURRENT USER =====================
  Future<void> updateCurrentUser({
    required String name,
    required String email,
    String? telefon,
    String? adresa,
  }) async {
    if (_currentUser == null) return;

    final uid = _currentUser!.uid;
    await _usersRef.child(uid).update({
      'name': name,
      'email': email,
      if (telefon != null) 'telefon': telefon,
      if (adresa != null) 'adresa': adresa,
    });

    _currentUser = UserModel(
      uid: uid,
      name: name,
      email: email,
      role: _currentUser!.role,
      telefon: telefon,
      adresa: adresa,
    );

    notifyListeners();
  }

  // ===================== LOGOUT =====================
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _isGuest = true;
    notifyListeners();
  }

  // ===================== GUEST =====================
  void loginAsGuest() {
    _currentUser = null;
    _isGuest = true;
    notifyListeners();
  }
}

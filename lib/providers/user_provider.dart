import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// =======================
/// USER MODEL
/// =======================
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? telefon;
  final String? adresa;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.telefon,
    this.adresa,
  });

  factory UserModel.fromMap(String uid, Map<dynamic, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      telefon: data['telefon'],
      adresa: data['adresa'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      if (telefon != null && telefon!.isNotEmpty) 'telefon': telefon,
      if (adresa != null && adresa!.isNotEmpty) 'adresa': adresa,
    };
  }
}

/// =======================
/// USER PROVIDER
/// =======================
class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _usersRef =
  FirebaseDatabase.instance.ref('Users');

  UserModel? _currentUser;
  bool _isGuest = true;
  bool _isLoading = false;

  // =======================
  // GETTERS
  // =======================
  UserModel? get currentUser => _currentUser;
  bool get isGuest => _isGuest;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isLoading => _isLoading;

  // =======================
  // INIT USER (on app start)
  // =======================
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
        final data =
        Map<dynamic, dynamic>.from(snapshot.value as dynamic);

        _currentUser =
            UserModel.fromMap(firebaseUser.uid, data);
        _isGuest = false;
      } else {
        debugPrint(
            'Korisnik postoji u Auth, ali nema zapis u bazi');
        _currentUser = null;
        _isGuest = false;
      }
    } catch (e) {
      debugPrint('Greška initUser: $e');
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // =======================
  // LOGIN
  // =======================
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final snapshot = await _usersRef.child(uid).get();

      if (!snapshot.exists || snapshot.value == null) {
        return 'Korisnik postoji u Auth, ali nema zapis u bazi.';
      }

      final data =
      Map<dynamic, dynamic>.from(snapshot.value as dynamic);

      _currentUser = UserModel.fromMap(uid, data);
      _isGuest = false;

      return null;
    } on FirebaseAuthException catch (_) {
      return 'Neispravni kredencijali.';
    } catch (e) {
      debugPrint('Login error: $e');
      return 'Greška pri prijavi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =======================
  // REGISTRACIJA
  // =======================
  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
    String? telefon,
    String? adresa,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final user = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: 'user',
        telefon: telefon,
        adresa: adresa,
      );

      await _usersRef.child(uid).set(user.toMap());

      _currentUser = user;
      _isGuest = false;

      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Auth error: ${e.code}');
      return 'Registracija nije uspela.';
    } catch (e) {
      debugPrint('Register error: $e');
      return 'Greška pri registraciji.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =======================
  // UPDATE PROFILA
  // =======================
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
      'telefon': telefon,
      'adresa': adresa,
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

  // =======================
  // GUEST
  // =======================
  void loginAsGuest() {
    _currentUser = null;
    _isGuest = true;
    notifyListeners();
  }

  // =======================
  // LOGOUT
  // =======================
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _isGuest = true;
    notifyListeners();
  }
}
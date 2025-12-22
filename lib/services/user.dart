import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserService {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  // Registracija novog korisnika
  Future<void> createUser(User user) async {
    await usersCollection.doc(user.id.toString()).set(user.toJson());
  }

  // Login po emailu
  Future<User?> login(String email) async {
    var query = await usersCollection.where('email', isEqualTo: email).get();
    if (query.docs.isNotEmpty) {
      return User.fromJson(query.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Dohvat korisnika po ID-u
  Future<User?> getUserById(String id) async {
    var doc = await usersCollection.doc(id).get();
    if (doc.exists) {
      return User.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Ažuriranje korisnika
  Future<void> updateUser(User user) async {
    await usersCollection.doc(user.id.toString()).update(user.toJson());
  }

  // Brisanje korisnika (samo admin)
  Future<void> deleteUser(String id) async {
    await usersCollection.doc(id).delete();
  }
}

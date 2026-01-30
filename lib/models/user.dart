class UserModel {
  final String uid;       // Firebase UID
  final String name;
  final String email;
  final String role;
  final String? telefon;
  final String? adresa;
  final String? grad;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.telefon,
    this.adresa,
    this.grad,
  });

  factory UserModel.fromMap(String uid, Map<dynamic, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      telefon: map['telefon'],
      adresa: map['adresa'],
      grad: map['grad'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      if (telefon != null) 'telefon': telefon,
      if (adresa != null) 'adresa': adresa,
      if (grad != null) 'grad': grad,
    };
  }
}

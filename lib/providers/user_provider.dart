import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  bool _isGuest = false;

  bool get isGuest => _isGuest;

  void loginAsGuest() {
    _isGuest = true;
    notifyListeners();
  }

  void logout() {
    _isGuest = false;
    notifyListeners();
  }

  void loginAsUser() {
    _isGuest = false;
    notifyListeners();
  }
}

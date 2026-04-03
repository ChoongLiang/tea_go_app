import 'package:flutter/foundation.dart';

// Represents the user's profile data
class User {
  final String firstName;
  final String lastName;
  final String dob;
  final String gender;
  final String email;

  User({
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.gender,
    required this.email,
  });
}

// Manages the app's authentication state
class AuthModel extends ChangeNotifier {
  User? _currentUser;

  bool get isLoggedIn => _currentUser != null;
  User? get currentUser => _currentUser;

  void login(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateProfile(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

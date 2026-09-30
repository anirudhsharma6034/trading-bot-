import 'package:flutter/foundation.dart';
import '../core/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoggedIn => _currentUser != null;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepo.login(email, password);
      
      if (result is UserModel) {
        _currentUser = result;
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (result == 'invalid_email') {
        _errorMessage = 'Invalid email address. Account not found.';
      } else if (result == 'invalid_password') {
        _errorMessage = 'Invalid password. Please try again.';
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An error occurred during login';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authRepo.register(name, email, password);
      if (!success) {
        _errorMessage = 'Email already exists or registration failed';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'An error occurred during registration';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfileName(String newName) async {
    if (_currentUser != null) {
      await _authRepo.updateProfile(_currentUser!.id, newName);
      _currentUser = UserModel(
        id: _currentUser!.id,
        email: _currentUser!.email,
        name: newName,
      );
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

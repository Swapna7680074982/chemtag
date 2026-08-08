import 'package:flutter/material.dart';
import '../models/tse_user.dart';
import '../services/mock_dcr_service.dart';

class AuthProvider with ChangeNotifier {
  final MockDcrService _apiService = MockDcrService();

  TseUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  TseUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // _currentUser starts as null so LoginScreen opens first
  }

  Future<bool> login(String employeeId, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _apiService.login(employeeId, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Invalid credentials or network error.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

import 'package:account_managment/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthViewModel({required this.authRepository});

  String? _accessToken;
  String? get accessToken => _accessToken;

  String? _refreshToken;
  String? get refreshToken => _accessToken;

  Future<void> login(String username, String password) async {
    final repoResponse = await authRepository.login(username, password);
    _accessToken = repoResponse?["accessToken"];
    _refreshToken = repoResponse?["refreshToken"];

    notifyListeners();
  }

  void logout() {
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }
}

import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository = AuthRepository();
  final _storage = const FlutterSecureStorage();

  Future<List<dynamic>> login(String username, String password) async {
    final RepoResponse repoResponse =
        await authRepository.login(username, password);

    if (repoResponse.success) {
      await _storage.write(
          key: 'accessToken', value: repoResponse.data!['access']);
      await _storage.write(
          key: 'refreshToken', value: repoResponse.data!['refresh']);
    } else {
      repoResponse.error = repoResponse.data!["detail"];
    }

    return [repoResponse.success, repoResponse.error];
  }

  void logout() {
    authRepository.logout();
    // _accessToken = null;
    // _refreshToken = null;
    // notifyListeners();
  }
}

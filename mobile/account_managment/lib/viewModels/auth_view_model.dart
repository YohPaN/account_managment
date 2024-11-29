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
    } else if (repoResponse.message == "" ||
        repoResponse.data?["detail"] != null) {
      repoResponse.message = repoResponse.data?["detail"] ?? "";
    }

    return [repoResponse.success, repoResponse.message];
  }

  void logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }
}

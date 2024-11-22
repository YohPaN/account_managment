import 'package:account_managment/helpers/request_handler.dart';
import 'package:account_managment/models/repo_reponse.dart';

class AuthRepository {
  Future<RepoResponse> login(String username, String password) async {
    final RepoResponse responseData = await RequestHandler.handleRequest(
        method: "POST",
        uri: "token/",
        contentType: "application/json",
        needAuth: false,
        body: {
          'username': username,
          'password': password,
        });

    return responseData;
  }

  Future<void> logout() async {
    // await _storage.delete(key: 'accessToken');
    // await _storage.delete(key: 'refreshToken');
  }
}

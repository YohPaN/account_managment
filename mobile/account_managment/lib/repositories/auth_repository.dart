import 'package:account_managment/helpers/request_handler.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  Future<RepoResponse> refreshToken() async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
        method: "POST",
        uri: "token/refresh/",
        contentType: "application/json",
        needAuth: false,
        body: {
          'refresh':
              await const FlutterSecureStorage().read(key: "refreshToken"),
        });

    return repoResponse;
  }
}

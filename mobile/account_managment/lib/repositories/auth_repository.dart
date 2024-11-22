import 'dart:convert';

import 'package:account_managment/common/api_config.dart';
import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/helpers/request_handler.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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
    print(responseData.success);
    print(responseData.data);
    print(responseData.error);
    return responseData;
  }

  Future<void> logout() async {
    // await _storage.delete(key: 'accessToken');
    // await _storage.delete(key: 'refreshToken');
  }
}

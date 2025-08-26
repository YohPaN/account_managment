import 'package:account_managment/common/request_handler.dart';

import 'package:account_managment/models/repo_reponse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountUserRepository {
  final storage = const FlutterSecureStorage();
  final modelUrl = "account_user";

  Future<RepoResponse> list() async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "GET",
      uri: "$modelUrl/",
      contentType: 'application/json',
    );

    return repoResponse;
  }

  Future<RepoResponse> create() async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "$modelUrl/",
      contentType: 'application/json',
      body: {},
    );

    return repoResponse;
  }

  Future<RepoResponse> partialUpdate(
      {required int accountUserId, required String state}) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "PATCH",
      uri: "$modelUrl/$accountUserId/",
      contentType: 'application/json',
      body: {"state": state},
    );

    return repoResponse;
  }
}

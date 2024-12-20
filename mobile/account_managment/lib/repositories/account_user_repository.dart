import 'package:account_managment/helpers/request_handler.dart';

import 'package:account_managment/models/repo_reponse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountUserRepository {
  final storage = const FlutterSecureStorage();
  final model_url = "account_user";

  Future<RepoResponse> list() async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "GET",
      uri: "$model_url/",
      contentType: 'application/json',
    );

    return repoResponse;
  }

  Future<RepoResponse> count() async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "GET",
      uri: "$model_url/count/",
      contentType: 'application/json',
    );

    return repoResponse;
  }

  Future<RepoResponse> create(String name, List<String> contributors) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "$model_url/",
      contentType: 'application/json',
      body: {},
    );

    return repoResponse;
  }
}

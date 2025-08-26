import 'package:account_managment/common/request_handler.dart';

import 'package:account_managment/models/repo_reponse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountRepository {
  final storage = const FlutterSecureStorage();
  final modelUrl = "accounts";

  Future<RepoResponse> list() async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "GET",
      uri: "$modelUrl/",
    );

    return repoResponse;
  }

  Future<RepoResponse> get(int? accountId) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "GET",
      uri: "$modelUrl/${accountId ?? "me"}/",
    );

    return repoResponse;
  }

  Future<RepoResponse> create(String name) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "$modelUrl/",
      body: {'name': name},
    );

    return repoResponse;
  }

  Future<RepoResponse> update({
    required int id,
    required String name,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "PATCH",
      uri: "$modelUrl/$id/",
      body: {'name': name},
    );

    return repoResponse;
  }

  Future<RepoResponse> delete(int accountId) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "DELETE",
      uri: "$modelUrl/$accountId/",
    );

    return repoResponse;
  }

  Future<RepoResponse> addContributor({
    required int id,
    required String username,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "$modelUrl/$id/contributors/add/",
      body: {'user_username': username},
    );

    return repoResponse;
  }

  Future<RepoResponse> removeContributor({
    required int id,
    required String username,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "$modelUrl/$id/contributors/remove/",
      body: {'user_username': username},
    );

    return repoResponse;
  }

  Future<RepoResponse> listItemPermissions(
      {required int accountId, required String username}) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "GET",
      uri: "$modelUrl/$accountId/$username/permissions/",
    );

    return repoResponse;
  }

  Future<RepoResponse> manageItemPermissions({
    required int id,
    required String username,
    required String permission,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "$modelUrl/$id/$username/permissions/",
      body: {
        'permission': permission,
      },
    );

    return repoResponse;
  }

  Future<RepoResponse> setSalaryBasedSplit({
    int? accountId,
    required bool isSplit,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "$modelUrl/$accountId/split/",
      body: {
        'is_slit': isSplit ? "True" : "False",
      },
    );

    return repoResponse;
  }
}

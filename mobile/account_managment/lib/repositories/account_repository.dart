import 'package:account_managment/helpers/request_handler.dart';

import 'package:account_managment/models/repo_reponse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountRepository {
  final storage = const FlutterSecureStorage();
  final modelUrl = "accounts";

  Future<RepoResponse> list() async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "GET",
      uri: "$modelUrl/",
      contentType: 'application/json',
    );

    return repoResponse;
  }

  Future<RepoResponse> get(int? accountId) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "GET",
      uri: "$modelUrl/${accountId ?? "me"}/",
      contentType: 'application/json',
    );

    return repoResponse;
  }

  Future<RepoResponse> create(String name, List<String> contributors) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "$modelUrl/",
      contentType: 'application/json',
      body: {'name': name, 'contributors': contributors},
    );

    return repoResponse;
  }

  Future<RepoResponse> update(
      int accountId, String name, List<String> contributors) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "PATCH",
      uri: "$modelUrl/$accountId/",
      contentType: 'application/json',
      body: {'name': name, 'contributors': contributors},
    );

    return repoResponse;
  }

  Future<RepoResponse> delete(int accountId) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "DELETE",
      uri: "$modelUrl/$accountId/",
      contentType: 'application/json',
    );

    return repoResponse;
  }

  Future<RepoResponse> createItem({
    required String title,
    required String description,
    required String valuation,
    required int accountId,
    String? username,
    String? toAccount,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "$modelUrl/$accountId/items/",
      contentType: 'application/json',
      body: {
        'account': accountId.toString(),
        if (username != null) 'username': username,
        if (toAccount != null) 'to_account': toAccount,
        'title': title,
        'description': description,
        'valuation': valuation,
      },
    );

    return repoResponse;
  }

  Future<RepoResponse> updateItem({
    required String title,
    required String description,
    required String valuation,
    required int accountId,
    required String? username,
    required String? toAccount,
    required int itemId,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "PUT",
      uri: "$modelUrl/$accountId/items/$itemId/",
      contentType: 'application/json',
      body: {
        'account': accountId.toString(),
        if (username != null) 'username': username,
        if (toAccount != null) 'to_account': toAccount,
        'title': title,
        'description': description,
        'valuation': valuation,
      },
    );

    return repoResponse;
  }

  Future<RepoResponse> deleteItem(int itemId, int accountId) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "DELETE",
      uri: "$modelUrl/$accountId/items/$itemId/",
      contentType: 'application/json',
    );

    return repoResponse;
  }

  Future<RepoResponse> listItemPermissions(
      {required int accountId, required String username}) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "GET",
      uri: "$modelUrl/$accountId/$username/permissions/",
      contentType: 'application/json',
    );

    return repoResponse;
  }

  Future<RepoResponse> manageItemPermissions(
      {int? accountId,
      required String username,
      required List<String> permissions}) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "$modelUrl/$accountId/$username/permissions/",
      contentType: 'application/json',
      body: {
        'permissions': permissions,
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
      contentType: 'application/json',
      body: {
        'is_slit': isSplit ? "True" : "False",
      },
    );

    return repoResponse;
  }
}

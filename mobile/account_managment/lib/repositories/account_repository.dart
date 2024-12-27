import 'package:account_managment/helpers/request_handler.dart';

import 'package:account_managment/models/repo_reponse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountRepository {
  final storage = const FlutterSecureStorage();
  final model_url = "accounts";

  Future<RepoResponse> list() async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "GET",
      uri: "$model_url/",
      contentType: 'application/json',
    );

    return repoResponse;
  }

  Future<RepoResponse> get(int? accountId) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "GET",
      uri: "$model_url/${accountId ?? "me"}/",
      contentType: 'application/json',
    );

    return repoResponse;
  }

  Future<RepoResponse> create(String name, List<String> contributors) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "$model_url/",
      contentType: 'application/json',
      body: {'name': name, 'contributors': contributors},
    );

    return repoResponse;
  }

  Future<RepoResponse> update(
      int accountId, String name, List<String> contributors) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "PATCH",
      uri: "$model_url/$accountId/",
      contentType: 'application/json',
      body: {'name': name, 'contributors': contributors},
    );

    return repoResponse;
  }

  Future<RepoResponse> delete(int accountId) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "DELETE",
      uri: "$model_url/$accountId/",
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
      uri: "$model_url/$accountId/items/",
      contentType: 'application/json',
      body: {
        'account': accountId.toString(),
        if (username != null) 'username': username,
        if (toAccount != null) 'toAccount': toAccount,
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
      uri: "$model_url/$accountId/items/$itemId/",
      contentType: 'application/json',
      body: {
        'account': accountId.toString(),
        if (username != null) 'username': username,
        if (toAccount != null) 'toAccount': toAccount,
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
      uri: "$model_url/$accountId/items/$itemId/",
      contentType: 'application/json',
    );

    return repoResponse;
  }

  Future<RepoResponse> listItemPermissions(
      {required int accountId, required String username}) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "GET",
      uri: "$model_url/$accountId/$username/permissions/",
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
      uri: "$model_url/$accountId/$username/permissions/",
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
      uri: "$model_url/$accountId/split/",
      contentType: 'application/json',
      body: {
        'is_slit': isSplit ? "True" : "False",
      },
    );

    return repoResponse;
  }
}

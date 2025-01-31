import 'package:account_managment/helpers/request_handler.dart';

import 'package:account_managment/models/repo_reponse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CategoryRepository {
  final storage = const FlutterSecureStorage();
  final modelUrl = "categories";

  Future<RepoResponse> create({
    required String title,
    required String icon,
    required String color,
    int? accountId,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "$modelUrl/",
      contentType: 'application/json',
      body: {
        'title': title,
        'icon': icon,
        'color': color,
        if (accountId != null) 'account_id': accountId,
      },
    );

    return repoResponse;
  }

  Future<RepoResponse> update({
    required int categoryId,
    required String title,
    required String icon,
    required String color,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "PUT",
      uri: "$modelUrl/$categoryId/",
      contentType: 'application/json',
      body: {
        'title': title,
        'icon': icon,
        'color': color,
      },
    );

    return repoResponse;
  }

  Future<RepoResponse> delete({
    required int categoryId,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "DELETE",
      uri: "$modelUrl/$categoryId/",
      contentType: 'application/json',
    );

    return repoResponse;
  }

  Future<RepoResponse> link(
      {required int account, required int category}) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "account-categories/",
      contentType: 'application/json',
      body: {
        'account': account,
        'category': category,
      },
    );

    return repoResponse;
  }
}

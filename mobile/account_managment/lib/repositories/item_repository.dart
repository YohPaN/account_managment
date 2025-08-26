import 'package:account_managment/common/request_handler.dart';
import 'package:account_managment/models/repo_reponse.dart';

class ItemRepository {
  final modelUrl = "items";

  Future<RepoResponse> create({
    required String title,
    required String description,
    required String valuation,
    required int accountId,
    int? categoryId,
    String? username,
    String? toAccount,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "$modelUrl/",
      contentType: 'application/json',
      body: {
        'account': accountId.toString(),
        if (username != null) 'username': username,
        if (toAccount != null) 'to_account': toAccount,
        'title': title,
        'description': description,
        'valuation': valuation,
        if (categoryId != null) 'category_id': categoryId.toString(),
      },
    );

    return repoResponse;
  }

  Future<RepoResponse> update({
    required String title,
    required String description,
    required String valuation,
    int? categoryId,
    String? username,
    String? toAccount,
    required int itemId,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "PUT",
      uri: "$modelUrl/$itemId/",
      contentType: 'application/json',
      body: {
        if (username != null) 'username': username,
        if (toAccount != null) 'to_account': toAccount,
        if (categoryId != null) 'category_id': categoryId.toString(),
        'title': title,
        'description': description,
        'valuation': valuation,
      },
    );

    return repoResponse;
  }

  Future<RepoResponse> delete(int itemId) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "DELETE",
      uri: "$modelUrl/$itemId/",
      contentType: 'application/json',
    );

    return repoResponse;
  }
}

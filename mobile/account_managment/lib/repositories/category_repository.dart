import 'dart:convert';

import 'package:account_managment/common/request_handler.dart';

import 'package:account_managment/models/repo_reponse.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CategoryRepository {
  final storage = const FlutterSecureStorage();
  final modelUrl = "categories";

  Future<RepoResponse> list({
    required int accountId,
    required String categoryType,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "GET",
      uri: "$modelUrl/?category=$categoryType&account=$accountId",
    );

    return repoResponse;
  }

  Future<RepoResponse> create({
    required String title,
    required IconPickerIcon icon,
    required int color,
    required String contentType,
    int? objectId,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "$modelUrl/",
      body: {
        'title': title,
        'icon': jsonEncode(serializeIcon(icon)),
        'color': color,
        'content_type': contentType,
        if (objectId != null) 'object_id': objectId,
      },
    );

    return repoResponse;
  }

  Future<RepoResponse> update({
    required int categoryId,
    required String title,
    required IconPickerIcon icon,
    required int color,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "PUT",
      uri: "$modelUrl/$categoryId/",
      body: {
        'title': title,
        'icon': jsonEncode(serializeIcon(icon)),
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
    );

    return repoResponse;
  }

  Future<RepoResponse> link({
    required int account,
    required int category,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "account-categories/",
      body: {
        'account': account,
        'category': category,
      },
    );

    return repoResponse;
  }

  Future<RepoResponse> unlink({
    required int account,
    required int category,
  }) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "POST",
      uri: "account-categories/unlink/",
      body: {
        'account': account,
        'category': category,
      },
    );

    return repoResponse;
  }

  Future<RepoResponse> getDefault() async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "GET",
      uri: "$modelUrl/?category=default",
    );

    return repoResponse;
  }
}

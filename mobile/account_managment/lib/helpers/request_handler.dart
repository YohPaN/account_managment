import 'dart:convert';

import 'package:account_managment/common/api_config.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class RequestHandler {
  static const storage = FlutterSecureStorage();

  static final List<int> SUCCESS_HTTP_CODE = [
    200,
    201,
    204,
  ];

  static Future<dynamic> handleRequest(
      {required String method,
      required String uri,
      required String contentType,
      bool? needAuth = true,
      Map<String, dynamic>? body}) async {
    http.Response? response;
    Map<String, dynamic>? data;
    String? error;
    bool success = false;

    try {
      switch (method) {
        case "GET":
          response = await http.get(
            buildUri(uri),
            headers: buildHeaders(contentType, needAuth),
          );
          break;

        case "POST":
          if (body == null) {
            break;
          }

          response = await http.post(
            buildUri(uri),
            headers: await buildHeaders(contentType, needAuth),
            body: jsonEncode(body),
          );

          break;

        case "PUT":
          if (body == null) {
            break;
          }
          response = await http.put(
            buildUri(uri),
            headers: await buildHeaders(contentType, needAuth),
            body: jsonEncode(body),
          );

          break;

        case "PATCH":
          if (body == null) {
            break;
          }
          response = await http.patch(
            buildUri(uri),
            headers: await buildHeaders(contentType, needAuth),
            body: jsonEncode(body),
          );

          break;

        case "DELETE":
          response = await http.delete(
            buildUri(uri),
            headers: await buildHeaders(contentType, needAuth),
          );
          break;

        default:
          error = "Method not handle";
      }
      if (response != null) {
        data = jsonDecode(response.body);
        error = checkFields(data);
        success = SUCCESS_HTTP_CODE.contains(response.statusCode);
      } else {
        error = "No response";
      }
    } catch (e) {
      error = e.toString();
    }
    return RepoResponse(data: data, success: success, error: error);
  }

  static buildHeaders(String contentType, bool? needAuth) async {
    var headers = <String, String>{};
    String? accessToken = await storage.read(key: 'accessToken');

    switch (contentType) {
      case "application/json":
        headers.addEntries({'Content-Type': 'application/json'}.entries);
        break;
      default:
    }

    if (needAuth == true) {
      headers.addEntries({'Authorization': 'Bearer $accessToken'}.entries);
    }

    return headers;
  }

  static buildUri(String uri) {
    return Uri.parse("http://${APIConfig.base_url}:${APIConfig.port}/api/$uri");
  }

  static checkFields(data) {
    if (data["error"] != null) {
      return data["error"];
    }

    for (var field in data.entries) {
      if (field.value[0] == "This field may not be blank.") {
        return "The field ${field.key} may not be blank.";
      }
    }

    return null;
  }
}

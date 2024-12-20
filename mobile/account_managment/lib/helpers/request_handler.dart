import 'dart:async';
import 'dart:convert';

import 'package:account_managment/common/api_config.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/repositories/auth_repository.dart';
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
    dynamic data;
    String action = "";

    bool success = false;

    try {
      switch (method) {
        case "GET":
          action = "retrieve";
          response = await http
              .get(
                buildUri(uri),
                headers: await buildHeaders(contentType, needAuth),
              )
              .timeout(const Duration(seconds: 5));

          break;

        case "POST":
          action = "create or update";

          if (body == null) {
            break;
          }

          response = await http.post(
            buildUri(uri),
            headers: await buildHeaders(contentType, needAuth),
            body: serializeBody(body),
          );

          break;

        case "PUT":
          action = "update";

          if (body == null) {
            break;
          }
          response = await http.put(
            buildUri(uri),
            headers: await buildHeaders(contentType, needAuth),
            body: serializeBody(body),
          );

          break;

        case "PATCH":
          action = "update";

          if (body == null) {
            break;
          }
          response = await http.patch(
            buildUri(uri),
            headers: await buildHeaders(contentType, needAuth),
            body: serializeBody(body),
          );

          break;

        case "DELETE":
          action = "delete";

          response = await http.delete(
            buildUri(uri),
            headers: await buildHeaders(contentType, needAuth),
          );
          break;

        default:
          return RepoResponse(
            success: false,
            message: "Method not handle",
          );
      }

      if (response == null) {
        return RepoResponse(success: false, message: "No response !");
      }

      success = SUCCESS_HTTP_CODE.contains(response.statusCode);
      if (response.body != "") {
        data = jsonDecode(response.body);
      }

      if (!success && data == null) {
        return RepoResponse(success: false, message: "No data !");
      } else if (!success && data != null) {
        if (data.containsKey("code") && data["code"] == "token_not_valid") {
          final RepoResponse repoResponse =
              await AuthRepository().refreshToken();

          if (repoResponse.success) {
            await storage.write(
              key: 'accessToken',
              value: repoResponse.data!['access'],
            );

            return handleRequest(
              method: method,
              uri: uri,
              contentType: contentType,
            );
          } else {
            return RepoResponse(
              success: false,
              message: repoResponse.data!["detail"],
            );
          }
        }

        return RepoResponse(
            success: false,
            message: jsonDecode(response.body).containsKey("error")
                ? jsonDecode(response.body)["error"]
                : jsonDecode(response.body).containsKey("detail")
                    ? jsonDecode(response.body)["detail"]
                    : "An error happend");
      }
    } on TimeoutException {
      return RepoResponse(
        success: false,
        message: "Unable to contact server",
      );
    } catch (e) {
      return RepoResponse(
        success: false,
        message: e.toString(),
      );
    }

    return RepoResponse(
      data: data,
      success: true,
      message: "Ressource $action successfully",
    );
  }

  static Future<Map<String, String>> buildHeaders(
      String contentType, bool? needAuth) async {
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

  static Uri buildUri(String uri) {
    return Uri.parse("http://${APIConfig.base_url}:${APIConfig.port}/api/$uri");
  }

  static String serializeBody(Map<String, dynamic> body) {
    for (var element in body.entries) {
      if (element.value.runtimeType != String) {
        body[element.key] = jsonEncode(element.value);
      }
    }

    return jsonEncode(body);
  }
}

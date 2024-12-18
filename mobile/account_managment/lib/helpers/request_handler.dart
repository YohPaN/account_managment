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
    Map<String, dynamic>? data;
    String message = "";
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
          message = "Method not handle";
      }

      if (response != null) {
        if (response.body != "") {
          data = jsonDecode(response.body);

          if (data!["code"] == "token_not_valid") {
            final RepoResponse repoResponse =
                await AuthRepository().refreshToken();

            if (repoResponse.success) {
              await storage.write(
                  key: 'accessToken', value: repoResponse.data!['access']);

              return handleRequest(
                  method: method, uri: uri, contentType: contentType);
            } else {
              message = repoResponse.data!["detail"];
            }
          }

          message = checkFields(data);
        }
//TODO: améliorer la logique ici,  c'est un peu bruoillon
        success = SUCCESS_HTTP_CODE.contains(response.statusCode);

        if (message == "" && success) {
          message = "Ressource $action successfully";
        } else if (message == "" && !success) {
          message = jsonDecode(response.body)["error"];
        }
      } else {
        message = "No response";
      }
    } on TimeoutException {
      message = "Unable to contact server";
    } catch (e) {
      message = e.toString();
    }

    return RepoResponse(data: data, success: success, message: message);
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

  static String checkFields(data) {
    for (var field in data.entries) {
      if (field.value is Iterable && !field.value.isEmpty) {
        if (field.value[0] == "This field may not be blank.") {
          return "The field ${field.key} may not be blank.";
        }
      }
    }

    return "";
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

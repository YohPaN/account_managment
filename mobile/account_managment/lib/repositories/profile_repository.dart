import 'package:account_managment/common/request_handler.dart';
import 'package:account_managment/models/repo_reponse.dart';

class ProfileRepository {
  final modelUrl = "users";

  Future<RepoResponse> get() async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
      method: "GET",
      uri: "$modelUrl/me/",
      contentType: 'application/json',
    );

    return repoResponse;
  }

  Future<RepoResponse> create(String username, String firstName,
      String lastName, String email, String salary, String password) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
        method: "POST",
        uri: "register/",
        contentType: 'application/json',
        needAuth: false,
        body: {
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'salary': salary,
          'password': password,
        });

    return repoResponse;
  }

  Future<RepoResponse> update(String username, String firstName,
      String lastName, String email, String salary, String password) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
        method: "PATCH",
        uri: "$modelUrl/me/update/",
        contentType: 'application/json',
        body: {
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'salary': salary,
          'password': password,
        });

    return repoResponse;
  }

  Future<RepoResponse> updatePassword(
      String oldPassword, String newPassword) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
        method: "PATCH",
        uri: "$modelUrl/password/",
        contentType: 'application/json',
        body: {
          'old_password': oldPassword,
          'new_password': newPassword,
        });

    return repoResponse;
  }
}

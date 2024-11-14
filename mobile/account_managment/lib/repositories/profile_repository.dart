import 'dart:convert';

import 'package:account_managment/models/profile.dart';
import 'package:account_managment/models/user.dart';
import 'package:account_managment/viewModels/auth_view_model.dart';
import 'package:http/http.dart' as http;

class ProfileRepository {
  final AuthViewModel authViewModel;

  ProfileRepository({required this.authViewModel});

  Future<bool> create(String username, String firstName, String lastName,
      String email, String salary, String password) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/register/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'salary': salary,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }

  Future<Map<String, dynamic>?> get() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/users/me/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authViewModel.accessToken}'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final user = User(
          username: data["username"],
          email: data["email"],
          password: data["password"]);

      final profile = Profile(
          firstName: data["profile"]["first_name"],
          lastName: data["profile"]["last_name"],
          salary: double.parse(data["profile"]["salary"]));

      return {"user": user, "profile": profile};
    }

    return null;
  }

  Future<Map<String, dynamic>?> update(String username, String firstName,
      String lastName, String email, String salary, String password) async {
    final response = await http.patch(
      Uri.parse('http://10.0.2.2:8000/api/users/me/update/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authViewModel.accessToken}'
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'salary': salary,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User(
          username: data["username"],
          email: data["email"],
          password: data["password"]);

      final profile = Profile(
          firstName: data["profile"]["first_name"],
          lastName: data["profile"]["last_name"],
          salary: double.parse(data["profile"]["salary"]));

      return {"user": user, "profile": profile};
    }

    return null;
  }
}

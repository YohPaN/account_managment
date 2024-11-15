import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>?> login(String username, String password) async {
    var accessToken = "";
    var refreshToken = "";

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/token/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      accessToken = responseData['access'];
      refreshToken = responseData['refresh'];

      // Store the token securely
      await _storage.write(key: 'accessToken', value: accessToken);
      await _storage.write(key: 'refreshToken', value: refreshToken);

      return {"accessToken": accessToken, "refreshToken": refreshToken};
    }

    return null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }
}

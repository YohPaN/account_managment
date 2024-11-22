import 'package:account_managment/models/profile.dart';
import 'package:account_managment/models/user.dart';
import 'package:account_managment/repositories/profile_repository.dart';
import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository profileRepository = ProfileRepository();

  User? _user;
  User? get user => _user;

  Profile? _profile;
  Profile? get profile => _profile;

  Future<void> getProfile() async {
    final response = await profileRepository.get();
    if (response != null) {
      _user = response["user"];
      _profile = response["profile"];
    }

    notifyListeners();
  }

  Future<void> createProfile(String username, String firstName, String lastName,
      String email, String salary, String password) async {
    bool success = await profileRepository.create(
        username, firstName, lastName, email, salary, password);

    if (success) {
      _profile = Profile(
        firstName: firstName,
        lastName: lastName,
        salary: double.parse(salary),
      );
      notifyListeners();
    }
  }

  Future<void> updateProfile(String username, String firstName, String lastName,
      String email, String salary, String password) async {
    Map<String, dynamic>? response = await profileRepository.update(
        username, firstName, lastName, email, salary, password);

    if (response != null) {
      _user = response["user"];
      _profile = response["profile"];
      notifyListeners();
    }
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    await profileRepository.updatePassword(oldPassword, newPassword);
    notifyListeners();
  }
}

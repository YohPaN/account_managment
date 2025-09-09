import 'package:account_managment/common/model_factory.dart';
import 'package:account_managment/models/profile.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/models/user.dart';
import 'package:account_managment/repositories/profile_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository profileRepository = ProfileRepository();

  ProfileViewModel();

  User? _user;
  User? get user => _user;

  Profile? _profile;
  Profile? get profile => _profile;

  Future<RepoResponse> getProfile() async {
    final RepoResponse repoResponse = await profileRepository.get();

    if (repoResponse.success) {
      _user = User.deserialize(repoResponse.data);
      _profile = Profile.deserialize(repoResponse.data!["profile"]);
      for (var category in repoResponse.data!["categories"]) {
        _profile!.categories
            .add(ModelFactory.fromJson(json: category, type: 'category'));
      }
    }

    return repoResponse;
  }

  Future<RepoResponse> createProfile(String username, String firstName,
      String lastName, String email, String salary, String password) async {
    final RepoResponse repoResponse = await profileRepository.create(
        username, firstName, lastName, email, salary, password);

    return repoResponse;
  }

  Future<RepoResponse> updateProfile(String username, String firstName,
      String lastName, String email, String salary, String password) async {
    final RepoResponse repoResponse = await profileRepository.update(
        username, firstName, lastName, email, salary, password);

    if (repoResponse.success) {
      _user = User.updateData(repoResponse.data, user!);
      _profile = Profile.updateData(repoResponse.data, profile!);
    }

    return repoResponse;
  }

  Future<RepoResponse> updatePassword(
      String oldPassword, String newPassword) async {
    final RepoResponse repoResponse =
        await profileRepository.updatePassword(oldPassword, newPassword);

    return repoResponse;
  }

  void clear() {
    _user = null;
    _profile = null;
  }
}

import 'package:account_managment/models/account_user.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/repositories/account_user_repository.dart';
import 'package:flutter/material.dart';

class AccountUserViewModel extends ChangeNotifier {
  final AccountUserRepository accountUserRepository = AccountUserRepository();

  int _accountUsersCount = 0;
  int get accountUsersCount => _accountUsersCount;

  final List<AccountUser> _accountUsers = [];
  List<AccountUser> get accountUsers => _accountUsers;

  Future<void> countAccountUser() async {
    final RepoResponse repoResponse = await accountUserRepository.count();

    int count = 0;
    if (repoResponse.success && repoResponse.data != null) {
      count = repoResponse.data!["pending_account_request"];
    }

    _accountUsersCount = count;
    notifyListeners();
  }

  Future<RepoResponse> listAccountUser() async {
    final RepoResponse repoResponse = await accountUserRepository.list();
    _accountUsers.clear();

    if (repoResponse.success && repoResponse.data != null) {
      for (var accountUser in repoResponse.data) {
        final deserializeAccountUser = AccountUser.deserialize(accountUser);

        _accountUsers.add(deserializeAccountUser);
      }
    }

    return repoResponse;
  }

  Future<RepoResponse> partialUpdateAccountUser(
      {required int accountUserId, required String state}) async {
    final RepoResponse repoResponse = await accountUserRepository.partialUpdate(
        accountUserId: accountUserId, state: state);

    countAccountUser();

    return repoResponse;
  }
}

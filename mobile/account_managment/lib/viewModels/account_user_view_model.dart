import 'package:account_managment/models/account_user.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/repositories/account_user_repository.dart';
import 'package:flutter/material.dart';

class AccountUserViewModel extends ChangeNotifier {
  final AccountUserRepository accountUserRepository = AccountUserRepository();

  final List<AccountUser> _accountUsers = [];
  List<AccountUser> get accountUsers => _accountUsers;

  Future<int> countAccountUser() async {
    final RepoResponse repoResponse = await accountUserRepository.count();

    int count = 0;
    if (repoResponse.success && repoResponse.data != null) {
      count = repoResponse.data!["pending_account_request"];
    }

    return count;
  }

  Future<RepoResponse> listAccountUser() async {
    final RepoResponse repoResponse = await accountUserRepository.list();

    if (repoResponse.success && repoResponse.data != null) {
      for (var accountUser in repoResponse.data) {
        final deserializeAccountUser = AccountUser.deserialize(accountUser);

        _accountUsers.add(deserializeAccountUser);
      }
    }

    return repoResponse;
  }
}

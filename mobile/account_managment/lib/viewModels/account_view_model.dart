import 'package:account_managment/common/model_factory.dart';
import 'package:account_managment/models/account.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/repositories/account_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AccountViewModel extends ChangeNotifier {
  final AccountRepository accountRepository = AccountRepository();

  List<Account> _accounts = [];
  List<Account> get accounts => _accounts;

  List<Account>? _contributorAccounts;
  List<Account>? get contributorAccounts => _contributorAccounts;

  Account? account;

  int? accountIdToRetrieve;

  Future<RepoResponse> listAccount({required String user}) async {
    final RepoResponse repoResponse = await accountRepository.list();

    if (repoResponse.success && repoResponse.data != null) {
      _accounts = [
        ...ModelFactory.fromJson(
            json: repoResponse.data
                .where((account) => account["user"]["username"] == user)
                .toList(),
            type: 'account')
      ];

      _contributorAccounts = [
        ...ModelFactory.fromJson(
            json: repoResponse.data
                .where((account) => account["user"]["username"] != user)
                .toList(),
            type: 'account')
      ];
    }

    return repoResponse;
  }

  Future<RepoResponse> getAccount([int? accountId]) async {
    final RepoResponse repoResponse = await accountRepository.get(accountId);

    if (repoResponse.success && repoResponse.data != null) {
      account = ModelFactory.fromJson(json: repoResponse.data, type: 'account')
          as Account;
    }

    accountIdToRetrieve = null;

    return repoResponse;
  }

  Future<RepoResponse> createAccount({required String accountName}) async {
    final RepoResponse repoResponse =
        await accountRepository.create(accountName);

    if (repoResponse.success) {
      Account newAccount = ModelFactory.fromJson(
        json: repoResponse.data,
        type: 'account',
      );
      _accounts.add(newAccount);
      account = newAccount;
    }

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> updateAccount({required String accountName}) async {
    final RepoResponse repoResponse = await accountRepository.update(
      id: account!.id,
      name: accountName,
    );

    if (repoResponse.success) {
      for (var i = 0; i < accounts.length; i++) {
        if (accounts[i].id == account!.id) {
          await _accounts[i].update(repoResponse.data);
          await account!.update(repoResponse.data);
          break;
        }
      }
    }

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> deleteAccount({required int accountId}) async {
    final RepoResponse repoResponse = await accountRepository.delete(accountId);

    if (repoResponse.success) {
      _accounts.removeWhere((account) => account.id == accountId);
    }

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> addContributor({
    required String userUsername,
  }) async {
    final RepoResponse repoResponse = await accountRepository.addContributor(
      id: account!.id,
      username: userUsername,
    );

    if (repoResponse.success) {
      await account!.update(repoResponse.data);
    }

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> removeContributor({
    required String userUsername,
  }) async {
    final RepoResponse repoResponse = await accountRepository.removeContributor(
      id: account!.id,
      username: userUsername,
    );

    if (repoResponse.success) {
      await account!.update(repoResponse.data);
    }

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> listItemPermissions({
    required String username,
  }) async {
    final RepoResponse repoResponse = await accountRepository
        .listItemPermissions(accountId: account!.id, username: username);

    return repoResponse;
  }

  Future<RepoResponse> manageItemPermissions({
    required String username,
    required String permission,
  }) async {
    final RepoResponse repoResponse =
        await accountRepository.manageItemPermissions(
      id: account!.id,
      username: username,
      permission: permission,
    );

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> setSalaryBasedSplit({
    required bool isSplit,
  }) async {
    final RepoResponse repoResponse = await accountRepository
        .setSalaryBasedSplit(accountId: account!.id, isSplit: isSplit);

    if (repoResponse.success) {
      account!.update(repoResponse.data);
    }

    notifyListeners();

    return repoResponse;
  }
}

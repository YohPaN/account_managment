import 'package:account_managment/models/account.dart';
import 'package:account_managment/models/contributor.dart';
import 'package:account_managment/models/item.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/repositories/account_repository.dart';
import 'package:flutter/material.dart';

class AccountViewModel extends ChangeNotifier {
  final AccountRepository accountRepository = AccountRepository();

  List<Account>? _accounts;
  List<Account>? get accounts => _accounts;

  List<Account>? _contributorAccounts;
  List<Account>? get contributorAccounts => _contributorAccounts;

  Account? _account;
  Account? get account => _account;

  int? _accountIdToRetrieve;
  set accountIdToRetrieve(int? value) {
    _accountIdToRetrieve = value;
  }

  int? get accountIdToRetrieve => _accountIdToRetrieve;

  Future<RepoResponse> listAccount() async {
    final RepoResponse repoResponse = await accountRepository.list();
    final List<Account> accounts = [];
    final List<Account> contributorAccounts = [];

    if (repoResponse.success && repoResponse.data != null) {
      for (var account in repoResponse.data!["own"]) {
        final List<Item> items = [];

        for (var item in account["items"]) {
          items.add(Item.deserialize(item));
        }

        final List<Contributor> contributors = [];

        for (var contributor in account["contributors"]) {
          contributors.add(
            Contributor.deserialize(contributor),
          );
        }

        final accountToAdd = Account.deserialize(account);
        accountToAdd.items = items;
        accountToAdd.contributor = contributors;
        accounts.add(
          accountToAdd,
        );
      }

      for (var contributorAccount
          in repoResponse.data!["contributor_account"]) {
        final List<Item> items = [];

        for (var item in contributorAccount["items"]) {
          items.add(Item.deserialize(item));
        }

        final List<Contributor> contributors = [];

        for (var contributor in contributorAccount["contributors"]) {
          contributors.add(
            Contributor.deserialize(contributor),
          );
        }

        final accountToAdd = Account.deserialize(contributorAccount);
        accountToAdd.items = items;
        accountToAdd.contributor = contributors;
        contributorAccounts.add(
          accountToAdd,
        );
      }
    }

    _accounts = accounts;
    _contributorAccounts = contributorAccounts;

    return repoResponse;
  }

  Future<RepoResponse> getAccount([int? accountId]) async {
    final RepoResponse repoResponse = await accountRepository.get(accountId);

    if (repoResponse.success && repoResponse.data != null) {
      final List<Item> items = [];
      for (var item in repoResponse.data!["items"]) {
        items.add(Item.deserialize(item));
      }

      final List<Contributor> contributors = [];

      for (var contributor in repoResponse.data!["contributors"]) {
        contributors.add(
          Contributor.deserialize(contributor),
        );
      }

      final accountToAdd = Account.deserialize(repoResponse.data);
      accountToAdd.items = items;
      accountToAdd.contributor = contributors;

      _account = accountToAdd;
    }

    accountIdToRetrieve = null;

    return repoResponse;
  }

  Future<RepoResponse> createAccount(
      String accountName, List<Contributor> contributors) async {
    final List<String> contributorSerializable = [];

    for (var contributor in contributors) {
      contributorSerializable.add(contributor.username);
    }
    final RepoResponse repoResponse =
        await accountRepository.create(accountName, contributorSerializable);

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> updateAccount(
      int accountId, String accountName, List<Contributor> contributors) async {
    final List<String> contributorSerializable = [];

    for (var contributor in contributors) {
      contributorSerializable.add(contributor.username);
    }
    final RepoResponse repoResponse = await accountRepository.update(
        accountId, accountName, contributorSerializable);

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> deleteAccount(int accountId) async {
    final RepoResponse repoResponse = await accountRepository.delete(accountId);

    notifyListeners();

    return repoResponse;
  }

  Future<void> refreshAccount() async {
    await getAccount(account?.id);
    listAccount();
  }

  Future<RepoResponse> createOrUpdateItem(
      String title, String description, String valuation,
      [int? itemId]) async {
    final RepoResponse repoResponse = await accountRepository
        .createOrUpdateItem(title, description, valuation, account!.id, itemId);

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> deleteItem(int itemId) async {
    final RepoResponse repoResponse =
        await accountRepository.deleteItem(itemId, account!.id);
    notifyListeners();

    return repoResponse;
  }
}

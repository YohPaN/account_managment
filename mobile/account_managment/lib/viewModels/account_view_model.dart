import 'package:account_managment/models/account.dart';
import 'package:account_managment/models/category.dart';
import 'package:account_managment/models/contributor.dart';
import 'package:account_managment/models/item.dart';
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

        final List<CategoryApp> categories = [];

        for (var category in account["categories"]) {
          categories.add(
            CategoryApp.deserialize(category),
          );
        }

        final List<CategoryApp> accountCategories = [];

        for (var category in account["account_categories"]) {
          accountCategories.add(
            CategoryApp.deserialize(category),
          );
        }

        final List<Contributor> contributors = [];

        for (var contributor in account["contributors"]) {
          contributors.add(
            Contributor.deserialize(contributor),
          );
        }

        final accountToAdd = Account.deserialize(account);
        accountToAdd.items = items;
        accountToAdd.categories = categories;
        accountToAdd.contributor = contributors;
        accountToAdd.accountCategories = accountCategories;
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
        Item deserializedItem = Item.deserialize(item);
        if (item["category"] != null) {
          CategoryApp categoryItem = CategoryApp.deserialize(item["category"]);
          deserializedItem.category = categoryItem;
        }
        items.add(deserializedItem);
      }

      final List<CategoryApp> categories = [];

      for (var category in repoResponse.data!["categories"]) {
        categories.add(
          CategoryApp.deserialize(category),
        );
      }

      for (var transfertItem in repoResponse.data!["transfert_items"]) {
        items.add(Item.deserialize(transfertItem, true));
      }

      final List<CategoryApp> accountCategories = [];

      for (var category in repoResponse.data!["account_categories"]) {
        accountCategories.add(
          CategoryApp.deserialize(category),
        );
      }

      final List<Contributor> contributors = [];

      for (var contributor in repoResponse.data!["contributors"]) {
        contributors.add(
          Contributor.deserialize(contributor),
        );
      }

      final accountToAdd = Account.deserialize(repoResponse.data);
      accountToAdd.items = items;
      accountToAdd.categories = categories;
      accountToAdd.accountCategories = accountCategories;
      accountToAdd.contributor = contributors;

      account = accountToAdd;
    }

    accountIdToRetrieve = null;

    return repoResponse;
  }

  Future<RepoResponse> createAccount({
    required String accountName,
  }) async {
    final RepoResponse repoResponse =
        await accountRepository.create(accountName);

    if (repoResponse.success) {
      Account newAccount = Account.deserialize(repoResponse.data);
      _accounts.add(newAccount);
      account = newAccount;
    }

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> updateAccount({
    required String accountName,
  }) async {
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

  Future<RepoResponse> deleteAccount(int accountId) async {
    final RepoResponse repoResponse = await accountRepository.delete(accountId);

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

  Future<RepoResponse> createItem({
    required String title,
    required String description,
    required String valuation,
    required int? categoryId,
    required String? username,
    required String? toAccount,
  }) async {
    final RepoResponse repoResponse = await accountRepository.createItem(
      title: title,
      description: description,
      valuation: valuation,
      categoryId: categoryId,
      accountId: account!.id,
      username: username,
      toAccount: toAccount,
    );

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> updateItem({
    required String title,
    required String description,
    required String valuation,
    required int? categoryId,
    required String? username,
    required String? toAccount,
    required int itemId,
  }) async {
    final RepoResponse repoResponse = await accountRepository.updateItem(
        title: title,
        description: description,
        valuation: valuation,
        categoryId: categoryId,
        accountId: account!.id,
        username: username,
        toAccount: toAccount,
        itemId: itemId);

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> deleteItem(int itemId) async {
    final RepoResponse repoResponse =
        await accountRepository.deleteItem(itemId, account!.id);
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

import 'package:account_managment/models/account.dart';
import 'package:account_managment/models/contributor.dart';
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

  Future<void> listAccount() async {
    final Map<String, List<Account>> allAccounts =
        await accountRepository.list();

    _accounts = allAccounts["accounts"];
    _contributorAccounts = allAccounts["contributorAccounts"];

    notifyListeners();
  }

  Future<void> getAccount([int? accountId]) async {
    _account = await accountRepository.get(accountId);
    notifyListeners();
  }

  Future<void> createAccount(
      String accountName, List<Contributor> usersToAdd) async {
    await accountRepository.create(accountName, usersToAdd);
    listAccount();
  }

  Future<void> updateAccount(
      int accountId, String accountName, List<Contributor> contributors) async {
    await accountRepository.update(accountId, accountName, contributors);
    listAccount();
  }

  Future<void> deleteAccount(int accountId) async {
    await accountRepository.delete(accountId);
    listAccount();
  }

  Future<void> refreshAccount() async {
    await getAccount(account?.id);
    listAccount();
  }

  Future<void> createOrUpdateItem(
      String title, String description, String valuation,
      [int? itemId]) async {
    bool? success = await accountRepository.createOrUpdateItem(
        title, description, valuation, account!.id, itemId);

    if (success == true) {
      await getAccount(account!.id);
    }
    await refreshAccount();
  }

  Future<void> deleteItem(int itemId) async {
    await accountRepository.deleteItem(itemId, account!.id);
    await refreshAccount();
  }
}

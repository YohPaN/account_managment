import 'package:account_managment/models/account.dart';
import 'package:account_managment/repositories/account_repository.dart';
import 'package:flutter/material.dart';

class AccountViewModel extends ChangeNotifier {
  final AccountRepository accountRepository;

  List<Account>? _accounts;
  List<Account>? get accounts => _accounts;

  Account? _account;
  Account? get account => _account;

  AccountViewModel({required this.accountRepository});

  Future<void> fetchAccounts() async {
    _accounts = await accountRepository.listAccounts();
    notifyListeners();
  }

  Future<void> fetchAccount([int? accountId]) async {
    _account = await accountRepository.getAccount(accountId);
    notifyListeners();
  }

  Future<void> createAccount(String accountName) async {
    await accountRepository.create(accountName);
    fetchAccounts();
  }

  Future<void> updateAccount(int accountId, String accountName) async {
    await accountRepository.update(accountId, accountName);
    fetchAccounts();
  }

  Future<void> deleteAccount(int accountId) async {
    await accountRepository.delete(accountId);
    fetchAccounts();
  }
}

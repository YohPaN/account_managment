import 'package:account_managment/models/item.dart';
import 'package:account_managment/repositories/item_repository.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:flutter/material.dart';

class ItemViewModel extends ChangeNotifier {
  final ItemRepository itemRepository;
  final AccountViewModel accountViewModel;

  ItemViewModel({required this.itemRepository, required this.accountViewModel});

  List<Item>? _items;
  List<Item>? get items => _items;

  Future<void> create(
      String title, String description, String valuation) async {
    bool? success = await itemRepository.create(title, description, valuation);

    if (success == true) {
      await accountViewModel.fetchAccount(accountViewModel.account!.id);
    }
    await list();
  }

  Future<void> list() async {
    _items = await itemRepository.list(accountViewModel.account!.id);
    notifyListeners();
  }

  Future<void> update(
      int itemId, String title, String description, String valuation) async {
    await itemRepository.update(itemId, title, description, valuation);
    await list();
  }

  Future<void> delete(int itemId) async {
    await itemRepository.delete(itemId);
    await list();
  }
}

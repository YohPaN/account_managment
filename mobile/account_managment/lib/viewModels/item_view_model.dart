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

  Future<void> createItem(
      String title, String description, String valuation) async {
    bool? success = await itemRepository.create(title, description, valuation);

    if (success == true) {
      await accountViewModel.getAccount(accountViewModel.account!.id);
    }
    await accountViewModel.refreshAccount();
  }

  Future<void> updateItem(
      int itemId, String title, String description, String valuation) async {
    await itemRepository.update(itemId, title, description, valuation);
    await accountViewModel.refreshAccount();
  }

  Future<void> deleteItem(int itemId) async {
    await itemRepository.delete(itemId);
    await accountViewModel.refreshAccount();
  }
}

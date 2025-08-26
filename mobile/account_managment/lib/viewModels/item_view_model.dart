import 'package:account_managment/common/model_factory.dart';
import 'package:account_managment/models/account.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/repositories/item_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ItemViewModel extends ChangeNotifier {
  final ItemRepository itemRepository = ItemRepository();

  Future<RepoResponse> createItem({
    required Account account,
    required String title,
    required String description,
    required String valuation,
    required int? categoryId,
    required String? username,
    required String? toAccount,
  }) async {
    final RepoResponse repoResponse = await itemRepository.create(
      title: title,
      description: description,
      valuation: valuation,
      categoryId: categoryId,
      accountId: account.id,
      username: username,
      toAccount: toAccount,
    );

    if (repoResponse.success) {
      account.items.add(ModelFactory.fromJson(
        json: repoResponse.data,
        type: 'item',
      ));
    }

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> updateItem({
    required Account account,
    required String title,
    required String description,
    required String valuation,
    required int? categoryId,
    required String? username,
    required String? toAccount,
    required int itemId,
  }) async {
    final RepoResponse repoResponse = await itemRepository.update(
        title: title,
        description: description,
        valuation: valuation,
        categoryId: categoryId,
        username: username,
        toAccount: toAccount,
        itemId: itemId);

    if (repoResponse.success) {
      for (var i = 0; i < account.items.length; i++) {
        if (account.items[i].id == itemId) {
          await account.items[i].update(repoResponse.data);
          break;
        }
      }
    }

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> deleteItem({
    required Account account,
    required int itemId,
  }) async {
    final RepoResponse repoResponse =
        await itemRepository.delete(itemId);

    if (repoResponse.success) {
      account.items.removeWhere((item) => item.id == itemId);
    }

    notifyListeners();

    return repoResponse;
  }
}

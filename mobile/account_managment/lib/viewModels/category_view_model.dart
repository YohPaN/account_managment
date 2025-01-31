import 'package:account_managment/models/category.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/repositories/category_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository accountCategoryRepository = CategoryRepository();

  final List<CategoryApp> categories = [];

  Future<RepoResponse> createCategory({
    required String title,
    required String icon,
    required String color,
    int? accountId,
  }) async {
    final RepoResponse repoResponse = await accountCategoryRepository.create(
      title: title,
      icon: icon,
      color: color,
      accountId: accountId,
    );

    if (repoResponse.success) {
      categories.add(CategoryApp.deserialize(repoResponse.data));
    }

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> updateCategory({
    required int categoryId,
    required String title,
    required String icon,
    required String color,
  }) async {
    final RepoResponse repoResponse = await accountCategoryRepository.update(
      categoryId: categoryId,
      title: title,
      icon: icon,
      color: color,
    );

    if (repoResponse.success) {
      for (var i = 0; i < categories.length; i++) {
        if (categories[i].id == categoryId) {
          categories[i].update(repoResponse.data);
          break;
        }
      }
    }

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> deleteCategory({
    required int categoryId,
  }) async {
    final RepoResponse repoResponse = await accountCategoryRepository.delete(
      categoryId: categoryId,
    );

    categories.removeWhere((category) => category.id == categoryId);

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> linkCategoryToAccount(
      {required int category, required int account}) async {
    final RepoResponse repoResponse = await accountCategoryRepository.link(
        account: account, category: category);

    return repoResponse;
  }
}

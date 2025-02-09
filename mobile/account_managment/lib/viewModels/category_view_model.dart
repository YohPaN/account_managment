import 'package:account_managment/models/category.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/repositories/category_repository.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository accountCategoryRepository = CategoryRepository();
  final ProfileViewModel profileViewModel;
  final AccountViewModel accountViewModel;

  CategoryViewModel({
    required this.accountViewModel,
    required this.profileViewModel,
  });

  final List<CategoryApp> defaultCategories = [];
  final List<CategoryApp> categories = [];

  Future<RepoResponse> listCategory({
    required int accountId,
    required String categoryType,
  }) async {
    final RepoResponse repoResponse = await accountCategoryRepository.list(
      categoryType: categoryType,
      accountId: accountId,
    );

    if (repoResponse.success) {
      categories.clear();
      repoResponse.data.forEach((category) {
        categories.add(CategoryApp.deserialize(category));
      });
    }

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> createCategory({
    required String title,
    required IconPickerIcon icon,
    required int color,
    int? accountId,
  }) async {
    final RepoResponse repoResponse = await accountCategoryRepository.create(
      title: title,
      icon: icon,
      color: color,
      accountId: accountId,
    );

    if (repoResponse.success) {
      List<CategoryApp> categories;

      if (accountId != null) {
        categories = accountViewModel.account!.categories;
      } else {
        categories = profileViewModel.profile!.categories;
      }

      categories.add(CategoryApp.deserialize(repoResponse.data));
    }

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> updateCategory({
    required int categoryId,
    required String title,
    required IconPickerIcon icon,
    required int color,
    required String categoryType,
  }) async {
    final RepoResponse repoResponse = await accountCategoryRepository.update(
      categoryId: categoryId,
      title: title,
      icon: icon,
      color: color,
    );

    if (repoResponse.success) {
      List<CategoryApp> categories;

      if (categoryType == "account") {
        categories = accountViewModel.account!.categories;
      } else {
        categories = profileViewModel.profile!.categories;
      }

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
    required String categoryType,
  }) async {
    final RepoResponse repoResponse = await accountCategoryRepository.delete(
      categoryId: categoryId,
    );

    if (repoResponse.success) {
      List<CategoryApp> categories;

      if (categoryType == "account") {
        categories = accountViewModel.account!.categories;
      } else {
        categories = profileViewModel.profile!.categories;
      }

      categories.removeWhere((category) => category.id == categoryId);
    }

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> linkCategoryToAccount({
    required int categoryId,
    required int accountId,
    required bool linked,
  }) async {
    final RepoResponse repoResponse;

    if (linked) {
      repoResponse = await accountCategoryRepository.link(
        account: accountId,
        category: categoryId,
      );
      if (repoResponse.success) {
        accountViewModel.account!.accountCategories.add(CategoryApp.deserialize(
          repoResponse.data,
        ));
      }
    } else {
      repoResponse = await accountCategoryRepository.unlink(
        account: accountId,
        category: categoryId,
      );
      if (repoResponse.success) {
        accountViewModel.account!.accountCategories
            .removeWhere((category) => category.id == categoryId);
      }
    }

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> getDefaultCategory() async {
    final RepoResponse repoResponse =
        await accountCategoryRepository.getDefault();

    if (repoResponse.success) {
      for (var category in repoResponse.data) {
        defaultCategories.add(CategoryApp.deserialize(category));
      }
    }

    notifyListeners();

    return repoResponse;
  }
}

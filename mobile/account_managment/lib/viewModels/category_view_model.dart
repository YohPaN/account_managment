import 'package:account_managment/helpers/model_factory.dart';
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
      categories.addAll([
        ...ModelFactory.fromJson(json: repoResponse.data, type: 'category')
      ]);
    }

    notifyListeners();

    return repoResponse;
  }

  Future<RepoResponse> createCategory({
    required String title,
    required IconPickerIcon icon,
    required int color,
    required String contentType,
    int? objectId,
  }) async {
    final RepoResponse repoResponse = await accountCategoryRepository.create(
        title: title,
        icon: icon,
        color: color,
        objectId: objectId,
        contentType: contentType);

    if (repoResponse.success) {
      List<CategoryApp> categories;

      if (objectId != null) {
        categories = accountViewModel.account!.accountCategories;
      } else {
        categories = profileViewModel.profile!.categories;
      }

      categories.add(
          ModelFactory.fromJson(json: repoResponse.data, type: 'category'));
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
        categories = accountViewModel.account!.accountCategories;
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
        categories = accountViewModel.account!.accountCategories;
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
        accountViewModel.account!.categories.add(
            ModelFactory.fromJson(json: repoResponse.data, type: 'category'));
      }
    } else {
      repoResponse = await accountCategoryRepository.unlink(
        account: accountId,
        category: categoryId,
      );
      if (repoResponse.success) {
        accountViewModel.account!.categories
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
        defaultCategories
            .add(ModelFactory.fromJson(json: category, type: 'category'));
      }
    }

    notifyListeners();

    return repoResponse;
  }
}

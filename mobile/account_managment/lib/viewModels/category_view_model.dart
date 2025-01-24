import 'package:account_managment/models/category.dart';
import 'package:account_managment/models/profile.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/models/user.dart';
import 'package:account_managment/repositories/category_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository accountCategoryRepository = CategoryRepository();

  User? _user;
  User? get user => _user;

  Profile? _profile;
  Profile? get profile => _profile;

  final List<CategoryApp> _categories = [];
  List<CategoryApp> get categories => _categories;

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

    return repoResponse;
  }

  Future<RepoResponse> linkCategoryToAccount(
      {required int category, required int account}) async {
    final RepoResponse repoResponse = await accountCategoryRepository.link(
        account: account, category: category);

    return repoResponse;
  }
}

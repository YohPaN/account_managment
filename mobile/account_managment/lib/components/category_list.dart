import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:account_managment/models/category.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/category_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryList extends StatelessWidget {
  final List<CategoryApp> categories;
  bool accountCategory;
  Function? showModal;

  CategoryList({
    super.key,
    required this.categories,
    this.accountCategory = false,
    this.showModal,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    return Consumer<AccountViewModel>(
      builder: (context, accountViewModel, child) {
        if (categories.isNotEmpty) {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (!accountCategory) {
                            return CheckboxListTile(
                              title: Text((locale.default_category_title(
                                              categories[index].title) !=
                                          ""
                                      ? locale.default_category_title(
                                          categories[index].title)
                                      : categories[index].title)
                                  .capitalize()),
                              value: accountViewModel.account!.accountCategories
                                  .any((category) =>
                                      category.id == categories[index].id),
                              onChanged: (bool? value) async {
                                final RepoResponse repoResponse =
                                    await Provider.of<CategoryViewModel>(
                                            context,
                                            listen: false)
                                        .linkCategoryToAccount(
                                  categoryId: categories[index].id,
                                  accountId: accountViewModel.account!.id,
                                  linked: value!,
                                );
                                Provider.of<InternalNotification>(context,
                                        listen: false)
                                    .showMessage(repoResponse.message,
                                        repoResponse.success);
                              },
                            );
                          } else {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(categories[index].title),
                                  IconButton(
                                    onPressed: () {
                                      showModal!('update', categories[index]);
                                    },
                                    icon: const Icon(Icons.mode),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(locale.no_category.capitalize()),
          );
        }
      },
    );
  }
}

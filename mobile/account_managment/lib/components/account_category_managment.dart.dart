import 'package:account_managment/components/category_drawer.dart';
import 'package:account_managment/components/category_list.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/models/category.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/category_view_model.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountCategoryManagment extends StatefulWidget {
  const AccountCategoryManagment({super.key});

  @override
  _AccountCategoryManagmentState createState() =>
      _AccountCategoryManagmentState();
}

class _AccountCategoryManagmentState extends State<AccountCategoryManagment> {
  final List<ExpansionTileController> _controllers = [
    ExpansionTileController(),
    ExpansionTileController(),
    ExpansionTileController(),
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    showModal(String action, [CategoryApp? category]) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        isScrollControlled: true,
        builder: (BuildContext drawerContext) {
          return MultiProvider(
            providers: [
              InheritedProvider<CategoryViewModel>(
                update: (context, value) {
                  return Provider.of<CategoryViewModel>(context, listen: false);
                },
              ),
            ],
            child: CategoryDrawer(
              action: action,
              category: category,
              categoryType: "account",
            ),
          );
        },
      );
    }

    return Consumer<AccountViewModel>(
      builder: (context, accountViewModel, child) {
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            ListTile(
              title: ExpansionTile(
                controller: _controllers[0],
                onExpansionChanged: (isExpanded) {
                  if (isExpanded) {
                    for (var (key, controller) in _controllers.indexed) {
                      if (key != 0) controller.collapse();
                    }
                  }
                },
                title: Text(locale.category_type("default").capitalize()),
                children: [
                  CategoryList(
                    categories: Provider.of<CategoryViewModel>(context)
                        .defaultCategories,
                  ),
                ],
              ),
            ),
            ListTile(
              title: ExpansionTile(
                controller: _controllers[1],
                onExpansionChanged: (isExpanded) {
                  if (isExpanded) {
                    for (var (key, controller) in _controllers.indexed) {
                      if (key != 1) controller.collapse();
                    }
                  }
                },
                title: Text(locale.category_type("profile").capitalize()),
                children: [
                  CategoryList(
                    categories: Provider.of<ProfileViewModel>(context)
                        .profile!
                        .categories,
                  ),
                ],
              ),
            ),
            ListTile(
              title: ExpansionTile(
                controller: _controllers[2],
                onExpansionChanged: (isExpanded) {
                  if (isExpanded) {
                    for (var (key, controller) in _controllers.indexed) {
                      if (key != 2) controller.collapse();
                    }
                  }
                },
                title: Text(locale.category_type("account").capitalize()),
                children: [
                  CategoryList(
                    categories: Provider.of<AccountViewModel>(context)
                        .account!
                        .accountCategories,
                    accountCategory: true,
                    showModal: showModal,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        showModal("create");
                      },
                      child: Text(locale.action("create").capitalize())),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:account_managment/components/item_drawer.dart';
import 'package:account_managment/components/list_item.dart';
import 'package:account_managment/models/category.dart';
import 'package:account_managment/models/item.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/category_view_model.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemCategoryList extends StatelessWidget {
  final CategoryApp? category;

  const ItemCategoryList({
    super.key,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final AccountViewModel accountViewModel =
        Provider.of<AccountViewModel>(context, listen: false);
    final ProfileViewModel profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);

    final List<Item> items = accountViewModel.account!.items
        .where((item) => item.category?.id == category?.id)
        .toList();

    showModal(String action, [Item? item]) async {
      await Provider.of<CategoryViewModel>(context, listen: false).listCategory(
        categoryType: "account_categories",
        accountId: accountViewModel.account!.id,
      );

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        isScrollControlled: true,
        builder: (BuildContext drawerContext) {
          return InheritedProvider<AccountViewModel>(
            update: (context, value) {
              return accountViewModel;
            },
            child: ItemDrawer(
              item: item,
              action: action,
            ),
          );
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 8, bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0.0, 1.0),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: ListItem(
                      item: items[index],
                      accountId: accountViewModel.account!.id,
                      callbackFunc: showModal,
                      canManage: profileViewModel.user!.hasPermission(
                        ressource: items[index],
                        account: accountViewModel.account,
                        permissionsNeeded: ["change_item", "delete_item"],
                        permissions: accountViewModel.account!.permissions,
                        strict: false,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:account_managment/UI/components/items/list_item.dart';
import 'package:account_managment/models/category.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
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

    final List items = accountViewModel.account!.items
        .where((item) => item.category?.id == category?.id)
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: const Color.fromARGB(0, 0, 0, 0),
                    ),
                    child: ListTile(
                      title: ListItem(
                        item: items[index],
                        accountId: accountViewModel.account!.id,
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
                  if (items.length != index + 1)
                    const Divider(
                      color: Colors.black,
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

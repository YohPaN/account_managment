import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PermissionCheckbox extends StatelessWidget {
  final bool permission;
  final String username;
  final String permissionsCodename;

  const PermissionCheckbox({
    super.key,
    required this.permission,
    required this.username,
    required this.permissionsCodename,
  });

  @override
  Widget build(BuildContext context) {
    final AccountViewModel accountViewModel =
        Provider.of<AccountViewModel>(context, listen: false);

    return CheckboxListTile(
      title: Text(permissionsCodename.replaceAll("_", " ").capitalize()),
      value: permission,
      onChanged: (bool? value) async {
        await accountViewModel.manageItemPermissions(
          username: username,
          permission: permissionsCodename,
        );
      },
    );
  }
}

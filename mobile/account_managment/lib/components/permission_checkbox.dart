import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PermissionCheckbox extends StatefulWidget {
  final List<String> permissions;
  final String permissionsCodename;
  final String username;
  final int? accountId;

  const PermissionCheckbox({
    super.key,
    required this.permissions,
    required this.permissionsCodename,
    required this.username,
    this.accountId,
  });

  @override
  _PermissionCheckboxState createState() => _PermissionCheckboxState();
}

class _PermissionCheckboxState extends State<PermissionCheckbox> {
  @override
  Widget build(BuildContext context) {
    final accountViewModel =
        Provider.of<AccountViewModel>(context, listen: false);

    return CheckboxListTile(
      title: Text(widget.permissionsCodename.replaceAll("_", " ").capitalize()),
      value: widget.permissions.contains(widget.permissionsCodename),
      onChanged: (bool? value) async {
        value!
            ? widget.permissions.add(widget.permissionsCodename)
            : widget.permissions.remove(widget.permissionsCodename);

        await accountViewModel.manageItemPermissions(
            accountId: widget.accountId,
            username: widget.username,
            permissions: widget.permissions);
        setState(() {});
      },
    );
  }
}

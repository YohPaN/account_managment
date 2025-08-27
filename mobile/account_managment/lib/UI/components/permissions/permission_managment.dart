import 'package:account_managment/UI/components/permissions/permission_checkbox.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class PermissionManagment extends StatelessWidget {
  final String username;

  const PermissionManagment({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    return FutureBuilder(
      future: Provider.of<AccountViewModel>(context, listen: false)
          .listItemPermissions(username: username),
      builder: (context, snapshot) => snapshot.hasData
          ? ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Text(locale.permissions.capitalize()),
                ListTile(
                  title: PermissionCheckbox(
                    permission:
                        snapshot.data!.data["permissions"].contains("add_item"),
                    permissionsCodename: "add_item",
                    username: username,
                  ),
                ),
                ListTile(
                  title: PermissionCheckbox(
                    permission: snapshot.data!.data["permissions"]
                        .contains("change_item"),
                    permissionsCodename: "change_item",
                    username: username,
                  ),
                ),
                ListTile(
                  title: PermissionCheckbox(
                    permission: snapshot.data!.data["permissions"]
                        .contains("delete_item"),
                    permissionsCodename: "delete_item",
                    username: username,
                  ),
                ),
                ListTile(
                  title: PermissionCheckbox(
                    permission: snapshot.data!.data["permissions"]
                        .contains("transfert_item"),
                    permissionsCodename: "transfert_item",
                    username: username,
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

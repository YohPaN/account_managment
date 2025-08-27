import 'package:account_managment/helpers/navigation_index_helper.dart';
import 'package:account_managment/models/account.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountListItem extends StatelessWidget {
  final Account account;
  final bool canManage;

  const AccountListItem({
    super.key,
    required this.account,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: ElevatedButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsets>(
            const EdgeInsets.only(right: 0, left: 16.0),
          ),
        ),
        onPressed: () async => {
          Provider.of<AccountViewModel>(context, listen: false)
              .accountIdToRetrieve = account.id,
          Provider.of<NavigationIndex>(context, listen: false).changeIndex(0)
        },
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                  AppLocalizations.of(context)!.amount_of_money(account.total)),
            ),
            if (canManage)
              IconButton(
                onPressed: () {
                  Provider.of<AccountViewModel>(context, listen: false)
                      .account = account;
                  Navigator.pushNamed(
                    context,
                    "account_managment",
                    arguments: "update",
                  );
                },
                icon: const Icon(Icons.mode),
              ),
          ],
        ),
      ),
    );
  }
}

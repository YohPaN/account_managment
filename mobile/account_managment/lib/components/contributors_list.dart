import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/components/permission_managment.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContributorsList extends StatefulWidget {
  const ContributorsList({super.key});

  @override
  _ContributorsListState createState() => _ContributorsListState();
}

class _ContributorsListState extends State<ContributorsList> {
  final List<ExpansionTileController> _controllers = [];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    return Consumer<AccountViewModel>(
      builder: (context, accountViewModel, child) {
        _controllers.clear();

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: accountViewModel.account!.contributor.length,
          itemBuilder: (context, index) {
            _controllers.add(ExpansionTileController());

            return ListTile(
              title: ExpansionTile(
                controller: _controllers[index],
                onExpansionChanged: (isExpanded) {
                  if (isExpanded) {
                    for (var (key, controller) in _controllers.indexed) {
                      if (key != index) controller.collapse();
                    }
                  }
                },
                title: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 16,
                      color:
                          accountViewModel.account!.contributor[index].state !=
                                  "APPROVED"
                              ? Colors.orange[500]
                              : Colors.green,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(accountViewModel
                          .account!.contributor[index].username),
                    ),
                  ],
                ),
                children: [
                  PermissionManagment(
                      username: accountViewModel
                          .account!.contributor[index].username),
                  ElevatedButton(
                      onPressed: () async {
                        final RepoResponse repoResponse =
                            await accountViewModel.removeContributor(
                                userUsername: accountViewModel
                                    .account!.contributor[index].username);

                        Provider.of<InternalNotification>(context,
                                listen: false)
                            .showMessage(
                                repoResponse.message, repoResponse.success);
                      },
                      child: Text(locale.action("delete").capitalize()))
                ],
              ),
            );
          },
        );
      },
    );
  }
}

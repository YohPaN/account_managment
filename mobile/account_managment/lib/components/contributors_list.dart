import 'package:account_managment/components/permission_managment.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContributorsList extends StatefulWidget {
  const ContributorsList({super.key});

  @override
  _ContributorsListState createState() => _ContributorsListState();
}

class _ContributorsListState extends State<ContributorsList> {
  final List<ExpansionTileController> _controllers = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountViewModel>(
      builder: (context, accountViewModel, child) => ListView.builder(
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
                    color: accountViewModel.account!.contributor[index].state !=
                            "APPROVED"
                        ? Colors.orange[500]
                        : Colors.green,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                        accountViewModel.account!.contributor[index].username),
                  ),
                ],
              ),
              children: [
                PermissionManagment(
                    username:
                        accountViewModel.account!.contributor[index].username)
              ],
            ),
          );
        },
      ),
    );
  }
}

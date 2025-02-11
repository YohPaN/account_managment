import 'package:account_managment/components/item_category_list.dart';
import 'package:account_managment/components/item_drawer.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/helpers/text_w_or_dark.dart';
import 'package:account_managment/models/item.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/category_view_model.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final List<ExpansionTileController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _controllers.clear();
  }

  @override
  Widget build(BuildContext context) {
    final accountViewModel =
        Provider.of<AccountViewModel>(context, listen: false);
    final ProfileViewModel profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);
    final AppLocalizations locale = AppLocalizations.of(context)!;

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

    Future<RepoResponse?> getAccount() async {
      var accountID =
          accountViewModel.accountIdToRetrieve ?? accountViewModel.account?.id;
      return accountViewModel.getAccount(accountID);
    }

    return Consumer<AccountViewModel>(
      builder: (context, accountViewModel, child) {
        return FutureBuilder(
          future: getAccount(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.success) {
                return Scaffold(
                  body: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                    child: Text(
                                  accountViewModel.account!.name.capitalize(),
                                  style: const TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold),
                                )),
                                Text(
                                  locale.amount_of_money(
                                      accountViewModel.account!.total),
                                  style: TextStyle(
                                      fontSize: 24.0,
                                      color: accountViewModel.account!.total < 0
                                          ? Colors.red[600]
                                          : Colors.green[500]),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                    child: Text(
                                  locale.your_contribution.capitalize(),
                                  style: const TextStyle(),
                                )),
                                Text(
                                  locale.amount_of_money(accountViewModel
                                      .account!.ownContribution!),
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                    child: Text(
                                  locale.needs_to_add.capitalize(),
                                  style: const TextStyle(),
                                )),
                                Text(
                                  locale.amount_of_money(
                                      accountViewModel.account!.needToAdd!),
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color:
                                          accountViewModel.account!.needToAdd! <
                                                  0
                                              ? Colors.red[600]
                                              : Colors.green[500]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async => {
                            await accountViewModel
                                .getAccount(accountViewModel.account?.id)
                          },
                          child: ListView.builder(
                            itemCount: accountViewModel
                                    .account!.accountCategories.length +
                                1,
                            itemBuilder: (context, index) {
                              _controllers.add(ExpansionTileController());

                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 8, bottom: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: index != 0
                                        ? Color(accountViewModel
                                                .account!
                                                .accountCategories[index - 1]
                                                .color ??
                                            0)
                                        : Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(0.0, 1.0),
                                        blurRadius: 4.0,
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: ExpansionTile(
                                      key: ValueKey(index),
                                      controller: _controllers[index],
                                      onExpansionChanged: (isExpanded) {
                                        if (isExpanded) {
                                          for (var (key, controller)
                                              in _controllers.indexed) {
                                            if (key != index) {
                                              controller.collapse();
                                            }
                                          }
                                        }
                                      },
                                      title: index == 0
                                          ? Text(
                                              locale.without_category
                                                  .capitalize(),
                                              style: const TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Row(
                                              children: [
                                                Icon(
                                                  color: textColor(
                                                      accountViewModel
                                                          .account!
                                                          .accountCategories[
                                                              index - 1]
                                                          .color),
                                                  IconData(
                                                      accountViewModel
                                                          .account!
                                                          .accountCategories[
                                                              index - 1]
                                                          .icon!
                                                          .data
                                                          .codePoint,
                                                      fontFamily:
                                                          accountViewModel
                                                              .account!
                                                              .accountCategories[
                                                                  index - 1]
                                                              .icon!
                                                              .data
                                                              .fontFamily),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Text(
                                                    (locale.default_category_title(accountViewModel
                                                                    .account!
                                                                    .accountCategories[
                                                                        index -
                                                                            1]
                                                                    .title) !=
                                                                ""
                                                            ? locale.default_category_title(
                                                                accountViewModel
                                                                    .account!
                                                                    .accountCategories[
                                                                        index -
                                                                            1]
                                                                    .title)
                                                            : accountViewModel
                                                                .account!
                                                                .accountCategories[
                                                                    index - 1]
                                                                .title)
                                                        .capitalize(),
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: textColor(
                                                          accountViewModel
                                                              .account!
                                                              .accountCategories[
                                                                  index - 1]
                                                              .color!),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      children: [
                                        Builder(builder: (context) {
                                          if (index == 0) {
                                            return ItemCategoryList(); //MUST BE NOT CONST
                                          } else {
                                            return ItemCategoryList(
                                              category: accountViewModel
                                                  .account!
                                                  .accountCategories[index - 1],
                                            );
                                          }
                                        })
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  floatingActionButton: Visibility(
                    visible: profileViewModel.user!.hasPermission(
                      account: accountViewModel.account,
                      permissionsNeeded: ["add_item"],
                      permissions: accountViewModel.account!.permissions,
                    ),
                    child: FloatingActionButton(
                      onPressed: () => showModal("create"),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: const Icon(Icons.add),
                    ),
                  ),
                );
              } else {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Text(
                      snapshot.data!.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                );
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }
}

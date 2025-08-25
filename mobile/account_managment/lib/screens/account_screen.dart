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
                        child: Builder(
                          builder: (context) {
                            final categories =
                                accountViewModel.account!.categories;
                            final totalTiles = categories.length +
                                1; // +1 for "without category"

                            if (_controllers.length != totalTiles) {
                              _controllers.clear();
                              _controllers.addAll(
                                List.generate(totalTiles,
                                    (_) => ExpansionTileController()),
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: () async {
                                await accountViewModel
                                    .getAccount(accountViewModel.account?.id);
                              },
                              child: ListView.builder(
                                itemCount: totalTiles,
                                itemBuilder: (context, index) {
                                  final isWithoutCategory = index == 0;
                                  final category = !isWithoutCategory
                                      ? categories[index - 1]
                                      : null;
                                  final bgColor = !isWithoutCategory
                                      ? Color(category!.color ?? 0)
                                      : Colors.white;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        color: bgColor,
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
                                          collapsedIconColor: !isWithoutCategory
                                              ? textColor(category!.color ?? 0)
                                              : Colors.black,
                                          iconColor: !isWithoutCategory
                                              ? textColor(category!.color ?? 0)
                                              : Colors.black,
                                          onExpansionChanged: (isExpanded) {
                                            if (isExpanded) {
                                              for (var (i, controller)
                                                  in _controllers.indexed) {
                                                if (i != index) {
                                                  controller.collapse();
                                                }
                                              }
                                            }
                                          },
                                          title: isWithoutCategory
                                              ? Text(
                                                  locale.without_category
                                                      .capitalize(),
                                                  style: const TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : Row(
                                                  children: [
                                                    Icon(
                                                      color: textColor(
                                                          category!.color),
                                                      IconData(
                                                        category.icon!.data
                                                            .codePoint,
                                                        fontFamily: category
                                                            .icon!
                                                            .data
                                                            .fontFamily,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      (locale.default_category_title(
                                                                      category
                                                                          .title) !=
                                                                  ""
                                                              ? locale
                                                                  .default_category_title(
                                                                      category
                                                                          .title)
                                                              : category.title)
                                                          .capitalize(),
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: textColor(
                                                            category.color!),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      "${accountViewModel.account!.items.where((item) => item.category?.id == category.id).fold<double>(0, (sum, item) => sum + (item.transfertItem ? -1 * item.valuation : item.valuation)).toStringAsFixed(2)}€",
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: textColor(
                                                            category.color!),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                          children: [
                                            isWithoutCategory
                                                // ignore: prefer_const_constructors
                                                ? ItemCategoryList() //MUST BE NOT CONST
                                                : ItemCategoryList(
                                                    category: category),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
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

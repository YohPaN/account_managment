import 'package:account_managment/components/category_drawer.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/models/category.dart';
import 'package:account_managment/viewModels/account_user_view_model.dart';
import 'package:account_managment/viewModels/auth_view_model.dart';
import 'package:account_managment/viewModels/category_view_model.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AccountUserViewModel accountUserViewModel =
        Provider.of<AccountUserViewModel>(context);
    final CategoryViewModel categoryViewModel =
        Provider.of<CategoryViewModel>(context);
    final AppLocalizations locale = AppLocalizations.of(context)!;

    showModal(String action, [CategoryApp? category]) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        isScrollControlled: true,
        builder: (BuildContext drawerContext) {
          return MultiProvider(
            providers: [
              InheritedProvider<CategoryViewModel>(
                update: (context, value) {
                  return categoryViewModel;
                },
              ),
            ],
            child: CategoryDrawer(
              action: action,
              category: category,
              categoryType: "user",
            ),
          );
        },
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder(
              future: accountUserViewModel.listAccountUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.success) {
                    return Expanded(
                        child: ListView.builder(
                      itemCount: snapshot.data!.data?.length ?? 0,
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
                              title: Column(
                                children: [
                                  Text(
                                    "${locale.account("")}: ${accountUserViewModel.accountUsers[index].accountName}"
                                        .capitalize(),
                                  ),
                                  Text(
                                    "${locale.admin}: ${accountUserViewModel.accountUsers[index].adminUsername}"
                                        .capitalize(),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async =>
                                            await accountUserViewModel
                                                .partialUpdateAccountUser(
                                                    accountUserId:
                                                        accountUserViewModel
                                                            .accountUsers[index]
                                                            .id,
                                                    state: "DISAPPROVED"),
                                        child: const Icon(
                                          Icons.close,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async =>
                                            await accountUserViewModel
                                                .partialUpdateAccountUser(
                                                    accountUserId:
                                                        accountUserViewModel
                                                            .accountUsers[index]
                                                            .id,
                                                    state: "APPROVED"),
                                        child: const Icon(
                                          Icons.check,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ));
                  }
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            Consumer<ProfileViewModel>(
              builder: (context, profileViewModel, child) {
                return Expanded(
                  child: Column(
                    children: [
                      Text(locale.categories.capitalize()),
                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              profileViewModel.profile!.categories.length,
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
                                  title: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(
                                            IconData(
                                                profileViewModel
                                                    .profile!
                                                    .categories[index]
                                                    .icon!
                                                    .data
                                                    .codePoint,
                                                fontFamily: profileViewModel
                                                    .profile!
                                                    .categories[index]
                                                    .icon!
                                                    .data
                                                    .fontFamily),
                                          ),
                                          const SizedBox(width: 12), // Gap
                                          Flexible(
                                            child: Text(
                                              profileViewModel.profile!
                                                  .categories[index].title
                                                  .capitalize(),
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                          const SizedBox(width: 12), // Gap
                                          Icon(
                                            Icons.circle,
                                            size: 16,
                                            color: Color(profileViewModel
                                                    .profile!
                                                    .categories[index]
                                                    .color ??
                                                0),
                                          ),
                                          const SizedBox(width: 12), // Gap
                                          ElevatedButton(
                                            onPressed: () => showModal(
                                              "update",
                                              profileViewModel
                                                  .profile!.categories[index],
                                            ),
                                            child: const Icon(
                                              Icons.mode,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () => showModal("create"),
                            child: Text(locale.create_category(1).capitalize()),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
            ElevatedButton(
              child: Text(locale.logout.capitalize()),
              onPressed: () {
                Provider.of<ProfileViewModel>(context, listen: false).clear();
                Provider.of<AuthViewModel>(context, listen: false).logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/",
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

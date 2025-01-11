import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/viewModels/account_user_view_model.dart';
import 'package:account_managment/viewModels/auth_view_model.dart';
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
    final AppLocalizations locale = AppLocalizations.of(context)!;

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

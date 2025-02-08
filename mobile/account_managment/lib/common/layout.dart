import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/common/navigation_index.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/screens/account_list_screen.dart';
import 'package:account_managment/screens/account_screen.dart';
import 'package:account_managment/screens/profile_screen.dart';
import 'package:account_managment/screens/setting_screen.dart';
import 'package:account_managment/viewModels/account_user_view_model.dart';
import 'package:account_managment/viewModels/category_view_model.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  _LayoutState createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final List<Widget> allDestinations = [
    const AccountScreen(),
    const AccountListScreen(),
    ProfileScreen(action: "update"),
    const SettingScreen(),
  ];

  ToastificationItem? toastPendingAccountRequest;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Provider.of<AccountUserViewModel>(context, listen: false)
        .countAccountUser();

    setState(() {});

    if (Provider.of<AccountUserViewModel>(context, listen: false)
            .accountUsersCount >
        0) {
      toastPendingAccountRequest =
          Provider.of<InternalNotification>(context, listen: false)
              .showPendingAccountRequest(
                  Provider.of<AccountUserViewModel>(context, listen: false)
                      .accountUsersCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    var currentPageIndex = Provider.of<NavigationIndex>(context).getIndex;
    final ProfileViewModel profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);
    final CategoryViewModel categoryViewModel =
        Provider.of<CategoryViewModel>(context, listen: false);
    final AppLocalizations locale = AppLocalizations.of(context)!;

    if (profileViewModel.user == null) profileViewModel.getProfile();

    if (categoryViewModel.defaultCategories.isEmpty) {
      categoryViewModel.getDefaultCategory();
    }

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(),
      body: allDestinations[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: locale.home.capitalize(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.euro),
            label: locale.account("many").capitalize(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_circle),
            label: locale.profile.capitalize(),
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible:
                  Provider.of<AccountUserViewModel>(context).accountUsersCount >
                      0,
              label: Text(
                Provider.of<AccountUserViewModel>(context)
                    .accountUsersCount
                    .toString(),
              ),
              child: const Icon(Icons.settings),
            ),
            label: locale.settings.capitalize(),
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            if (toastPendingAccountRequest != null) {
              toastification.dismiss(toastPendingAccountRequest!);
            }
            Provider.of<NavigationIndex>(context, listen: false)
                .changeIndex(index);
          });
        },
      ),
    ));
  }
}

import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/common/navigation_index.dart';
import 'package:account_managment/screens/account_managment_screen.dart';
import 'package:account_managment/screens/account_screen.dart';
import 'package:account_managment/screens/profile_screen.dart';
import 'package:account_managment/screens/setting_screen.dart';
import 'package:account_managment/viewModels/account_user_view_model.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  _LayoutState createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final List<Widget> allDestinations = [
    const AccountScreen(),
    const AccountManagmentScreen(),
    ProfileScreen(action: "update"),
    const SettingScreen(),
  ];

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

    if (profileViewModel.user == null) profileViewModel.getProfile();

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AccountViewModel(),
          ),
        ],
        child: allDestinations[currentPageIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.euro),
            label: 'Accounts',
          ),
          const NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
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
            label: 'Settings',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            Provider.of<NavigationIndex>(context, listen: false)
                .changeIndex(index);
          });
        },
      ),
    ));
  }
}

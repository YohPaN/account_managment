import 'package:account_managment/common/navigation_index.dart';
import 'package:account_managment/screens/account_managment_screen.dart';
import 'package:account_managment/screens/account_screen.dart';
import 'package:account_managment/screens/profile_screen.dart';
import 'package:account_managment/screens/setting_screen.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
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
  Widget build(BuildContext context) {
    var currentPageIndex = Provider.of<NavigationIndex>(context).getIndex;

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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.euro),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
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

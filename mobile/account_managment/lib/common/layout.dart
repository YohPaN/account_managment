import 'package:flutter/material.dart';

class Layout extends StatelessWidget {
  final Widget child;
  final String title;

  const Layout({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.euro),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigator.pushNamed(context, '/');
              break;
            case 1:
              Navigator.pushNamed(
                context,
                '/account_managment',
              );
              break;
            case 2:
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: {'update': true},
              );
              break;
            case 3:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}

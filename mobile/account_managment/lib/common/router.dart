import 'package:account_managment/common/layout.dart';
import 'package:account_managment/screens/login_screen.dart';
import 'package:account_managment/screens/profile_screen.dart';
import 'package:flutter/material.dart';

router(BuildContext context) {
  return {
    '/': (context) => const LoginScreen(),
    '/home': (context) => const Layout(),
    '/register': (context) => ProfileScreen(action: "create"),
  };
}

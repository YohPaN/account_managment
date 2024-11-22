import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/common/navigation_index.dart';
import 'package:account_managment/common/router.dart';
import 'package:account_managment/viewModels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NavigationIndex()),
        ChangeNotifierProvider(create: (context) => InternalNotification()),
        ChangeNotifierProvider<AuthViewModel>(
            create: (context) => AuthViewModel()),
      ],
      child: ToastificationWrapper(
        child: MaterialApp(
          title: 'Account managment',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: router(context),
        ),
      ),
    );
  }
}

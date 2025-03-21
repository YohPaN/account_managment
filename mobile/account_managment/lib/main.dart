import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/common/navigation_index.dart';
import 'package:account_managment/common/router.dart';
import 'package:account_managment/helpers/push_notification.dart';
import 'package:account_managment/viewModels/account_user_view_model.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/auth_view_model.dart';
import 'package:account_managment/viewModels/category_view_model.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NavigationIndex()),
        ChangeNotifierProvider(create: (context) => InternalNotification()),
        ChangeNotifierProvider(create: (context) => AccountUserViewModel()),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(),
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (context) => ProfileViewModel(),
        ),
        ChangeNotifierProvider<AccountViewModel>(
          create: (context) => AccountViewModel(),
        ),
        ChangeNotifierProvider<CategoryViewModel>(
          create: (context) => CategoryViewModel(
            profileViewModel:
                Provider.of<ProfileViewModel>(context, listen: false),
            accountViewModel:
                Provider.of<AccountViewModel>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<PushNotification>(
          create: (context) => PushNotification(
            profileViewModel:
                Provider.of<ProfileViewModel>(context, listen: false),
            navigationIndex:
                Provider.of<NavigationIndex>(context, listen: false),
          ),
        )
      ],
      child: ToastificationWrapper(
        child: MaterialApp(
          title: 'Account managment',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: router(context),
          navigatorKey: navigatorKey,
        ),
      ),
    );
  }
}

import 'package:account_managment/common/router.dart';
import 'package:account_managment/repositories/account_repository.dart';
import 'package:account_managment/repositories/auth_repository.dart';
import 'package:account_managment/repositories/item_repository.dart';
import 'package:account_managment/repositories/profile_repository.dart';
import 'package:account_managment/screens/login_screen.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/auth_view_model.dart';
import 'package:account_managment/viewModels/item_view_model.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core Repository Providers
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        // Auth ViewModel
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            authRepository: Provider.of<AuthRepository>(context, listen: false),
          ),
        ),
        ProxyProvider<AuthViewModel, ProfileRepository>(
            update: (context, authViewModel, _) =>
                ProfileRepository(authViewModel: authViewModel)),

        // Account Repository depends on AuthViewModel
        ProxyProvider<AuthViewModel, AccountRepository>(
          update: (context, authViewModel, _) =>
              AccountRepository(authViewModel: authViewModel),
        ),

        // Account ViewModel depends on AccountRepository
        ChangeNotifierProvider<AccountViewModel>(
          create: (context) => AccountViewModel(
            accountRepository:
                Provider.of<AccountRepository>(context, listen: false),
          ),
        ),

        // Item Repository depends on AuthViewModel and AccountViewModel
        ProxyProvider2<AuthViewModel, AccountViewModel, ItemRepository>(
          update: (context, authViewModel, accountViewModel, _) =>
              ItemRepository(
            authViewModel: authViewModel,
            accountViewModel: accountViewModel,
          ),
        ),

        // Item ViewModel depends on ItemRepository
        ChangeNotifierProvider<ItemViewModel>(
          create: (context) => ItemViewModel(
            itemRepository: Provider.of<ItemRepository>(context, listen: false),
            accountViewModel:
                Provider.of<AccountViewModel>(context, listen: false),
          ),
        ),

        // Profile ViewModel
        ChangeNotifierProvider<ProfileViewModel>(
          create: (context) => ProfileViewModel(
            profileRepository:
                Provider.of<ProfileRepository>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Account managment',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: router(context),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("My app"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20)),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              child: const Text('go to login'),
            ),
          ],
        ),
      ),
    );
  }
}

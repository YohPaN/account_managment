import 'package:account_managment/viewModels/account_user_view_model.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/category_view_model.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    fetchDataAndNavigate();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> updateProgress(double value) async {
    await controller.animateTo(value,
        duration: const Duration(milliseconds: 500));
  }

  void fetchDataAndNavigate() async {
    final profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);

    try {
      await profileViewModel.getProfile();
      await updateProgress(0.2);

      await Provider.of<CategoryViewModel>(context, listen: false)
          .getDefaultCategory();
      await updateProgress(0.4);

      await Provider.of<AccountViewModel>(context, listen: false).getAccount();
      await updateProgress(0.6);

      await Provider.of<AccountViewModel>(context, listen: false)
          .listAccount(user: profileViewModel.user!.username);
      await updateProgress(0.8);

      await Provider.of<AccountUserViewModel>(context, listen: false)
          .countAccountUser();
      await updateProgress(1.0);

      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Loading data...'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: controller.value,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

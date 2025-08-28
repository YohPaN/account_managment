import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileFormFutureBuilder extends StatelessWidget {
  final Widget child;
  const ProfileFormFutureBuilder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          Provider.of<ProfileViewModel>(context, listen: false).getProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.success) {
            return child;
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(36.0),
                child: Text(
                  snapshot.data!.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ),
            );
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

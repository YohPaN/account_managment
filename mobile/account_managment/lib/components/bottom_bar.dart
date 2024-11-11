import 'package:account_managment/create_profile.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.blue,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Row(
          children: <Widget>[
            Expanded(
                child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => print('test'),
            )),
            Expanded(
                child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => print('test'),
            )),
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CreateProfile(
                    createOrUpdate: 'update',
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

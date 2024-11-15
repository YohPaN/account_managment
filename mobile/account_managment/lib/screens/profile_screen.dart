import 'package:account_managment/models/profile.dart';
import 'package:account_managment/models/user.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:account_managment/helpers/validation_helper.dart';

class ProfileScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final _formKey = GlobalKey<FormState>();

    User? user = profileViewModel.user;
    Profile? profile = profileViewModel.profile;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final action =
        (args != null && args['update'] == true) ? 'update' : 'create';

    if ((profile == null || user == null) && action == "update") {
      profileViewModel.get();
      user = profileViewModel.user;
      profile = profileViewModel.profile;
    }

    if (profile != null && user != null) {
      usernameController.text = user.username;
      firstNameController.text = profile.firstName;
      lastNameController.text = profile.lastName;
      emailController.text = user.email;
      salaryController.text = profile.salary.toString();
      passwordController.text = user.password;
    }

    createOrUpdate() async {
      late Function(String, String, String, String, String, String)
          actionFunction;

      if (action == "create") {
        actionFunction = profileViewModel.create;
      } else if (action == "update") {
        actionFunction = profileViewModel.update;
      }

      await actionFunction(
        usernameController.text,
        firstNameController.text,
        lastNameController.text,
        emailController.text,
        salaryController.text,
        passwordController.text,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("$action your account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: firstNameController,
                maxLength: 50,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: (value) => ValidationHelper.validateInput(
                    value, ["notEmpty", "notNull", "validTextOnly"]),
              ),
              TextFormField(
                controller: lastNameController,
                maxLength: 50,
                decoration: const InputDecoration(labelText: 'Last name'),
                validator: (value) => ValidationHelper.validateInput(
                    value, ["notEmpty", "notNull", "validTextOnly"]),
              ),
              TextFormField(
                controller: usernameController,
                maxLength: 50,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => ValidationHelper.validateInput(
                    value, ["notEmpty", "notNull", "validTextOrDigitOnly"]),
              ),
              TextFormField(
                  controller: emailController,
                  maxLength: 100,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => ValidationHelper.validateInput(
                      value, ["notEmpty", "notNull", "validEmail"])),
              TextFormField(
                controller: salaryController,
                maxLength: 15,
                decoration: const InputDecoration(labelText: 'Salary'),
                validator: (value) => ValidationHelper.validateInput(
                    value, ["notEmpty", "notNull", "validDouble"]),
              ),
              //TODO: add max length when password will be manage
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                // validator: (value) => {}
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  child: const Text("Back"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await createOrUpdate();
                      if (profileViewModel.profile != null) {
                        Navigator.pushReplacementNamed(context, '/');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Can't $action profile")),
                        );
                      }
                    }
                  },
                  child: Text("$action my account"),
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }
}

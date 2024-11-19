import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/helpers/validation_helper.dart';
import 'package:account_managment/models/account.dart';
import 'package:account_managment/models/contributor.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountDrawer extends StatefulWidget {
  final Account? account;
  final String action;
  final Function closeCallback;
  const AccountDrawer(
      {super.key,
      this.account,
      required this.action,
      required this.closeCallback});

  @override
  _AccountDrawerState createState() => _AccountDrawerState();
}

class _AccountDrawerState extends State<AccountDrawer> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController userToAddController = TextEditingController();

  final List<Contributor> _usersToAdd = [];

  @override
  void initState() {
    super.initState();
    if (widget.action == "update") {
      for (var contributor in widget.account!.contributor) {
        _usersToAdd.add(contributor);
      }
    }
  }

  _addUser() {
    setState(() {
      _usersToAdd.add(Contributor(username: userToAddController.text));
      userToAddController.text = "";
    });
  }

  _removeUser(int index) {
    setState(() {
      _usersToAdd.removeAt(index);
      userToAddController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountViewModel = Provider.of<AccountViewModel>(context);
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    if (profileViewModel.user == null) {
      profileViewModel.getProfile();
    }

    createOrUpdate() async {
      if (widget.action == "create") {
        await accountViewModel.createAccount(nameController.text, _usersToAdd);
      } else if (widget.action == "update") {
        await accountViewModel.updateAccount(
            widget.account!.id, nameController.text, _usersToAdd);
      }
    }

    if (widget.action == "update" && widget.account != null) {
      nameController.text = widget.account!.name;
    }

    return Padding(
            padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 4.0,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Title'),
                maxLength: 30,
                validator: (value) => ValidationHelper.validateInput(
                    value, ["notEmpty", "notNull", "validTextOrDigitOnly"]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: userToAddController,
                decoration: InputDecoration(
                  labelText: 'User to add',
                  suffixIcon: IconButton(
                    onPressed: () => {
                      if (profileViewModel.user!.username !=
                          userToAddController.text)
                        {
                          _addUser(),
                        }
                      else
                        {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Error"),
                                content: const Text(
                                    "You can't add yourself to your account"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              );
                            },
                          ),
                        }
                    },
                    icon: const Icon(Icons.add),
                  ),
                ),
                maxLength: 15,
              ),
              const SizedBox(height: 16),
              if (_usersToAdd.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 300,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _usersToAdd.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 8, bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(0.0, 1.0),
                                blurRadius: 4.0,
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 16,
                                    color: _usersToAdd[index].state != "APPROVED"
                                        ? Colors.orange[500]
                                        : Colors.green,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(_usersToAdd[index].username),
                                  ),
                                  Expanded(
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            onPressed: () => _removeUser(index),
                                            icon: const Icon(Icons.remove),
                                          ),
                                        ]),
                                  ),
                                ]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await createOrUpdate();
                        widget.closeCallback();
                      }
                    },
                    child: Text('${widget.action} account'.capitalize()),
                  ),
                  if (widget.action == "update" && !widget.account!.isMain)
                    ElevatedButton(
                      onPressed: () async {
                        await accountViewModel.deleteAccount(widget.account!.id);
                        widget.closeCallback();
                      },
                      child: const Text('Delete account'),
                    )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

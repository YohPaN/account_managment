import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/components/permission_checkbox.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/helpers/validation_helper.dart';
import 'package:account_managment/models/account.dart';
import 'package:account_managment/models/contributor.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountDrawer extends StatefulWidget {
  final Account? account;
  final String action;
  const AccountDrawer({
    super.key,
    this.account,
    required this.action,
  });

  @override
  _AccountDrawerState createState() => _AccountDrawerState();
}

class _AccountDrawerState extends State<AccountDrawer> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController userToAddController = TextEditingController();

  final List<Contributor> _usersToAdd = [];
  final List<ExpansionTileController> _controllers = [];
  bool isSplit = false;

  @override
  void initState() {
    super.initState();
    if (widget.action == "update") {
      for (var contributor in widget.account!.contributor) {
        _usersToAdd.add(contributor);
      }

      for (var _ in _usersToAdd) {
        _controllers.add(ExpansionTileController());
      }

      isSplit = widget.account!.salaryBasedSplit ?? false;
    }
  }

  _addUser() {
    setState(() {
      _usersToAdd.add(Contributor(username: userToAddController.text));
      _controllers.add(ExpansionTileController());

      userToAddController.text = "";
    });
  }

  _removeUser(int index) {
    setState(() {
      _usersToAdd.removeAt(index);
      _controllers.removeAt(index);
      userToAddController.text = "";
    });
    for (var controller in _controllers) {
      controller.collapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountViewModel = Provider.of<AccountViewModel>(context);
    final profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);
    final AppLocalizations locale = AppLocalizations.of(context)!;

    // createOrUpdate() async {
    //   RepoResponse response;
    //   if (widget.action == "create") {
    //     response = await accountViewModel.createAccount(
    //         nameController.text, _usersToAdd);
    //   } else {
    //     response = await accountViewModel.updateAccount(
    //         widget.account!.id, nameController.text, _usersToAdd);
    //   }
    //   return response;
    // }

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
                textCapitalization: TextCapitalization.sentences,
                controller: nameController,
                decoration:
                    InputDecoration(labelText: locale.title.capitalize()),
                maxLength: 30,
                validator: (value) => ValidationHelper.validateInput(
                    value, ["notEmpty", "notNull", "validTextOrDigitOnly"]),
              ),
              const SizedBox(height: 16),
              if (widget.action == "update")
                CheckboxListTile(
                  title: Text(locale.salary_based_split.capitalize()),
                  value: isSplit,
                  onChanged: (bool? value) async {
                    // final RepoResponse repoResponse =
                    //     await accountViewModel.setSalaryBasedSplit(
                    //   accountId: widget.account!.id,
                    //   isSplit: value!,
                    // );
                    //   if (repoResponse.success) {
                    //     setState(() {
                    //       isSplit = value;
                    //     });
                    //   }
                    //   Provider.of<InternalNotification>(context, listen: false)
                    //       .showMessage(
                    //           repoResponse.message, repoResponse.success);
                  },
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: userToAddController,
                decoration: InputDecoration(
                  labelText: locale.add_users.capitalize(),
                  suffixIcon: IconButton(
                    onPressed: () => {
                      if (userToAddController.text != "")
                        {
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
                                    title: Text(locale.error.capitalize()),
                                    content: Text(locale.add_self_account_error
                                        .capitalize()),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(locale.ok.capitalize()),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            }
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
                            title: ExpansionTile(
                              controller: _controllers[index],
                              onExpansionChanged: (isExpanded) {
                                if (isExpanded) {
                                  for (var (key, controller)
                                      in _controllers.indexed) {
                                    if (key != index) controller.collapse();
                                  }
                                }
                              },
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 16,
                                    color:
                                        _usersToAdd[index].state != "APPROVED"
                                            ? Colors.orange[500]
                                            : Colors.green,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(_usersToAdd[index].username),
                                  ),
                                ],
                              ),
                              children: [
                                if (widget.action == "create")
                                  Text(
                                    locale
                                        .create_account_before_manage_permissions
                                        .capitalize(),
                                  )
                                else if (widget.action == "update" &&
                                    !widget.account!.contributor.any(
                                        (contributor) =>
                                            contributor.username ==
                                            _usersToAdd[index].username))
                                  Text(
                                    locale.add_user_before_manage_permissions
                                        .capitalize(),
                                  )
                                else if (widget.account!.username ==
                                    profileViewModel.user!.username)
                                  FutureBuilder(
                                    future:
                                        accountViewModel.listItemPermissions(
                                      accountId: widget.account!.id,
                                      username: _usersToAdd[index].username,
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data!.success) {
                                          final List<String> permissions = [
                                            ...snapshot
                                                .data!.data?["permissions"],
                                          ];

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(locale.permissions
                                                  .capitalize()),
                                              PermissionCheckbox(
                                                  permissions: permissions,
                                                  permissionsCodename:
                                                      "add_item",
                                                  accountId: widget.account!.id,
                                                  username: _usersToAdd[index]
                                                      .username),
                                              PermissionCheckbox(
                                                  permissions: permissions,
                                                  permissionsCodename:
                                                      "change_item",
                                                  accountId: widget.account!.id,
                                                  username: _usersToAdd[index]
                                                      .username),
                                              PermissionCheckbox(
                                                  permissions: permissions,
                                                  permissionsCodename:
                                                      "delete_item",
                                                  accountId: widget.account!.id,
                                                  username: _usersToAdd[index]
                                                      .username),
                                              PermissionCheckbox(
                                                  permissions: permissions,
                                                  permissionsCodename:
                                                      "transfert_item",
                                                  accountId: widget.account!.id,
                                                  username: _usersToAdd[index]
                                                      .username),
                                            ],
                                          );
                                        } else {
                                          return Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(36.0),
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
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    },
                                  ),
                                ElevatedButton(
                                  onPressed: () => _removeUser(index),
                                  child: Text(
                                      locale.action("delete").capitalize()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.action == "create" ||
                      profileViewModel.user!.hasPermission(
                        account: widget.account,
                        permissionsNeeded: ["change_account"],
                        permissions: widget.account!.permissions,
                      ))
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // RepoResponse repoResponse = await createOrUpdate();
                          // Provider.of<InternalNotification>(context,
                          //         listen: false)
                          //     .showMessage(
                          //         repoResponse.message, repoResponse.success);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(locale.action(widget.action).capitalize()),
                    ),
                  if (widget.action == "update" &&
                      profileViewModel.user!.hasPermission(
                        account: widget.account,
                        permissionsNeeded: ["delete_account"],
                        permissions: widget.account!.permissions,
                      ) &&
                      !widget.account!.isMain)
                    ElevatedButton(
                      onPressed: () async {
                        final RepoResponse repoResponse = await accountViewModel
                            .deleteAccount(widget.account!.id);

                        Provider.of<InternalNotification>(context,
                                listen: false)
                            .showMessage(
                                repoResponse.message, repoResponse.success);
                        Navigator.pop(context);
                      },
                      child: Text(locale.action('delete').capitalize()),
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

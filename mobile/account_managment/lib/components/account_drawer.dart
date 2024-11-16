import 'package:account_managment/helpers/validation_helper.dart';
import 'package:account_managment/models/account.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final accountViewModel = Provider.of<AccountViewModel>(context);

    createOrUpdate() async {
      if (widget.action == "create") {
        await accountViewModel.createAccount(
          nameController.text,
        );
      } else if (widget.action == "update") {
        await accountViewModel.updateAccount(
          widget.account!.id,
          nameController.text,
        );
      }
    }

    if (widget.action == "update" && widget.account != null) {
      nameController.text = widget.account!.name;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                  child: Text('${widget.action} account'),
                ),
                if (widget.action == "update")
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
    );
  }
}

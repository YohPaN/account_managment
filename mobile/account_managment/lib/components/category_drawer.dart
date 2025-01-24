import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/viewModels/category_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:account_managment/helpers/validation_helper.dart';
import 'package:provider/provider.dart';

class CategoryDrawer extends StatefulWidget {
  @override
  const CategoryDrawer({super.key});

  @override
  _CategoryDrawerState createState() => _CategoryDrawerState();
}

class _CategoryDrawerState extends State<CategoryDrawer> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController iconController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final CategoryViewModel categoryViewModel =
        Provider.of<CategoryViewModel>(context);

    final AppLocalizations locale = AppLocalizations.of(context)!;

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
                controller: titleController,
                decoration:
                    InputDecoration(labelText: locale.title.capitalize()),
                maxLength: 30,
                validator: (value) => ValidationHelper.validateInput(
                    value, ["notEmpty", "notNull", "validTextOrDigitOnly"]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                controller: iconController,
                decoration:
                    InputDecoration(labelText: locale.icon.capitalize()),
                maxLength: 30,
                validator: (value) => ValidationHelper.validateInput(
                    value, ["notEmpty", "notNull", "validTextOrDigitOnly"]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                controller: colorController,
                decoration:
                    InputDecoration(labelText: locale.color.capitalize()),
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
                        RepoResponse repoResponse =
                            await categoryViewModel.createCategory(
                          title: titleController.text,
                          icon: iconController.text,
                          color: colorController.text,
                        );
                        Provider.of<InternalNotification>(context,
                                listen: false)
                            .showMessage(
                                repoResponse.message, repoResponse.success);
                        // Navigator.pop(context);
                      }
                    },
                    child: Text(locale.create.capitalize()),
                  ),

                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final RepoResponse repoResponse = await accountViewModel
                  //         .deleteAccount(widget.account!.id);

                  //     Provider.of<InternalNotification>(context,
                  //             listen: false)
                  //         .showMessage(
                  //             repoResponse.message, repoResponse.success);
                  //     Navigator.pop(context);
                  //   },
                  //   child: Text(locale.action('delete').capitalize()),
                  // )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

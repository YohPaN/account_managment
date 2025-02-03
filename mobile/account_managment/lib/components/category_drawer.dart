import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/models/category.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/category_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:account_managment/helpers/validation_helper.dart';
import 'package:provider/provider.dart';

class CategoryDrawer extends StatefulWidget {
  final String action;
  final String categoryType;
  final CategoryApp? category;

  @override
  const CategoryDrawer({
    super.key,
    required this.action,
    required this.categoryType,
    required this.category,
  });

  @override
  _CategoryDrawerState createState() => _CategoryDrawerState();
}

class _CategoryDrawerState extends State<CategoryDrawer> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController iconController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.action == "update") {
      titleController.text = widget.category!.title;
      iconController.text = widget.category!.icon.toString();
      colorController.text = widget.category!.color.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final CategoryViewModel categoryViewModel =
        Provider.of<CategoryViewModel>(context);

    final AppLocalizations locale = AppLocalizations.of(context)!;

    Future<RepoResponse> submit({
      required String title,
      required String icon,
      required String color,
    }) async {
      if (widget.action == "create") {
        return await categoryViewModel.createCategory(
          title: title,
          icon: icon,
          color: color,
          accountId: widget.categoryType == "account"
              ? Provider.of<AccountViewModel>(context, listen: false)
                  .account!
                  .id
              : null,
        );
      } else {
        return await categoryViewModel.updateCategory(
          categoryId: widget.category!.id,
          title: title,
          icon: icon,
          color: color,
          categoryType: widget.categoryType,
        );
      }
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
                        RepoResponse repoResponse = await submit(
                          title: titleController.text,
                          icon: iconController.text,
                          color: colorController.text,
                        );
                        Provider.of<InternalNotification>(context,
                                listen: false)
                            .showMessage(
                                repoResponse.message, repoResponse.success);
                        Navigator.pop(context);
                      }
                    },
                    child: Text(locale.action(widget.action).capitalize()),
                  ),
                  if (widget.action == "update")
                    ElevatedButton(
                      onPressed: () async {
                        final RepoResponse repoResponse =
                            await categoryViewModel.deleteCategory(
                          categoryId: widget.category!.id,
                          categoryType: widget.categoryType,
                        );

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

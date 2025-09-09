import 'package:account_managment/UI/components/categories/category_color_picker.dart';
import 'package:account_managment/UI/components/categories/category_icon_picker.dart';
import 'package:account_managment/helpers/internal_notification_helper.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/models/category.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/category_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:account_managment/helpers/validation_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

class CategoryDrawer extends StatefulWidget {
  final String action;
  final String categoryType;
  final CategoryApp? category;

  @override
  const CategoryDrawer(
      {super.key,
      required this.action,
      required this.categoryType,
      this.category});

  @override
  _CategoryDrawerState createState() => _CategoryDrawerState();
}

class _CategoryDrawerState extends State<CategoryDrawer> {
  final TextEditingController titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Color currentColor = const Color(0xff443a49);
  IconPickerIcon _selectedIcon = const IconPickerIcon(
      name: "category",
      pack: IconPack.material,
      data: IconData(0xe148, fontFamily: 'MaterialIcons'));

  @override
  void initState() {
    super.initState();
    titleController.text = widget.category?.title ?? "";
    _selectedIcon = widget.category?.icon ?? _selectedIcon;
    currentColor = Color(widget.category?.color ?? 0xff443a49);
  }

  @override
  Widget build(BuildContext context) {
    final CategoryViewModel categoryViewModel =
        Provider.of<CategoryViewModel>(context);
    final InternalNotification internalNotification =
        Provider.of<InternalNotification>(context, listen: false);
    final AppLocalizations locale = AppLocalizations.of(context)!;

    Future<RepoResponse> submit() async {
      return widget.action == "create"
          ? await categoryViewModel.createCategory(
              title: titleController.text,
              icon: _selectedIcon,
              color: currentColor.toARGB32(),
              contentType: widget.categoryType,
              objectId: widget.categoryType == "account"
                  ? Provider.of<AccountViewModel>(context, listen: false)
                      .account!
                      .id
                  : null,
            )
          : await categoryViewModel.updateCategory(
              title: titleController.text,
              icon: _selectedIcon,
              color: currentColor.toARGB32(),
              categoryType: widget.categoryType,
              categoryId: widget.category!.id,
            );
    }

    return Padding(
        padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 4.0),
        child: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: titleController,
                    decoration:
                        InputDecoration(labelText: locale.title.capitalize()),
                    maxLength: 25,
                    validator: (value) => ValidationHelper.validateInput(
                        value, ["notEmpty", "notNull", "validTextOrDigitOnly"]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CategoryColorPicker(
                            currentColor: currentColor,
                            onColorChanged: (color) {
                              setState(() {
                                currentColor = color;
                              });
                              Navigator.of(context).pop();
                            }),
                        CategoryIconPicker(
                            selectedIcon: _selectedIcon,
                            onIconSelected: (value) {
                              setState(() {
                                _selectedIcon = value!;
                              });
                            })
                      ]),
                  const SizedBox(height: 16),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              RepoResponse repoResponse = await submit();
                              internalNotification.showMessage(
                                  repoResponse.message, repoResponse.success);
                              Navigator.pop(context);
                            }
                          },
                          child:
                              Text(locale.action(widget.action).capitalize()),
                        ),
                        if (widget.action == "update")
                          ElevatedButton(
                            onPressed: () async {
                              final RepoResponse repoResponse =
                                  await categoryViewModel.deleteCategory(
                                categoryId: widget.category!.id,
                                categoryType: widget.categoryType,
                              );
                              internalNotification.showMessage(
                                  repoResponse.message, repoResponse.success);
                              Navigator.pop(context);
                            },
                            child: Text(locale.action('delete').capitalize()),
                          )
                      ])
                ]))));
  }
}

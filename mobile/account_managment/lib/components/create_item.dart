import 'dart:convert';

import 'package:account_managment/components/input_text_form.dart';
import 'package:account_managment/models/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

final TextEditingController _titleController = TextEditingController();
final TextEditingController _descriptionController = TextEditingController();
final TextEditingController _valuationController = TextEditingController();

Future<void> createItem(BuildContext context, int accountId,
    String createOrUpdate, int? itemId) async {
  if (_formKey.currentState!.validate()) {
    if (createOrUpdate == "create") {
      final token = await const FlutterSecureStorage().read(key: 'accessToken');
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/items/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          'account': 1,
          'title': _titleController.text,
          'description': _descriptionController.text,
          'valuation': _valuationController.text,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Can't create item"),
            backgroundColor: Color.fromRGBO(255, 0, 0, 1),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2), // Customize duration as needed
            margin: EdgeInsets.only(
                bottom: 50.0,
                left: 20.0,
                right: 20.0), // Adjust margins for positioning
          ),
        );
      }
    } else {
      final token = await const FlutterSecureStorage().read(key: 'accessToken');
      final response = await http.patch(
        Uri.parse('http://10.0.2.2:8000/api/items/$itemId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          'title': _titleController.text,
          'description': _descriptionController.text,
          'valuation': _valuationController.text,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Can't update item"),
            backgroundColor: Color.fromRGBO(255, 0, 0, 1),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2), // Customize duration as needed
            margin: EdgeInsets.only(
                bottom: 50.0,
                left: 20.0,
                right: 20.0), // Adjust margins for positioning
          ),
        );
      }
    }
  }
}

Future<void> deleteItem(BuildContext context, int itemId) async {
  final token = await const FlutterSecureStorage().read(key: 'accessToken');
  final response = await http.delete(
    Uri.parse('http://10.0.2.2:8000/api/items/$itemId/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    },
  );

  if (response.statusCode == 204) {
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Can't create item"),
        backgroundColor: Color.fromRGBO(255, 0, 0, 1),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2), // Customize duration as needed
        margin: EdgeInsets.only(
            bottom: 50.0,
            left: 20.0,
            right: 20.0), // Adjust margins for positioning
      ),
    );
  }
}

void showBottomDrawer(
    {required BuildContext context,
    required int accountId,
    required Function closeCallback,
    required String createOrUpdate,
    Item? item}) {
  if (item != null) {
    _titleController.text = item.title;
    _descriptionController.text = item.description;
    _valuationController.text = item.valuation;
  }
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        height: 400, // Customize the height as needed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$createOrUpdate an item",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centers the form vertically
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InputTextForm(
                      controller: _titleController,
                      name: "Title",
                      isRequired: true,
                    ),
                    InputTextForm(
                      controller: _descriptionController,
                      name: "Description",
                      isRequired: true,
                    ),
                    InputTextForm(
                      controller: _valuationController,
                      name: "valuation",
                      isRequired: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll<Color>(
                                  Color.fromARGB(255, 167, 33, 33)),
                            ),
                            onPressed: () {
                              // Validate will return true if the form is valid, or false if
                              // the form is invalid.
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Back',
                              style:
                                  TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
                            ),
                          ),
                          ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll<Color>(
                                  Color.fromARGB(255, 33, 116, 36)),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await createItem(context, accountId,
                                    createOrUpdate, item?.id);
                                closeCallback();
                              }
                            },
                            child: Text(
                              "$createOrUpdate an item",
                              style: const TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (createOrUpdate == "update")
              ElevatedButton(
                onPressed: () async {
                  await deleteItem(context, item!.id);
                  closeCallback();
                },
                child: const Text("Delete"),
              )
          ],
        ),
      );
    },
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white, // Customize the background color
    isScrollControlled:
        true, // Allows the bottom sheet to be full-screen if necessary
  );
}

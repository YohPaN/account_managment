import 'package:flutter/material.dart';

class InputTextForm extends StatelessWidget {
  final TextEditingController controller;
  final String name;
  final bool isRequired;

  const InputTextForm(
      {super.key,
      required this.controller,
      required this.name,
      this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        label: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              WidgetSpan(
                child: Text(
                  name,
                ),
              ),
              if (isRequired)
                const WidgetSpan(
                  child: Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
        hintText: "Enter your $name",
      ),
      validator: (String? value) {
        if ((value == null || value.isEmpty) && isRequired) {
          return 'Please enter a $name';
        }
        return null;
      },
    );
  }
}

import 'package:account_managment/UI/components/icon_visibility.dart';
import 'package:account_managment/helpers/pwd_validation_helper.dart';
import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final String label;
  final String index;
  final Map<String, String> formData;
  final String? comparisonSame;
  final String? comparisonDiff;

  const PasswordField({
    super.key,
    required this.label,
    required this.index,
    required this.formData,
    this.comparisonSame,
    this.comparisonDiff,
  });

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _passwordVisibility = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          onPressed: () => setState(() {
            _passwordVisibility = !_passwordVisibility;
          }),
          icon: IconVisibility(visibility: _passwordVisibility),
        ),
      ),
      maxLength: 50,
      obscureText: _passwordVisibility,
      onSaved: (value) {
        widget.formData[widget.index] = value ?? '';
      },
      validator: (value) {
        return PwdValidationHelper.validatePassword(
          password: value!,
          comparisonSame: widget.formData[widget.comparisonSame],
          comparisonDifferent: widget.formData[widget.comparisonDiff],
        );
      },
    );
  }
}

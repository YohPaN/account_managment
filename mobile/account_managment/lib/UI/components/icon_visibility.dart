import 'package:flutter/material.dart';

class IconVisibility extends StatefulWidget {
  final bool visibility;

  const IconVisibility({super.key, required this.visibility});

  @override
  _IconVisibilityState createState() => _IconVisibilityState();
}

class _IconVisibilityState extends State<IconVisibility> {
  @override
  Widget build(BuildContext context) {
    return Icon(widget.visibility ? Icons.visibility_off : Icons.visibility);
  }
}

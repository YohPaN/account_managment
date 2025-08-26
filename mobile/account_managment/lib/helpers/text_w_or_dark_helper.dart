import 'package:flutter/material.dart';

Color textColor(int? colorNum) {
  if (colorNum == null) return Colors.black;

  return Color(colorNum).computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

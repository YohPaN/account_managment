import 'package:flutter/material.dart';

Color textColor(int colorNum) =>
    Color(colorNum).computeLuminance() > 0.5 ? Colors.black : Colors.white;

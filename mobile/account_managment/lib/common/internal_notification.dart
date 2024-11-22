import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class InternalNotification extends ChangeNotifier {
  void showError(String title, [String? description]) {
    // modifier l'icon

    toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: Text(title),
        description: Text(description ?? ""),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: highModeShadow,
        closeButtonShowType: CloseButtonShowType.none);
  }
}

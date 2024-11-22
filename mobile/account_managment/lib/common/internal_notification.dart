import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class InternalNotification extends ChangeNotifier {
  void showError(String title, bool success, [String? description]) {
    toastification.show(
        type: success ? ToastificationType.success : ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: Text(title),
        description: Text(description ?? ""),
        alignment: Alignment.topCenter,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: highModeShadow,
        closeOnClick: true,
        closeButtonShowType: CloseButtonShowType.none);
  }
}

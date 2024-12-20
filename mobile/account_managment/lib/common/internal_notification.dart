import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class InternalNotification extends ChangeNotifier {
  void showMessage(String title, bool success, [String? description]) {
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

  void showPendingAccountRequest(int count) {
    toastification.show(
      type: ToastificationType.warning,
      style: ToastificationStyle.flatColored,
      title: const Text("Account ask"),
      description: Text("You have $count ask to join an account"),
      alignment: Alignment.center,
      icon: const Icon(Icons.notifications),
      borderRadius: BorderRadius.circular(12.0),
      dragToClose: true,
    );
  }
}

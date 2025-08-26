import 'dart:convert';

import 'package:account_managment/config/api_config.dart';
import 'package:account_managment/helpers/navigation_index_helper.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PushNotification extends ChangeNotifier {
  ProfileViewModel profileViewModel;
  NavigationIndex navigationIndex;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final InitializationSettings initializationSettings =
      const InitializationSettings(
    android: AndroidInitializationSettings('app_icon'),
  );

  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  PushNotification({
    required this.profileViewModel,
    required this.navigationIndex,
  });

  Future<void> init(context) async {
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        navigationIndex.changeIndex(3);
      },
    );
    await pusher.init(
      apiKey: APIConfig.PUSHER_KEY,
      cluster: "eu",
      useTLS: true,
    );
    await pusher.connect();
    await pusher.subscribe(
      channelName: 'account-user-${profileViewModel.user!.username}',
      onEvent: (event) {
        displayNotification(event);
      },
    );
  }

  void displayNotification(event) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.high,
            priority: Priority.high,
            fullScreenIntent: true,
            visibility: NotificationVisibility.public,
            ticker: 'ticker');

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    if (event.data != null) {
      final data = event.data.runtimeType == String
          ? jsonDecode(event.data)
          : event.data;

      if (data["title"] != null && data["message"] != null) {
        await flutterLocalNotificationsPlugin.show(
            0, data["title"], data["message"], notificationDetails,
            payload: 'item x');
      }
    }
  }
}

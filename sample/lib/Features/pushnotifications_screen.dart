import 'package:flutter/material.dart';
import '../Components/alert.dart';
import '../device_info_fetcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class PushNotificationsScreen extends StatefulWidget {
  @override
  _PushNotificationState createState() => _PushNotificationState();
}

class _PushNotificationState extends State<PushNotificationsScreen> {
  final _deviceInfoFetcher = DeviceInfoFetcher();

  @override
  Widget build(BuildContext context) {
    Future<void> enableNotification(BuildContext context) async {
    try {
      // Request notification permission
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await _deviceInfoFetcher.registerDevice();
        AlertDialogHelper.showAlertDialog(context, "Notification", "Push Notification Enabled");
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _deviceInfoFetcher.registerDevice();
        AlertDialogHelper.showAlertDialog(context, "Notification", "Provisional Push Notification Enabled");
      } else {
        AlertDialogHelper.showAlertDialog(context, "Permission Denied", "Please enable notifications in settings");
      }
    } catch (error) {
      AlertDialogHelper.showAlertDialog(context, "Error", "Failed to enable push notifications: $error");
    }
  }

    void disableNotification(BuildContext context) async {
      try {
        await _deviceInfoFetcher.unregisterDevice();
        AlertDialogHelper.showAlertDialog(context, "Notification", "Push Notification Disabled");
      } catch (error) {
        AlertDialogHelper.showAlertDialog(context, "Error", "Failed to disable push notifications: $error");
      }
    }

    List<Map<String, dynamic>> getMenuItems() {
      return [
        {"title": "Register for Push Notification", "action": () => enableNotification(context)},
        {"title": "Unregister from Push Notification", "action": () => disableNotification(context)},
      ];
    }

    final notificationMenuItems = getMenuItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Push Notification"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {}); // Refresh the UI
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: notificationMenuItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notificationMenuItems[index]["title"]),
            onTap: notificationMenuItems[index]["action"],
          );
        },
      ),
    );
  }
}

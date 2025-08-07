import 'dart:io';
import 'package:devrev_sdk_flutter/devrev.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as secure;
import 'package:uuid/uuid.dart';

class DeviceInfoFetcher {
  static final secure.FlutterSecureStorage _storage = secure.FlutterSecureStorage();

  static String? _deviceId;

  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    try {
      String? storedId = await _storage.read(key: "device_id");

      if (storedId != null) {
        _deviceId = storedId;
      } else {
        _deviceId = const Uuid().v4();
        await _storage.write(key: "device_id", value: _deviceId);
      }

      print("Device ID: $_deviceId");
      return _deviceId!;
    } catch (error) {
      print("Error getting device ID: $error");
      throw Exception("Failed to get device ID");
    }
  }

  Future<String?> getDeviceToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      if (Platform.isIOS) {
        NotificationSettings settings = await messaging.requestPermission();
        if (settings.authorizationStatus != AuthorizationStatus.authorized) {
          print("Notifications permission not granted");
          return null;
        }

        String? apnsToken = await messaging.getAPNSToken();
        print("iOS APNs Token: $apnsToken");

        return apnsToken;
      } else if (Platform.isAndroid) {
        String? fcmToken = await messaging.getToken();
        print("Android FCM Token: $fcmToken");

        return fcmToken;
      }

      return null;
    } catch (e) {
      print("Error getting device token: $e");
      return null;
    }
  }

  /// Registers the device from DevRev.
  Future<void> registerDevice() async {
    try {
      String deviceId = await getDeviceId();
      final String? token = await getDeviceToken();

      if (token != null) {
        await DevRev.registerDeviceToken(token, deviceId);
        print("Successfully registered with DevRev");
      } else {
        print("Failed to get Firebase device token");
      }
    } catch (error) {
      print("Error registering device: $error");
      rethrow;
    }
  }

  /// Unregisters the device from DevRev.
  Future<void> unregisterDevice() async {
    try {
      String deviceId = await getDeviceId();
      DevRev.unregisterDevice(deviceId);
      print("Device unregistered - ID: $deviceId");
    } catch (error) {
      print("Error unregistering device: $error");
      rethrow;
    }
  }

  /// Logs out the device from DevRev and clears stored device ID.
  Future<void> logout() async {
    try {
      String deviceId = await getDeviceId();
      DevRev.logout(deviceId);
      _deviceId = null;
      await _storage.delete(key: "device_id"); // Clear stored device ID
      print("Logged out successfully");
    } catch (error) {
      print("Error logging out: $error");
      rethrow;
    }
  }
}

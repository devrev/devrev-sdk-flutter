# DevRev SDK for Flutter
DevRev SDK, used for integrating DevRev services into your Flutter app.

## Table of contents
- [DevRev SDK for Flutter](#devrev-sdk-for-flutter)
  - [Table of contents](#table-of-contents)
  - [Quickstart guide](#quickstart-guide)
    - [Requirements](#requirements)
    - [Installation](#installation)
    - [Set up the DevRev SDK](#set-up-the-devrev-sdk)
  - [Features](#features)
    - [Identification](#identification)
      - [Anonymous identification](#anonymous-identification)
      - [Unverified identification](#unverified-identification)
      - [Verified identification](#verified-identification)
        - [Generate an AAT](#generate-an-aat)
        - [Exchange your AAT for a session token](#exchange-your-aat-for-a-session-token)
        - [Identifying the verified user](#identifying-the-verified-user)
    - [Update the user](#update-the-user)
      - [Logout](#logout)
    - [Identity model](#identity-model)
      - [Properties](#properties)
      - [User traits](#user-traits)
      - [Organization traits](#organization-traits)
      - [Account traits](#account-traits)
    - [PLuG support chat](#plug-support-chat)
      - [Creating a new support conversation](#creating-a-new-support-conversation)
    - [In-app link handling](#in-app-link-handling)
    - [Analytics](#analytics)
    - [Session analytics](#session-analytics)
      - [Opting-in or out](#opting-in-or-out)
    - [Session recording](#session-recording)
    - [Session properties](#session-properties)
    - [Masking sensitive data](#masking-sensitive-data)
    - [Unmasking sensitive data](#unmasking-sensitive-data)
    - [Advanced session recording control while masking](#advanced-session-recording-control-while-masking)
    - [Timers](#timers)
    - [Screen tracking](#screen-tracking)
      - [Screen transition tracking (Android only)](#screen-transition-tracking-android-only)
    - [Push notifications](#push-notifications)
      - [Configuration](#configuration)
      - [Register for push notifications](#register-for-push-notifications)
      - [Unregister from push notifications](#unregister-from-push-notifications)
      - [Processing push notifications](#processing-push-notifications)
        - [Android](#android)
        - [iOS](#ios)
  - [Sample app](#sample-app)
  - [Troubleshooting](#troubleshooting)
  - [Migration guide](#migration-guide)

## Quickstart guide

### Requirements

- Flutter 3.3.0 or later.
- Dart SDK 3.7.0 or later.
- On Android, the minimum API level should be 24.
- On iOS, the minimum deployment target should be 15.0.

### Installation

To install the DevRev SDK, run the following command:
```sh
flutter pub add devrev_sdk_flutter
```

It automatically fetches the latest version of our package and adds it to your project's pubspec.yaml file:
```yaml
dependencies:
    devrev_sdk_flutter: <version>
```

Alternatively, you can add the dependency manually by adding the package to your `pubspec.yaml` file under the `dependencies` section and run `flutter pub get` to install the package.

To get the latest version of the SDK, you can check the [pub.dev page](https://pub.dev/packages/devrev_sdk_flutter).

### Set up the DevRev SDK

1. Open the DevRev web app at [https://app.devrev.ai](https://app.devrev.ai) and go to the **Settings** page.
2. Under **PLuG settings** copy the value under **Your unique App ID**.
3. After obtaining the credentials, you can configure the DevRev SDK in your app.

> [!WARNING]
> The DevRev SDK must be configured before you can use any of its features.

The SDK becomes ready for use once the following configuration method is executed.

```dart
DevRev.configure(appID);
```

For example:

```dart
DevRev.configure(appID: "abcdefg12345")
```

## Features

### Identification

To access certain features of the DevRev SDK, user identification is required.

The identification function should be placed appropriately in your app after the user logs in. If you have the user information available at app launch, call the function after the `DevRev.configure(appID:)` method.

> [!TIP]
> On iOS, if you haven't previously identified the user, the DevRev SDK will automatically create an anonymous user for you immediately after the SDK is configured.

> [!TIP]
> The `Identity` structure allows for custom fields in the user, organization, and account traits. These fields must be configured through the DevRev app before they can be used. For more information, refer to [Object customization](https://developer.devrev.ai/docs/product/object-customization).

You can select from the following methods to identify users within your application:

#### Anonymous identification
The anonymous identification method allows you to create an anonymous user with an optional user identifier, ensuring that no other data is stored or associated with the user.
```dart
DevRev.identifyAnonymousUser(userID);
```

#### Unverified identification
The unverified identification method identifies users with a unique identifier, but it does not verify their identity with the DevRev backend.
```dart
DevRev.identifyUnverifiedUser(userID, organizationID);
```

#### Verified identification
The verified identification method is used to identify users with an identifier unique to your system within the DevRev platform. The verification is done through a token exchange process between you and the DevRev backend.

The steps to identify a verified user are as follows:
1. Generate an AAT for your system (preferably through your backend).
2. Exchange your AAT for a session token for each user of your system.
3. Pass the user identifier and the exchanged session token to the `DevRev.identifyVerifiedUser(userID, sessionToken)` method.

> [!CAUTION]
> For security reasons we **strongly recommend** that the token exchange is executed on your backend to prevent exposing your application access token (AAT).

##### Generate an AAT

1. Open the DevRev web app at [https://app.devrev.ai](https://app.devrev.ai) and go to the **Settings** page.
2. Open the **PLuG Tokens** page.
3. Under the **Application access tokens** panel, click **New token** and copy the token that's displayed.

> [!WARNING]
> Ensure that you copy the generated application access token, as you cannot view it again.

##### Exchange your AAT for a session token

To proceed with identifying the user, you need to exchange your AAT for a session token. This step helps you identify a user of your own system within the DevRev platform.

Here is a simple example of an API request to the DevRev backend to exchange your AAT for a session token:

> [!WARNING]
> Make sure that you replace the `<AAT>` and `<YOUR_USER_ID>` with the actual values.
```bash
curl \
--location 'https://api.devrev.ai/auth-tokens.create' \
--header 'accept: application/json, text/plain, */*' \
--header 'content-type: application/json' \
--header 'authorization: <AAT>' \
--data '{
  "rev_info": {
    "user_ref": "<YOUR_USER_ID>"
  }
}'
```

The response of the API call contains a session token that you can use with the verified identification method in your app.

> [!WARNING]
> As a good practice, **your** app should retrieve the exchanged session token from **your** backend at app launch or any relevant app lifecycle event.

##### Identifying the verified user
Pass the user identifier and the exchanged session token to the verified identification method:

```dart
DevRev.identifyVerifiedUser(userID, sessionToken);
```

### Update the user

You can update the user's information using the following method:

```dart
DevRev.updateUser(identity)
```

> [!WARNING]
> The `userID` property cannot be updated.

Use this property to check whether the user is identified in the current session:

```dart
await DevRev.isUserIdentified
```

#### Logout

You can perform a logout of the current user by calling the following method:

```dart
DevRev.logout(deviceID);
```

The user is logged out by clearing their credentials, as well as unregistering the device from receiving push notifications, and stopping the session recording.

For example:

```dart
// Identify an anonymous user with a user identifier.
await DevRev.identifyAnonymousUser("user@example.org")

// Identify an unverified user using their email address as the user identifier.
await DevRev.identifyUnverifiedUser("user@example.org", "organization-1337")

// Identify a verified user using their email address as the user identifier.
await DevRev.identifyVerifiedUser("foo@example.org", "bar-1337")

// Update the user's information.
await DevRev.updateUser({"organizationRef": "organization-1337"})

// Logout the identified user.
await DevRev.logout("dvc32423")
```

### Identity model

User identity information is passed as a `Map<String, dynamic>` to the `updateUser` method. The map can contain user, organization, and account information.

#### Properties

The identity map can contain the following properties:

| Property | Type | Description |
|----------|------|--------------|
| `userRef` | `String` | A unique identifier for the user |
| `organizationRef` | `String?` | An identifier for the user's organization |
| `accountRef` | `String?` | An identifier for the user's account |
| `userTraits` | `Map<String, dynamic>?` | Additional information about the user |
| `organizationTraits` | `Map<String, dynamic>?` | Additional information about the organization |
| `accountTraits` | `Map<String, dynamic>?` | Additional information about the account |

> [!NOTE]
> Custom fields must be configured in the DevRev web app **before** they can be used. See [Object customization](https://developer.devrev.ai/docs/product/object-customization) for more information.

#### User traits

The `userTraits` map can contain detailed information about the user:

| Property | Type | Description |
|----------|------|--------------|
| `displayName` | `String?` | The displayed name of the user |
| `email` | `String?` | The user's email address |
| `fullName` | `String?` | The user's full name |
| `description` | `String?` | A description of the user |
| `customFields` | `Map<String, dynamic>?` | Dictionary of custom fields configured in DevRev |

#### Organization traits

The `organizationTraits` map can contain detailed information about the organization:

| Property | Type | Description |
|----------|------|--------------|
| `displayName` | `String?` | The displayed name of the organization |
| `domain` | `String?` | The organization's domain |
| `description` | `String?` | A description of the organization |
| `phoneNumbers` | `List<String>?` | Array of the organization's phone numbers |
| `tier` | `String?` | The organization's tier or plan level |
| `customFields` | `Map<String, dynamic>?` | Dictionary of custom fields configured in DevRev |

#### Account traits

The `accountTraits` map can contain detailed information about the account:

| Property | Type | Description |
|----------|------|--------------|
| `displayName` | `String?` | The displayed name of the account |
| `domains` | `List<String>?` | Array of domains associated with the account |
| `description` | `String?` | A description of the account |
| `phoneNumbers` | `List<String>?` | Array of the account's phone numbers |
| `websites` | `List<String>?` | Array of websites associated with the account |
| `tier` | `String?` | The account's tier or plan level |
| `customFields` | `Map<String, dynamic>?` | Dictionary of custom fields configured in DevRev |

### PLuG support chat

Once user identification is complete, you can start using the chat (conversations) dialog supported by our DevRev SDK. The support chat feature can be shown as a modal screen from the top-most screen.

```dart
DevRev.showSupport();
```

#### Creating a new support conversation

You can initiate a new support conversation directly from your app. This method displays the support chat screen and simultaneously creates a new conversation.

```dart
DevRev.createSupportConversation();
```

### In-app link handling
In certain cases, tapping links in the support chat opens them in the app instead of a browser. You can control whether the chat modal screen is dismissed after the link is opened by calling the following method:

```dart
DevRev.setShouldDismissModalsOnOpenLink(value);
```

Setting this flag to true applies the system's default behavior for opening links, which includes dismissing any DevRev modal screens to facilitate handling your own deep links.

### Analytics

The DevRev SDK allows you to send custom analytic events by using a properties map. You can track these events using the following function:

```dart
DevRev.trackEvent(name, properties);
```

For example:

```dart
await DevRev.trackEvent("open-message-screen", {"id": "message-1337"})
```

### Session analytics
The DevRev SDK offers session analytics features to help you understand how users interact with your app.

#### Opting-in or out
Session analytics features are opted-in by default, enabling them from the start. However, you can opt-out using the following method:
```dart
DevRev.stopAllMonitoring();
```

To opt back in, use the following method:
```dart
DevRev.resumeAllMonitoring();
```

### Session recording

You can enable session recording to record user interactions with your app.

> [!WARNING]
> The session recording feature is opt-out and is enabled by default.

The session recording feature includes the following methods to control the recording:

| Method                                                               | Action                                                    |
|--------------------------------------------------------------------|-----------------------------------------------------------|
|`DevRev.startRecording()`   | Starts the session recording.                             |
|`DevRev.stopRecording()`    | Ends the session recording and uploads it to the portal. |
|`DevRev.pauseRecording()`   | Pauses the ongoing session recording.                     |
|`DevRev.resumeRecording()`  | Resumes a paused session recording.                       |
|`DevRev.processAllOnDemandSessions()` | Stops the ongoing session recording and uploads all offline sessions on demand, including the current one. |

### Session properties

You can add custom properties to the session recording to help you understand the context of the session. The properties are defined as a map of string values.

```dart
DevRev.addSessionProperties(properties);
```

To clear the session properties in scenarios such as user logout or when the session ends, use the following method:

```dart
DevRev.clearSessionProperties();
```

### Masking sensitive data

To protect sensitive data, you can mask sensitive UI elements such as text fields, text views, and web views using `DevRevMask` widget, as shown below.

For example:

```dart
DevRevMask(
  child: TextField(
    decoration: InputDecoration(labelText: "foo-bar"),
  ),
)
```

### Unmasking sensitive data

You can also manually unmask UI elements that would otherwise be automatically masked using `DevRevUnmask`:

For example:

```dart
DevRevUnmask(
  child: TextField(
    decoration: InputDecoration(labelText: "foo-bar"),
    ),
  )
```

### Advanced session recording control while masking

For enhanced session recording and screen transition handling, you can use `DevRevMonitoredApp` as a drop-in replacement for `MaterialApp`. This widget automatically handles screen transition states and ensures proper masking during navigation.

> [!NOTE]
> `DevRevMonitoredApp` is particularly useful when users want to avoid capturing snapshots during screen navigations, especially if any glitches occur. However, in most cases, this won't be necessary, as most of masking scenarios are not affected by standard navigation. This is an optional solution for enhanced control over session recording behavior.

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DevRevMonitoredApp(
      title: "My App",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
```

### Timers

The DevRev SDK offers a timer mechanism to measure the time spent on specific tasks, allowing you to track events such as response time, loading time, or any other duration-based metrics.

The mechanism uses balanced start and stop methods, both of which accept a timer name and an optional dictionary of properties.

To start a timer, use the following method:

```dart
DevRev.startTimer(name, properties)
```

To stop a timer, use the following method:

```dart
DevRev.endTimer(name, properties)
```

For example:

```dart
DevRev.startTimer("response-time", {"id": "task-1337"})

// Perform the task that you want to measure.

DevRev.endTimer("response-time", {"id": "task-1337"})
```

### Screen tracking

The DevRev SDK offers automatic screen tracking to help you understand how users navigate through your app. Although view controllers are automatically tracked, you can manually track screens using the following method:

```dart
DevRev.trackScreenName(screenName);
```

For example:

```dart
DevRev.trackScreenName("profile-screen")
```

#### Screen transition tracking (Android only)

On Android, the DevRev SDK provides methods to manually track the screen transitions.

When a screen transition begins, you must call the following method:

```dart
DevRev.setInScreenTransitioning(true)
```

When a screen transition ends, you must call the following method:

```dart
DevRev.setInScreenTransitioning(false)
```

### Push notifications
You can configure your app to receive push notifications from the DevRev SDK. The SDK is able to handle push notifications and execute actions based on the notification's content.

The DevRev backend sends push notifications to your app to notify users about new messages in the PLuG support chat.

#### Configuration

To receive push notifications, you need to configure your DevRev organization by following the instructions in the [push notifications](https://developer.devrev.ai/sdks/mobile/push-notifications) section.

#### Register for push notifications

> [!NOTE]
> Push notifications require that the SDK has been configured and the user has been identified, to ensure delivery to the correct user.

The DevRev SDK offers a method to register your device for receiving push notifications. You can register for push notifications using the following method:

```dart
DevRev.registerDeviceToken(deviceToken, deviceID);
```

On Android devices, the `deviceToken` should be the Firebase Cloud Messaging (FCM) token value, while on iOS devices, it should be the Apple Push Notification Service (APNs) token.

#### Unregister from push notifications

If your app no longer needs to receive push notifications, you can unregister the device.

Use the following method to unregister the device:

```dart
DevRev.unregisterDevice(deviceID);
```

The method requires the device identifier, which should be the same as the one used when registering the device.

#### Processing push notifications

##### Android

On Android, notifications are implemented as data messages to offer flexibility. However, this means that automatic click processing isn't available. To handle notification clicks, developers need to intercept the click event, extract the payload, and pass it to a designated method for processing. This custom approach enables tailored notification handling in Android applications.

To process the notification, use the following method:

```dart
DevRev.processPushNotification(payload);
```

Here, the `message` object from the notification payload needs to be passed to this function.

For example:

```dart
const notificationPayload = {
    "message": {
        "title": "New Message",
        "body": "You have received a new message.",
        "data": {
            "messageId": "12345",
            "sender": "John Doe"
        }
    }
};

const messageJson = notificationPayload["message"];

if (messageJson != null) {
  DevRev.processPushNotification(jsonEncode(messageJson));
}
```

##### iOS

On iOS devices, you must pass the received push notification payload to the DevRev SDK for processing. The SDK will then handle the notification and execute the necessary actions.

```dart
DevRev.processPushNotification(payload: String)
```

For example:

```dart
const notificationPayload = {
    "message": {
        "title": "New Message",
        "body": "You have received a new message.",
        "data": {
            "messageId": "12345",
            "sender": "John Doe"
        }
    }
};

const messageJson = notificationPayload["message"];

if (messageJson != null) {
  DevRev.processPushNotification(jsonEncode(messageJson));
}
```

## Sample app

A sample app with use cases for the DevRev SDK for Flutter has been provided as a part of our [public repository](https://github.com/devrev/devrev-sdk-flutter). To set up and run the sample app:

1. Go to the `sample` directory:
   ```sh
   cd sample
   flutter clean
   rm -rf ios android web linux macos windows
   flutter create --platforms=android,ios .
   ```

2. Install dependencies:
   ```sh
   flutter pub get
   ```

3. iOS app:
   Open the `ios/Runner.xcworkspace` in Xcode for running the iOS app or run the following command.
   ```sh
   flutter run -d ios
   ```

   Additional Steps for iOS before running the app:
   1. Change the minimum iOS deployment target version to `15.0`.
   2. Go to the `ios` directory and perform `pod install`.
   3. Open `ios/Runner.xcodeproj` in Xcode and select `Package dependencies -> FlutterGeneratedPluginSwiftPackage -> Package.swift` set iOS version from `12` to `15`.
      ```swift
      platforms: [
         .iOS("15.0")
      ]
      ```
   4. Perform `File -> Packages -> Resolve package versions`.
   5. Build and run the app.

4. Android app:
   Open the `android` directory in Android Studio or run the following command.
   ```sh
   flutter run -d android
   ```

## Troubleshooting

- **Issue**: Support chat doesn't show.
	**Solution**: Ensure you have correctly called one of the identification methods: `DevRev.identifyUnverifiedUser(...)`, `DevRev.identifyVerifiedUser(...)`, or `DevRev.identifyAnonymousUser(...)`.

- **Issue**: Not receiving push notifications.
	**Solution**: Ensure that your app is configured to receive push notifications and that your device is registered with the DevRev SDK.

## Migration guide
If you are migrating from the legacy UserExperior SDK to the new DevRev SDK, please refer to the [Migration Guide](./MIGRATION.md) for detailed instructions and feature equivalence.

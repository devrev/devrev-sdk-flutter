# DevRev SDK for Flutter
DevRev SDK, used for integrating DevRev services into your Flutter app.

- [DevRev SDK for Flutter](#devrev-sdk-for-flutter)
	- [Quickstart guide](#quickstart-guide)
		- [Requirements](#requirements)
		- [Installation](#installation)
		- [Set up the DevRev SDK](#set-up-the-devrev-sdk)
			- [Update the feature configuration](#update-the-feature-configuration)
			- [Feature configuration reference](#feature-configuration-reference)
				- [Support widget theme options](#support-widget-theme-options)
	- [Features](#features)
		- [Identification](#identification)
			- [Identify an unverified user](#identify-an-unverified-user)
			- [Identify a verified user](#identify-a-verified-user)
				- [Generate an AAT](#generate-an-aat)
				- [Exchange your AAT for a session token](#exchange-your-aat-for-a-session-token)
				- [Identify the verified user](#identify-the-verified-user)
		- [Update the user](#update-the-user)
			- [Logout](#logout)
		- [Identity model](#identity-model)
			- [Properties](#properties)
			- [User traits](#user-traits)
			- [Organization traits](#organization-traits)
			- [Account traits](#account-traits)
		- [Support chat](#support-chat)
			- [Create a new support conversation](#create-a-new-support-conversation)
		- [In-app link handling](#in-app-link-handling)
		- [Dynamic theme configuration](#dynamic-theme-configuration)
		- [Analytics](#analytics)
		- [Session analytics](#session-analytics)
			- [Opt in or out](#opt-in-or-out)
			- [Session recording](#session-recording)
			- [Session properties](#session-properties)
			- [Mask sensitive data](#mask-sensitive-data)
			- [Unmask sensitive data](#unmask-sensitive-data)
			- [Mask elements inside web views](#mask-elements-inside-web-views)
			- [Advanced session recording control while masking](#advanced-session-recording-control-while-masking)
			- [Timers](#timers)
			- [User interaction tracking](#user-interaction-tracking)
			- [Capture errors](#capture-errors)
			- [Track screens](#track-screens)
			- [Manage screen transitions (Android only)](#manage-screen-transitions-android-only)
		- [Push notifications](#push-notifications)
			- [Configuration](#configuration)
			- [Register for push notifications](#register-for-push-notifications)
			- [Unregister from push notifications](#unregister-from-push-notifications)
			- [Processing push notifications](#processing-push-notifications)
				- [Android](#android)
				- [iOS](#ios)
	- [Sample app](#sample-app)
	- [Troubleshooting](#troubleshooting)
		- [ProGuard (Android only)](#proguard-android-only)
	- [Migration guide](#migration-guide)

## Quickstart guide

### Requirements

- Flutter 3.3.0 or later.
- Dart SDK 3.5.0 or later.
- Android: minimum API level 24.
- iOS: minimum deployment target 15.0.

### Installation

To install the DevRev SDK, run the following command:
```sh
flutter pub add devrev_sdk_flutter
```

It automatically fetches the latest version of our package and adds it to your project's pubspec.yaml file:
```yaml
dependencies:
	devrev_sdk_flutter: <VERSION>
```

Alternatively, you can add the dependency manually by adding the package to your `pubspec.yaml` file under the `dependencies` section and run `flutter pub get` to install the package.

To get the latest version of the SDK, you can check the [pub.dev page](https://pub.dev/packages/devrev_sdk_flutter).

> [!NOTE]
> Starting with version `2.2.5`, the iOS portion of the plugin ships with a CocoaPods podspec. Flutter uses CocoaPods by default, so no additional Swift Package Manager configuration is required. If you prefer to keep using Swift Package Manager (`flutter config --enable-swift-package-manager`), the package continues to publish a `Package.swift`.

### Set up the DevRev SDK

1. Open the DevRev web app at [https://app.devrev.ai](https://app.devrev.ai) and go to the **Settings** page.
2. Under **PLuG settings** copy the value under **Your unique App ID**.
3. Configure the DevRev SDK in your app using the obtained credentials.

> [!WARNING]
> The DevRev SDK must be configured before you can use any of its features.

The SDK becomes ready for use once the configuration API is executed. Import the SDK and use `FeatureConfiguration` and `SupportWidgetTheme` (exported from the main package) when you need to customize behavior:

```dart
import 'package:devrev_sdk_flutter/devrev.dart';

// Configure with app ID only (defaults for all options).
await DevRev.configure(appID);
```

To provide a feature configuration during setup, pass a `FeatureConfiguration` as the second argument:

```dart
await DevRev.configure(appID, featureConfiguration);
```

For default behavior, call with just the app ID:

```dart
await DevRev.configure("abcdefg12345");
```

To customize behavior such as frame capture, auto-start recording, dialog mode (Android only), or theme preferences, pass a `FeatureConfiguration`:

```dart
final featureConfiguration = FeatureConfiguration(
  enableFrameCapture: true,
  autoStartRecording: true,
  alwaysUseRemoteConfig: true,
  prefersDialogMode: false,  // Android only
  supportWidgetTheme: SupportWidgetTheme(
    prefersSystemTheme: false,
    primaryTextColor: '#000000',
    accentColor: '#FF5733',
    spacing: {'bottom': '20px', 'side': '15px'},
  ),
);

await DevRev.configure(appID, featureConfiguration);
```

#### Update the feature configuration

You can adjust the feature configuration without reconfiguring the SDK:

```dart
await DevRev.updateFeatureConfiguration(FeatureConfiguration(
  enableFrameCapture: true,
  autoStartRecording: false,
  alwaysUseRemoteConfig: true,
  prefersDialogMode: false,  // Android only
  supportWidgetTheme: SupportWidgetTheme(prefersSystemTheme: true),
));
```

#### Feature configuration reference

`FeatureConfiguration` controls how the SDK behaves both during initial setup and when calling `DevRev.updateFeatureConfiguration`. All properties are required when providing a feature configuration.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `enableFrameCapture` | `bool` | `true` | Enables the screen capture pipeline used by session replay. |
| `autoStartRecording` | `bool` | `true` | Automatically starts recording after the SDK finishes remote configuration. |
| `prefersDialogMode` | `bool` | `false` | Prefer dialog mode for the support UI (Android only). |
| `alwaysUseRemoteConfig` | `bool` | `true` | Always use remote config. |
| `supportWidgetTheme` | `SupportWidgetTheme` | — | Controls the appearance of the in-app support widget, including dynamic theme behavior. |

##### Support widget theme options

`SupportWidgetTheme` lets you fine-tune the support UI. Use the `supportWidgetTheme` property inside your feature configuration.

```dart
SupportWidgetTheme(
  prefersSystemTheme: false,
  primaryTextColor: '#1F2933',
  accentColor: '#F97316',
  spacing: {'bottom': '20px', 'side': '16px'},
)
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `prefersSystemTheme` | `bool` | `true` | Follows the device appearance when `true`; otherwise uses your custom colors. |
| `primaryTextColor` | `String?` | — | Hex color string (e.g. `'#000000'`, `'#1F2933'`) for primary text in the support widget. |
| `accentColor` | `String?` | — | Hex color string (e.g. `'#F97316'`, `'#FF0000'`) applied to buttons and highlights. |
| `spacing` | `Map<String, String>?` | — | CSS-like spacing overrides (`bottom` and `side` keys are recognized). |

## Features

### Identification

To access certain features of the DevRev SDK, user identification is required.

The identification function should be placed appropriately in your app after the user logs in. If you have the user information available at app launch, call the function after `DevRev.configure(appID)` has completed.

> [!TIP]
> If you haven't previously identified the user, the DevRev SDK will automatically create an anonymous user for you immediately after the SDK is configured.

> [!TIP]
> The `Identity` structure allows for custom fields in the user, organization, and account traits. These fields must be configured through the DevRev app before they can be used. For more information, refer to [Object customization](https://devrev.ai/docs/product/object-customization).

You can select from the following methods to identify users within your application:

#### Identify an unverified user

The unverified identification method identifies users with a unique identifier, but it does not verify their identity with the DevRev backend.

```dart
DevRev.identifyUnverifiedUser(userID, organizationID);
```

#### Identify a verified user

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

##### Identify the verified user
Pass the user identifier and the exchanged session token to the verified identification method:

```dart
DevRev.identifyVerifiedUser(userID, sessionToken);
```

### Update the user

You can update the user's information using the following method:

```dart
DevRev.updateUser(identity);
```

For example:

```dart
final identity = {
  'userRef': 'user-123',
  'userTraits': {
    'displayName': 'Jane Doe',
    'email': 'jane@example.com',
    'fullName': 'Jane Q. Doe',
    'description': 'Power user',
    'phoneNumbers': ['+1-555-123-4567'],
    'customFields': {
      'plan': 'enterprise',
      'seats': 42,
    },
  },
};

await DevRev.updateUser(identity);
```

> [!WARNING]
> The `userID` property cannot be updated.

Use this property to check whether the user is identified in the current session:

```dart
DevRev.isUserIdentified;
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
DevRev.identifyAnonymousUser("user@example.org");

// Identify an unverified user using their email address as the user identifier.
DevRev.identifyUnverifiedUser("user@example.org", "organization-1337");

// Identify a verified user using their email address as the user identifier.
DevRev.identifyVerifiedUser("foo@example.org", "bar-1337");

// Update the user's information.
DevRev.updateUser({"organizationRef": "organization-1337"});

// Logout the identified user.
DevRev.logout("dvc32423");
```

### Identity model

User identity information is passed as a `Map<String, dynamic>` to the `updateUser` method. The map can contain user, organization, and account information.

#### Properties

The identity map can contain the following properties:

| Property | Type | Required | Description |
|----------|------|----------|--------------|
| `userRef` | `String` | ✅ | A unique identifier for the user |
| `organizationRef` | `String?` | ❌ | An identifier for the user's organization |
| `accountRef` | `String?` | ❌ | An identifier for the user's account |
| `userTraits` | `Map<String, dynamic>?` | ❌ | Additional information about the user |
| `organizationTraits` | `Map<String, dynamic>?` | ❌ | Additional information about the organization |
| `accountTraits` | `Map<String, dynamic>?` | ❌ | Additional information about the account |

> [!NOTE]
> The custom fields properties defined as part of the user, organization and account traits, must be configured in the DevRev web app **before** they can be used. See [Object customization](https://devrev.ai/docs/product/object-customization) for more information.

#### User traits

The `userTraits` map contains detailed information about the user:

> [!NOTE]
> All properties in `userTraits` are optional.

| Property | Type | Description |
|----------|------|--------------|
| `displayName` | `String?` | The displayed name of the user |
| `email` | `String?` | The user's email address |
| `fullName` | `String?` | The user's full name |
| `description` | `String?` | A description of the user |
| `phoneNumbers` | `List<String>?` | The user's phone numbers |
| `customFields` | `Map<String, dynamic>?` | Dictionary of custom fields configured in DevRev |

#### Organization traits

The `organizationTraits` map contains detailed information about the organization:

> [!NOTE]
> All properties in `organizationTraits` are optional.

| Property | Type | Description |
|----------|------|--------------|
| `displayName` | `String?` | The displayed name of the organization |
| `domain` | `String?` | The organization's domain |
| `description` | `String?` | A description of the organization |
| `phoneNumbers` | `List<String>?` | Array of the organization's phone numbers |
| `tier` | `String?` | The organization's tier or plan level |
| `customFields` | `Map<String, dynamic>?` | Dictionary of custom fields configured in DevRev |

#### Account traits

The `accountTraits` map contains detailed information about the account:

> [!NOTE]
> All properties in `accountTraits` are optional.

| Property | Type | Description |
|----------|------|--------------|
| `displayName` | `String?` | The displayed name of the account |
| `domains` | `List<String>?` | Array of domains associated with the account |
| `description` | `String?` | A description of the account |
| `phoneNumbers` | `List<String>?` | Array of the account's phone numbers |
| `websites` | `List<String>?` | Array of websites associated with the account |
| `tier` | `String?` | The account's tier or plan level |
| `customFields` | `Map<String, dynamic>?` | Dictionary of custom fields configured in DevRev |

### Support chat

Once user identification is complete, you can start using the chat (conversations) dialog supported by our DevRev SDK. The support chat feature can be shown as a modal screen from the top-most screen.

```dart
DevRev.showSupport();
```

#### Create a new support conversation

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

### Dynamic theme configuration

The DevRev SDK allows you to configure the theme dynamically based on the system appearance, or use the theme configured on the DevRev portal. By default, the theme is dynamic and follows the system appearance. Prefer setting the theme via `FeatureConfiguration.supportWidgetTheme` when calling `DevRev.configure` or `DevRev.updateFeatureConfiguration`. You can also use the legacy setter:

```dart
await DevRev.setPrefersSystemTheme(true);
```

### Analytics

The DevRev SDK allows you to send custom analytic events by using a properties map. You can track these events using the following function:

```dart
DevRev.trackEvent(name, properties);
```

For example:

```dart
DevRev.trackEvent("open-message-screen", {"id": "message-1337"});
```

### Session analytics
The DevRev SDK offers session analytics features to help you understand how users interact with your app.

#### Opt in or out
Session analytics features are opted-in by default, enabling them from the start. However, you can opt-out using the following method:
```dart
DevRev.stopAllMonitoring();
```

To opt back in, use the following method:
```dart
DevRev.resumeAllMonitoring();
```

#### Session recording

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

#### Session properties

You can add custom properties to the session recording to help you understand the context of the session. The properties are defined as a map of string values.

```dart
DevRev.addSessionProperties(properties);
```

To clear the session properties in scenarios such as user logout or when the session ends, use the following method:

```dart
DevRev.clearSessionProperties();
```

#### Mask sensitive data

To protect sensitive data, you can mask sensitive UI elements such as text fields, text views using the `DevRevMask` widget.

For example:

```dart
DevRevMask(
	child: TextField(
		decoration: InputDecoration(labelText: "foo-bar"),
	)
)
```

#### Unmask sensitive data

If any previously masked views need to be unmasked, you can unmask using the `DevRevUnmask` widget.

For example:

```dart
DevRevUnmask(
	child: TextField(
		decoration: InputDecoration(labelText: "foo-bar"),
	)
)
```

#### Mask elements inside web views

Input views such as password text fields are automatically masked in web views.

To mark elements as sensitive inside a web view (`WebView`), apply the `devrev-mask` CSS class. To unmark them, use `devrev-unmask`.

- Mark an element as masked:
  ```html
  <label class="devrev-mask">OTP: 12345</label>
  ```
- Mark an element as unmasked:
  ```html
  <input type="text" placeholder="Enter Username" name="username" required class="devrev-unmask">
  ```

#### Advanced session recording control while masking

For enhanced session recording and screen transition handling, you can use `DevRevMonitoredApp` as a drop-in replacement for `MaterialApp`. This widget automatically handles screen transition states and ensures proper masking during navigation.

> [!NOTE]
> `DevRevMonitoredApp` is particularly useful when you want to avoid capturing snapshots during screen navigations, especially if any glitches occur. However, in most cases, this won't be necessary, as most of masking scenarios are not affected by standard navigation. This is an optional solution for enhanced control over session recording behavior.

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

When using `DevRevMonitoredApp.router` with GoRouter, you should add `DevRevTransitionTrackingObserver` to GoRouter's `observers` list to ensure proper transition tracking:

```dart
final router = GoRouter(
  routes: [...],
  observers: [DevRevTransitionTrackingObserver()],
);
```

#### Timers

The DevRev SDK offers a timer mechanism to measure the time spent on specific tasks, allowing you to track events such as response time, loading time, or any other duration-based metrics.

The mechanism uses balanced start and stop methods, both of which accept a timer name and an optional dictionary of properties.

To start a timer, use the following method:

```dart
DevRev.startTimer(name, properties);
```

To stop a timer, use the following method:

```dart
DevRev.endTimer(name, properties);
```

For example:

```dart
DevRev.startTimer("response-time", {"id": "task-1337"});

// Perform the task that you want to measure.

DevRev.endTimer("response-time", {"id": "task-1337"});
```

#### User interaction tracking

The DevRev SDK automatically tracks user interactions such as taps, swipes, and scrolls. However, in some cases you may want to disable this tracking to prevent sensitive user actions from being recorded.

To **temporarily disable** user interaction tracking, use the following method:

```dart
DevRev.pauseUserInteractionTracking()
```

To **resume** user interaction tracking, use the following method:

```dart
DevRev.resumeUserInteractionTracking()
```

#### Capture errors

You can report a handled error from a catch block using the `captureError` function.

This ensures that even if the error is handled in your app, it will still be logged for diagnostics.

```dart
DevRev.captureError(
  error,
  tag,
)
```

**Example:**

```dart
try {
} catch (e) {
  DevRev.captureError(
    e,
    'network-failure',
  );
}
```

**Example with Exception:**

```dart
try {
  throw Exception('Something went wrong');
} catch (e) {
  DevRev.captureError(e, 'custom-error');
}
```

#### Track screens

The DevRev SDK offers automatic screen tracking to help you understand how users navigate through your app. Although screens are automatically tracked, you can manually track screens using the following method:

```dart
DevRev.trackScreenName(screenName);
```

For example:

```dart
DevRev.trackScreenName("profile-screen");
```

#### Manage screen transitions (Android only)

The DevRev SDK allows tracking of screen transitions to understand the user navigation within your app.
You can manually update the state using the following methods:

```dart
// Mark the transition as started.
DevRev.setInScreenTransitioning(true);

// Mark the transition as ended.
DevRev.setInScreenTransitioning(false);
```

### Push notifications
You can configure your app to receive push notifications from the DevRev SDK. The SDK is able to handle push notifications and execute actions based on the notification's content.

The DevRev backend sends push notifications to your app to notify users about new messages in the support chat.

#### Configuration

To receive push notifications, you need to configure your DevRev organization by following the instructions in the [push notifications](https://developer.devrev.ai/sdks/mobile/push-notifications) section.

#### Register for push notifications

> [!NOTE]
> Push notifications require that the SDK has been configured and the user has been identified, to ensure delivery to the correct user.

The DevRev SDK offers a method to register your device for receiving push notifications. You can register for push notifications using the following method:

```dart
DevRev.registerDeviceToken(deviceToken, deviceID);
```

On Android devices, the `deviceToken` should be the Firebase Cloud Messaging (FCM) token value, while on iOS devices, it should be the Apple Push Notification service (APNs) token.

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

##### iOS

On iOS devices, you must pass the received push notification payload to the DevRev SDK for processing. The SDK handles the notification and executes the necessary actions.

```dart
DevRev.processPushNotification(payload);
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
	 3. (Optional) If you have enabled Flutter's Swift Package Manager integration, open `ios/Runner.xcodeproj` in Xcode and set `Package dependencies -> FlutterGeneratedPluginSwiftPackage -> Package.swift` to use:
			```swift
			platforms: [
				.iOS("15.0")
			]
			```
	 4. Build and run the app.

4. Android app:
	 Open the `android` directory in Android Studio or run the following command.
	 ```sh
	 flutter run -d android
	 ```

## Troubleshooting

- **Issue**: Support chat doesn't show.
	**Solution**: Ensure you have correctly called one of the identification methods: `DevRev.identifyUnverifiedUser(...)` or `DevRev.identifyVerifiedUser(...)`.

- **Issue**: Not receiving push notifications.
	**Solution**: Ensure that your app is configured to receive push notifications and that your device is registered with the DevRev SDK.

### ProGuard (Android only)

When trying to build your app for Android with ProGuard enabled, refer to these common issues and their solutions.

> [!NOTE]
> You can always refer to the [Android ProGuard documentation](https://developer.android.com/topic/performance/app-optimization/enable-app-optimization#proguard) for more information.

- **Issue**: Missing class `com.google.android.play.core.splitcompat.SplitCompatApplication`.
  **Solution**: Add the following line to your `proguard-rules.pro` file:
  ```proguard
  -dontwarn com.google.android.play.core.**
  ```

- **Issue**: Missing class issue due to transitive Flutter dependencies.
  **Solution**: Add the following lines to your `proguard-rules.pro` file:
  ```proguard
  -keep class io.flutter.** { *; }
  -keep class io.flutter.plugins.** { *; }
  -keep class GeneratedPluginRegistrant { *; }
  ```

- **Issue**: Missing class `org.s1f4j.impl.StaticLoggerBinder`.
  **Solution**: Add the following line to your `proguard-rules.pro` file:
  ```proguard
  -dontwarn org.slf4j.impl.StaticLoggerBinder
  ```

## Migration guide
If you are migrating from the legacy UserExperior SDK to the new DevRev SDK, please refer to the [Migration Guide](./MIGRATION.md) for detailed instructions and feature equivalence.

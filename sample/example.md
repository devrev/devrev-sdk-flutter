# DevRev SDK for Flutter sample app

A sample app with use cases for the DevRev SDK for Flutter has been provided as a part of our [public repository](https://github.com/devrev/devrev-sdk-flutter). To set up and run the sample app:

1. Go to the `example` directory:
	 ```sh
	 cd example
	 flutter clean
	 rm -rf ios android web linux macos windows
	 flutter create --platforms=android,ios .
	 ```
2. Install the dependencies:
	 ```sh
	 flutter pub get
	 ```
3. To run the Android app open the `android` directory in Android Studio or run the following command:
	 ```sh
	 flutter run -d android
	 ```
4. To run the iOS app open the `ios/Runner.xcworkspace` in Xcode for running the iOS app or run the following command:
	 ```sh
	 flutter run -d ios
	 ```
	 Additional steps before running the app:
	 1. Change the minimum iOS deployment target version to `15.0`.
	 2. Go to the `ios` directory and perform `pod install --repo-update`.
	 3. Open `ios/Runner.xcodeproj` in Xcode and select `Package dependencies -> FlutterGeneratedPluginSwiftPackage -> Package.swift` set iOS version from `12` to `15`.
		```swift
		platforms: [
				.iOS("15.0")
		]
		```
	 4. Perform `File -> Packages -> Resolve package versions`.
	 5. Build and run the app.

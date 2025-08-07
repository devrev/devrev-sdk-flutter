
# Migration guide

This guide helps you transition from the legacy UserExperior SDK to the new DevRev SDK in your Flutter application. Below is a feature equivalence chart and detailed instructions for migrating.

## Feature equivalence chart

| Feature | UserExperior SDK | DevRev SDK |
|-|-|-|
| Installation | `user_experior: ^<version>` | `devrev_sdk_flutter: ^<version>` |
| Initialization | `userExperior.startRecording(appID)` | `DevRev.configure(appID)` |
| User identification | `userExperior.setUserIdentifier(userIdentifier)` | `DevRev.identifyAnonymousUser(userID)`<br />`DevRev.identifyUnverifiedUser(userID, organizationID)`<br />`DevRev.identifyVerifiedUser(userID, sessionToken)`<br />`DevRev.logout(deviceID)` |
| Event tracking | `userExperior.logEvent(name)` | `DevRev.trackEvent(name, properties)` |
| Session recording | `userExperior.stopRecording()`<br />`userExperior.pauseRecording()`<br />`userExperior.resumeRecording()` | `DevRev.startRecording()`<br />`DevRev.stopRecording()`<br />`DevRev.pauseRecording()`<br />`DevRev.resumeRecording()`<br />`DevRev.processAllOnDemandSessions()` |
| Opting in/out | `userExperior.optOut()`<br />`userExperior.optIn()`<br />`userExperior.getOptOutStatus()` | `DevRev.stopAllMonitoring()`<br />`DevRev.resumeAllMonitoring()` |
| Session properties | `userExperior.setUserProperties(properties)` | `DevRev.addSessionProperties(properties)`<br />`DevRev.clearSessionProperties()` |
| Masking sensitive data | `UEMarker(child: TextField(controller: provider.fieldController, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),)` | `DevRevMask(child: TextField(decoration: InputDecoration(labelText: "foo-bar"),),)`<br />`DevRevUnmask(child: TextField(decoration: InputDecoration(labelText: "foo-bar"),),)` |
| Timers | `userExperior.startTimer(timerName, properties)`<br />`userExperior.endTimer(timerName, properties)` | `DevRev.startTimer(name, properties)`<br />`DevRev.endTimer(name, properties)` |
| PLuG support chat | Not supported. | `DevRev.showSupport()`<br /> `DevRev.createSupportConversation()` |
| Push notifications | Not supported. | `DevRev.registerDeviceToken(deviceID, deviceToken)`<br />`DevRev.unregisterDevice(deviceID)` |

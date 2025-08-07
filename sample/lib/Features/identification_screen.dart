import 'package:devrev_sdk_flutter/devrev.dart';
import 'package:flutter/material.dart';
import '../Components/alert.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import '../Components/StatusListItem.dart';
import '../device_info_fetcher.dart';

class IdentificationScreen extends StatefulWidget {
  @override
  _IdentificationScreenState createState() => _IdentificationScreenState();
}

class _IdentificationScreenState extends State<IdentificationScreen> {
  final TextEditingController unverifiedUserIDController = TextEditingController();
  final TextEditingController verifiedUserIDController = TextEditingController();
  final TextEditingController sessionTokenController = TextEditingController();
  final TextEditingController updateEmailController = TextEditingController();

  bool isUserIdentified = false;
  String? currentUserID;
  final _deviceInfoFetcher = DeviceInfoFetcher();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      isUserIdentified = (await DevRev.isUserIdentified)!;
    } on PlatformException catch (e) {
      developer.log("Failed to configure DevRev SDK", error: e);
    }

    if (!mounted) return;
    setState(() {});

    unverifiedUserIDController.clear();
    verifiedUserIDController.clear();
    sessionTokenController.clear();
    updateEmailController.clear();
  }

  Map<String, List<Map<String, dynamic>>> getIdentificationMenuItems(BuildContext context) {
    return {
      "Status": [
        {
          "type": "status",
          "title": "Is the user identified?",
          "status": isUserIdentified
        },
      ],
      "Unverified User": [
        {
          "type": "input",
          "title": "User ID Input",
          "widget": DevRevMask(
              child: TextField(
              controller: unverifiedUserIDController,
              decoration: InputDecoration(labelText: "User ID"),
            )
          ),
        },
        {
          "type": "action",
          "title": "Identify User",
          "action": () => identifyUnverifiedUser(context),
        },
      ],
      "Verified User": [
        {
          "type": "input",
          "title": "User ID Input",
          "widget": DevRevMask(
              child: TextField(
              controller: verifiedUserIDController,
              decoration: InputDecoration(labelText: "User ID"),
            )
          ),
        },
        {
          "type": "input",
          "title": "Session Token Input",
          "widget": DevRevMask(
              child: TextField(
              controller: sessionTokenController,
              decoration: InputDecoration(labelText: "Session Token"),
            )
          ),
        },
        {
          "type": "action",
          "title": "Verify User",
          "action": () => verifyUser(context),
        },
      ],
      "Update User": [
        {
          "type": "input",
          "title": "New Email",
          "widget": DevRevMask(
              child: TextField(
              controller: updateEmailController,
              decoration: InputDecoration(labelText: "Email"),
            )
          ),
        },
        {
          "type": "action",
          "title": "Update User",
          "action": () => updateUser(context),
        },
      ],
      "Logout": [
        {
          "type": "action",
          "title": "Logout",
          "action": () => logout(context),
        },
      ],
    };
  }

  void identifyUnverifiedUser(BuildContext context) {
    String userID = unverifiedUserIDController.text;
    DevRev.identifyUnverifiedUser(userID, null);
    if (userID.isNotEmpty) {
      currentUserID = userID;
      AlertDialogHelper.showAlertDialog(context, "User Identified", "User identified successfully as unverified.");
    } else {
      AlertDialogHelper.showAlertDialog(context, "Input Error", "Please enter a valid User ID.");
    }
  }

  void verifyUser(BuildContext context) {
    String userID = verifiedUserIDController.text;
    String sessionToken = sessionTokenController.text;
    DevRev.identifyVerifiedUser(userID, sessionToken);
    if (userID.isNotEmpty && sessionToken.isNotEmpty) {
      currentUserID = userID;
      AlertDialogHelper.showAlertDialog(context, "User Verified", "User verified successfully.");
    } else {
      AlertDialogHelper.showAlertDialog(context, "Input Error", "Please enter a valid User ID and Session Token.");
    }
  }

  void updateUser(BuildContext context) {
    String email = updateEmailController.text;

    if (email.isNotEmpty && currentUserID != null) {
      DevRev.updateUser({
        'userRef': currentUserID,
        'userTraits': {
          'email': email,
          'displayName': null,
          'fullName': null,
          'userDescription': null,
          'phoneNumbers': null,
          'customFields': null
        }
      });
      AlertDialogHelper.showAlertDialog(context, "User Updated", "User email updated successfully.");
    } else if (currentUserID == null) {
      AlertDialogHelper.showAlertDialog(context, "Error", "Please identify or verify a user first.");
    } else {
      AlertDialogHelper.showAlertDialog(context, "Input Error", "Please enter a valid email.");
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _deviceInfoFetcher.logout();
      AlertDialogHelper.showAlertDialog(context, "Logout", "The user has been logged out.");
    } catch (error) {
      AlertDialogHelper.showAlertDialog(context, "Error", "Failed to log out. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = getIdentificationMenuItems(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Identification"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                initPlatformState();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, sectionIndex) {
          final sectionTitle = menuItems.keys.elementAt(sectionIndex);
          final items = menuItems[sectionTitle]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               ListTile(
                title: Text(sectionTitle, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...items.map<Widget>((item) {
                if (item["type"] == "input") {
                  return ListTile(
                    title: item["widget"] as Widget,
                  );
                } else if (item["type"] == "action") {
                  return ListTile(
                    title: Text(item["title"]),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: item["action"],
                  );
                } else if (item["type"] == "status") {
                  return StatusListItem(title: item["title"], status: item["status"]);
                } else {
                  return Container();
                }
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}

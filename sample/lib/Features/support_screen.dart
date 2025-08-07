import 'package:flutter/material.dart';
import 'package:devrev_sdk_flutter/devrev.dart';

class SupportScreen extends StatefulWidget {
  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {

  @override
  void initState() {
    super.initState();
  }

  void initPlatformState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> supportMenuItems() {
    return [
      {"title": "Support Chat", "action": () => DevRev.createSupportConversation()},
      {"title": "Support View", "action": () => DevRev.showSupport()},
    ];
  }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support"),
        actions: [
          IconButton(
            onPressed: initPlatformState,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        children: supportMenuItems().map((item) {
          return ListTile(
            title: Text(item["title"]),
            onTap: () => item["action"](),
          );
        }).toList(),
      ),
    );
  }
}

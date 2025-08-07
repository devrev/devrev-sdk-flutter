import 'package:flutter/material.dart';
import 'package:devrev_sdk_flutter/devrev.dart';

class DelayedScreen extends StatefulWidget {
  const DelayedScreen({Key? key}) : super(key: key);

  @override
  _DelayedScreenState createState() => _DelayedScreenState();
}

class _DelayedScreenState extends State<DelayedScreen> {
  @override
  void initState() {
    super.initState();
    // Set transitioning state to false when screen is mounted
    DevRev.setInScreenTransitioning(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delayed Screen"),
      ),
      body: const Center(
        child: Text(
          "This screen opened after a 2 seconds delay",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

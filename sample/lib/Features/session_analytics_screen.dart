import 'package:flutter/material.dart';
import 'package:devrev_sdk_flutter/devrev.dart';
import '../Components/alert.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'delayed_screen.dart';

class SessionAnalyticsScreen extends StatefulWidget {
  @override
  _SessionAnalyticsState createState() => _SessionAnalyticsState();
}
class _SessionAnalyticsState extends State<SessionAnalyticsScreen> {
  bool areOnDemandSessionsEnabled = false;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    DevRev.addSessionProperties({
        'user_id': 'user_123'
      });
    DevRev.trackScreenName("session-analytics");
  }

  Future<void> initPlatformState() async {
    try {
      areOnDemandSessionsEnabled = (await DevRev.areOnDemandSessionsEnabled)!;
      isRecording = (await DevRev.isRecording)!;
    } on PlatformException catch (e) {
      developer.log("Failed to configure DevRev SDK", error: e);
    }

    if (!mounted) return;
    setState(() {});
  }

  Map<String, List<Map<String, dynamic>>> getSessionItems(BuildContext context) {
    final items = {
      "Status": [
        {"title": "Are on-demand sessions enabled?", "status": areOnDemandSessionsEnabled},
        {"title": "Is the session recorded?", "status": isRecording},
      ],
      "Session Monitoring": [
        {
          "title": "Stop All Monitoring",
          "action": () {
            DevRev.stopAllMonitoring();
            AlertDialogHelper.showAlertDialog(context, "Monitoring", "Stopped all monitoring.");
          }
        },
        {
          "title": "Resume Monitoring",
          "action": () {
            DevRev.resumeAllMonitoring();
            AlertDialogHelper.showAlertDialog(context, "Monitoring", "Resumed monitoring.");
          }
        },
      ],
      "Session Recording": [
        {
          "title": "Start Recording",
          "action": () {
            DevRev.startRecording();
            AlertDialogHelper.showAlertDialog(context, "Recording", "Recording started.");
          }
        },
        {
          "title": "Stop Recording",
          "action": () {
            DevRev.stopRecording();
            AlertDialogHelper.showAlertDialog(context, "Recording", "Recording stopped.");
          }
        },
        {
          "title": "Pause Recording",
          "action": () {
            DevRev.pauseRecording();
            AlertDialogHelper.showAlertDialog(context, "Recording", "Recording paused.");
          }
        },
        {
          "title": "Resume Recording",
          "action": () {
            DevRev.resumeRecording();
            AlertDialogHelper.showAlertDialog(context, "Recording", "Recording resumed.");
          }
        },
      ],
      "Timer": [
        {
          "title": "Start Timer",
          "action": () {
            DevRev.startTimer("sample-timer", {
              'action': 'start',
            });
            AlertDialogHelper.showAlertDialog(context, "Timer", "Timer started.");
          }
        },
        {
          "title": "End Timer",
          "action": () {
            DevRev.endTimer("sample-timer", {
              'action': 'end',
            });
            AlertDialogHelper.showAlertDialog(context, "Timer", "Timer ended.");
          }
        },
      ],
      "Manual Masking / Unmasking": [
        {
          "type": "masked_text",
          "title": "Manually Masked UI Item",
          "widget": DevRevMask(
            child: Text(
              "Manually Masked Item",
              style: TextStyle(fontSize: 16),
            ),
          ),
        },
        {
          "type": "input",
          "title": "Manually Unmasked UI Item",
          "widget": DevRevUnmask(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Manually Unmasked Item",
                border: OutlineInputBorder(),
              ),
            ),
          ),
        },
      ],
      "On-Demand Session": [
        {
          "title": "Process All Demand Sessions",
          "action": () {
            DevRev.processAllOnDemandSessions();
            AlertDialogHelper.showAlertDialog(context, "On-Demand Session", "Processing all demand sessions.");
          }
        },
      ],
    };

    if (Platform.isAndroid) {
      items["Delayed Screen"] = [
        {
          "title": "Navigate to Delayed Screen",
          "action": () async {
            // Set transitioning state to true before navigation
            await DevRev.setInScreenTransitioning(true);

            // Wait for 2 seconds
            await Future.delayed(Duration(seconds: 2));

            // Navigate to delayed screen
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DelayedScreen()),
              );
            }
          }
        },
      ];
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = getSessionItems(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Session Analytics"),
        actions: [
          IconButton(
            onPressed: () => initPlatformState(),
            icon: const Icon(Icons.refresh),
          ),
        ],
        ),
      body: ListView(
        children: items.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...entry.value.map((item) {
                if (entry.key == "Status") {
                  return ListTile(
                    title: Text(item["title"]),
                    trailing: Icon(
                      item["status"] ? Icons.check_circle : Icons.circle_outlined,
                    ),
                  );
                } else if (item["type"] == "masked_text" || item["type"] == "input") {
                  return ListTile(
                    title: item["widget"] as Widget,
                  );
                } else {
                  return ListTile(
                    title: Text(item["title"]),
                    onTap: () {
                      item["action"]();
                    },
                  );
                }
              }).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }
}

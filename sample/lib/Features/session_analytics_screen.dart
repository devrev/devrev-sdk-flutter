import 'package:flutter/material.dart';
import 'package:devrev_sdk_flutter/devrev.dart';
import '../Components/alert.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'delayed_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'camera_screen.dart';
import 'gallery_screen.dart';
import 'qr_scanner_screen.dart';
import 'live_chart_screen.dart';
import 'ui_heavy_screen.dart';

class SessionAnalyticsScreen extends StatefulWidget {
  const SessionAnalyticsScreen({super.key});

  @override
  SessionAnalyticsState createState() => SessionAnalyticsState();
}

class SessionAnalyticsState extends State<SessionAnalyticsScreen> {
  bool areOnDemandSessionsEnabled = false;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    DevRev.addSessionProperties({'user_id': 'user_123'});
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

  Map<String, List<Map<String, dynamic>>> getSessionItems(
    BuildContext context,
  ) {
    final Map<String, List<Map<String, dynamic>>> items = {
      "Status": [
        {
          "title": "Are on-demand sessions enabled?",
          "status": areOnDemandSessionsEnabled,
        },
        {"title": "Is the session recorded?", "status": isRecording},
      ],
      "Session Monitoring": [
        {
          "title": "Stop All Monitoring",
          "action": () {
            DevRev.stopAllMonitoring();
            AlertDialogHelper.showAlertDialog(
              context,
              "Monitoring",
              "Stopped all monitoring.",
            );
          },
        },
        {
          "title": "Resume Monitoring",
          "action": () {
            DevRev.resumeAllMonitoring();
            AlertDialogHelper.showAlertDialog(
              context,
              "Monitoring",
              "Resumed monitoring.",
            );
          },
        },
      ],
      "Session Recording": [
        {
          "title": "Start Recording",
          "action": () {
            DevRev.startRecording();
            AlertDialogHelper.showAlertDialog(
              context,
              "Recording",
              "Recording started.",
            );
          },
        },
        {
          "title": "Stop Recording",
          "action": () {
            DevRev.stopRecording();
            AlertDialogHelper.showAlertDialog(
              context,
              "Recording",
              "Recording stopped.",
            );
          },
        },
        {
          "title": "Pause Recording",
          "action": () {
            DevRev.pauseRecording();
            AlertDialogHelper.showAlertDialog(
              context,
              "Recording",
              "Recording paused.",
            );
          },
        },
        {
          "title": "Resume Recording",
          "action": () {
            DevRev.resumeRecording();
            AlertDialogHelper.showAlertDialog(
              context,
              "Recording",
              "Recording resumed.",
            );
          },
        },
        {
          "title": "Pause User Interaction Tracking",
          "action": () {
            DevRev.pauseUserInteractionTracking();
            AlertDialogHelper.showAlertDialog(
              context,
              "User Interaction Tracking",
              "User interaction tracking paused.",
            );
          },
        },
        {
          "title": "Resume User Interaction Tracking",
          "action": () {
            DevRev.resumeUserInteractionTracking();
            AlertDialogHelper.showAlertDialog(
              context,
              "User Interaction Tracking",
              "User interaction tracking has resumed.",
            );
          },
        },
      ],
      "Media": [
        {
          "title": "Camera",
          "action": () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CameraScreen(),
              ),
            );
          },
        },
        {
          "title": "Gallery",
          "action": () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GalleryScreen(),
              ),
            );
          },
        },
        {
          "title": "QR Scanner",
          "action": () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QrScannerScreen(),
              ),
            );
          }
        },
      ],
      "Heavy UI": [
        {
          "title": "Complex UI with Animations",
          "action": () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HeavyUIView(),
              ),
            );
          }
        },
        {
          "title": "Real Time UI",
          "action": () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RealTimeUpdatesScreen(),
              ),
            );
          },
        },
      ],
      "Timer": [
        {
          "title": "Start Timer",
          "action": () {
            DevRev.startTimer("sample-timer", {'action': 'start'});
            AlertDialogHelper.showAlertDialog(
              context,
              "Timer",
              "Timer started.",
            );
          },
        },
        {
          "title": "End Timer",
          "action": () {
            DevRev.endTimer("sample-timer", {'action': 'end'});
            AlertDialogHelper.showAlertDialog(context, "Timer", "Timer ended.");
          },
        },
      ],
      "Manual Masking / Unmasking": [
        {
          "type": "masked_text",
          "title": "Manually Masked UI Item",
          "widget": DevRevMask(
            child: const Text("Manually Masked Item",
                style: TextStyle(fontSize: 16)),
          ),
        },
        {
          "type": "input",
          "title": "Manually Unmasked UI Item",
          "widget": DevRevUnmask(
            child: const TextField(
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
            AlertDialogHelper.showAlertDialog(
              context,
              "On-Demand Session",
              "Processing all demand sessions.",
            );
          },
        },
      ],
      "Views": [
        {
          "title": "Open Web View",
          "action": () {
            _openWebView(context);
          },
        },
        {
          "title": "Open Surface View",
          "action": () {
            _openNativeView(context, "native-surface-view", "Surface View");
          },
        },
        {
          "title": "Open Texture View",
          "action": () {
            _openNativeView(context, "native-texture-view", "Texture View");
          },
        },
        {
          "title": "Open V2 Embedding FlutterView",
          "action": () {
            _openNativeView(
              context,
              "v2-embedding-view",
              "V2 Embedding FlutterView",
            );
          },
        },
        {
          "title": "Open Video View",
          "action": () {
            _openNativeView(context, "native-video-view", "Video View");
          },
        },
      ],
      "Large Scrollable List": [
        {
          "title": "Open Large Scrollable List",
          "action": () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ListViewScreen(itemCount: 100),
              ),
            );
          },
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
            await Future.delayed(const Duration(seconds: 2));

            // Navigate to delayed screen
            if (mounted) {
              Navigator.push(
                this.context,
                MaterialPageRoute(builder: (context) => const DelayedScreen()),
              );
            }
          },
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
                title: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...entry.value.map((item) {
                if (entry.key == "Status") {
                  return ListTile(
                    title: Text(item["title"]),
                    trailing: Icon(
                      item["status"]
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                    ),
                  );
                } else if (item["type"] == "masked_text" ||
                    item["type"] == "input") {
                  return ListTile(title: item["widget"] as Widget);
                } else {
                  return ListTile(
                    title: Text(item["title"]),
                    onTap: () {
                      item["action"]();
                    },
                  );
                }
              }),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _openWebView(BuildContext context) {
    WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/sample.html'); // Load HTML from assets
    setState(() {}); // Trigger a rebuild once HTML is loaded

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text("WebView")),
          body: WebViewWidget(controller: controller),
        ),
      ),
    );
  }

  void _openNativeView(BuildContext context, String viewType, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(
            child: SizedBox(
              height: 300,
              width: 300,
              child: AndroidView(viewType: viewType),
            ),
          ),
        ),
      ),
    );
  }
}

class ListViewScreen extends StatelessWidget {
  final int itemCount;

  const ListViewScreen({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ListView Screen')),
      body: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          Widget listItem = ListTile(title: Text('Item #$index'));

          if (index % 2 == 0) {
            listItem = DevRevMask(child: listItem);
          }

          return Card(
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: listItem,
          );
        },
      ),
    );
  }
}

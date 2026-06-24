import 'dart:io' show Platform;
import 'dart:async';
import 'dart:developer' as developer;
import 'package:devrev_sdk_flutter_sample/Utilities/app_constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:devrev_sdk_flutter/devrev.dart';
import 'package:devrev_sdk_flutter/devrev_monitored_app.dart';
import 'package:go_router/go_router.dart';
import 'Features/identification_screen.dart';
import 'Features/masked_form_screen.dart';
import 'Features/unmasked_form_screen.dart';
import 'Features/payment_details_form_screen.dart';
import 'Features/account_security_form_screen.dart';
import 'Features/pushnotifications_screen.dart';
import 'Features/router_navigation_screen.dart';
import 'Features/session_analytics_screen.dart';
import 'Features/support_screen.dart';
import 'Components/status_list_item.dart';

final _router = GoRouter(
  initialLocation: '/main',
  observers: [DevRevTransitionTrackingObserver()],
  routes: [
    GoRoute(
      path: '/main',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/router-navigation',
      builder: (context, state) => const RouterNavigationScreen(),
    ),
    GoRoute(
      path: '/masked-form/personal',
      builder: (context, state) => const MaskedFormScreen(),
    ),
    GoRoute(
      path: '/masked-form/contact',
      builder: (context, state) => const UnmaskedFormScreen(),
    ),
    GoRoute(
      path: '/masked-form/payment',
      builder: (context, state) => const PaymentDetailsFormScreen(),
    ),
    GoRoute(
      path: '/masked-form/security',
      builder: (context, state) => const AccountSecurityFormScreen(),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "<IOS_API_KEY>",
        appId: "<IOS_APP_ID>",
        messagingSenderId: "<MESSAGING_SENDER_ID>",
        projectId: "<PROJECT_ID>",
      ),
    );
  } else if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "<ANDROID_API_KEY>",
        appId: "<ANDROID_APP_ID>",
        messagingSenderId: "<MESSAGING_SENDER_ID>",
        projectId: "<PROJECT_ID>",
      ),
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DevRevMonitoredApp.router(
      title: "DevRev SDK",
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool isConfigured = false;
  bool isUserIdentified = false;
  bool isMonitoringEnabled = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _animationController.forward();
  }

  Future<void> initPlatformState() async {
    try {
      DevRev.configure(AppConstants.appID);
      isConfigured = (await DevRev.isConfigured)!;
      isUserIdentified = (await DevRev.isUserIdentified)!;
      isMonitoringEnabled = (await DevRev.isMonitoring)!;
    } on PlatformException catch (e) {
      developer.log("Failed to configure DevRev SDK", error: e);
    }

    if (!mounted) return;
    setState(() {});
  }

  void triggerANR() {
    if (Platform.isAndroid) {
      // Simulate ANR by running a long operation on the main thread
      Future.delayed(const Duration(seconds: 1), () {
        while (true) {
          // Infinite loop to cause ANR
          int i = 0;
          while (i < 1000000) {
            i++;
          }
          break;
        }
      });
    }
  }

  Map<String, List<Map<String, dynamic>>> getMenuItems() {
    return {
      "STATUS": [
        {"title": "Is the DevRev SDK configured?", "status": isConfigured},
        {"title": "Is the user identified?", "status": isUserIdentified},
        {
          "title": "Is session monitoring enabled?",
          "status": isMonitoringEnabled,
        },
      ],
      "FEATURES": [
        {"title": "Identification", "route": const IdentificationScreen()},
        {
          "title": "Push Notification",
          "route": const PushNotificationsScreen()
        },
        {"title": "Support", "route": const SupportScreen()},
        {"title": "Session Analytics", "route": const SessionAnalyticsScreen()},
        {
          "title": "Router Navigation",
          "routePath": "/router-navigation",
        },
      ],
      if (Platform.isAndroid)
        "DEBUG": [
          {"title": "Trigger ANR", "action": triggerANR},
        ],
      if (Platform.isAndroid)
        "ANIMATION": [
          {
            "type": "animated_text",
            "title": "Animated Text",
            "widget": ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTap: _startAnimation,
                child: const Text("Test Animation"),
              ),
            ),
          },
        ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final items = getMenuItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text("DevRev SDK"),
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
                if (entry.key == "STATUS") {
                  return StatusListItem.buildStatusListItem(
                    title: item["title"],
                    status: item["status"],
                  );
                } else if (entry.key == "DEBUG") {
                  return ListTile(
                    title: Text(item["title"]),
                    onTap: () => item["action"](),
                  );
                } else if (item["type"] == "animated_text") {
                  return ListTile(title: item["widget"] as Widget);
                } else if (item.containsKey("routePath")) {
                  return ListTile(
                    title: Text(item["title"]),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(item["routePath"] as String),
                  );
                } else {
                  return ListTile(
                    title: Text(item["title"]),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => item["route"],
                        ),
                      );
                    },
                  );
                }
              }),
              const SizedBox(height: 10),
            ],
          );
        }).toList(),
      ),
    );
  }
}

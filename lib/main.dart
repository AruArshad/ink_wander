import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ink_wander/screens/home_page.dart';
import 'package:ink_wander/services/foreground_provider.dart';
import 'package:ink_wander/services/theme_provider.dart';
import 'package:ink_wander/widgets/app_open_ad.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'package:ink_wander/screens/login.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Wait for preferences to initialize
  unawaited(MobileAds.instance.initialize());
  await Firebase.initializeApp(); // Initialize Firebase

  final prefs =
      await SharedPreferences.getInstance(); // Get SharedPreferences instance
  final isFirstLaunch =
      prefs.getBool('isFirstLaunch') ?? true; // Check for key or set default
  final isLoggedIn = await _isLoggedIn();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AppForegroundState()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ], child: MainApp(isFirstLaunch: isFirstLaunch, isLoggedIn: isLoggedIn)));
}

class MainApp extends StatefulWidget {
  final bool isFirstLaunch;
  final bool isLoggedIn;

  const MainApp(
      {super.key, required this.isFirstLaunch, required this.isLoggedIn});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    // Initialize prefs within initState using await
    SharedPreferences.getInstance().then((value) async {
      prefs = value;
      // Update isFirstLaunch only after prefs is initialized
      if (widget.isFirstLaunch) {
        await prefs.setBool('isFirstLaunch', false);
      }
    });
    AppOpenAdManager.loadAd();
    _listenForAppForegrounding();
  }

  void _listenForAppForegrounding() {
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message == AppLifecycleState.resumed.toString()) {
        Provider.of<AppForegroundState>(context, listen: false)
            .setIsForeground(true);
        AppOpenAdManager.showAdIfAvailable();
      } else {
        Provider.of<AppForegroundState>(context, listen: false)
            .setIsForeground(false);
      }
      debugPrint('AppLifecycleState: $message');
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Ink Wander',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: widget.isLoggedIn
          ? const HomePage() // Redirect to HomePage if logged in
          : widget.isFirstLaunch
              ? const OnboardingScreen()
              : const Login(),
      routes: {
        '/login': (context) => const Login(),
      },
    );
  }
}

Future<bool> _isLoggedIn() async {
  final user = FirebaseAuth.instance.currentUser;
  return user != null; // Check if a user is currently signed in
}

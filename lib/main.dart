import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ink_wander/utils/firebase_options.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ink_wander/screens/home_page.dart';
import 'package:ink_wander/services/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'package:ink_wander/screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.initialize().then((initializationStatus) {
  //   initializationStatus.adapterStatuses.forEach((key, value) {
  //     debugPrint('Adapter status for $key: ${value.description}');
  //   });
  // });

  // Set a wait timer
  //   return Future.delayed(const Duration(seconds: 5)); // Wait for 5 seconds
  // }).then((_) {
  //   // After the delay, open the Ad Inspector
  //   MobileAds.instance.openAdInspector((dynamic error) {
  //     if (error != null) {
  //       // Handle the error here
  //       debugPrint('Ad Inspector Error: ${error.toString()}');
  //     } else {
  //       // Ad Inspector opened successfully
  //       debugPrint('Ad Inspector opened successfully');
  //     }
  //   });
  // });
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase

  final prefs =
      await SharedPreferences.getInstance(); // Get SharedPreferences instance
  final isFirstLaunch =
      prefs.getBool('isFirstLaunch') ?? true; // Check for key or set default
  final isLoggedIn = await _isLoggedIn();

  runApp(MultiProvider(providers: [
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

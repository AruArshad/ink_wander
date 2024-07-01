import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'package:ink_wander/screens/login.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Wait for preferences to initialize
  final prefs = await SharedPreferences.getInstance(); // Get SharedPreferences instance
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true; // Check for key or set default

  runApp(MainApp(isFirstLaunch: isFirstLaunch)); // Pass isFirstLaunch to MyApp
}

class MainApp extends StatefulWidget {
  final bool isFirstLaunch;

  const MainApp({super.key, required this.isFirstLaunch});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final bool _isDarkMode = true;
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
    return MaterialApp(
      title: 'Ink Wander',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: widget.isFirstLaunch ? const OnboardingScreen() : const Login(),
      routes: {
        '/login': (context) => const Login(),
      },
    );
  }
}

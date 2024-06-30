import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'package:ink_wander/screens/login.dart';

void main() {
  runApp(const MainApp()); 
}


class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ink Wander',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ink Wander'),
          leading: IconButton(
            icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ),
        body: const OnboardingScreen(),
      ),
      routes: {
        '/login': (context) => const Login(),
      },
    );
  }
}

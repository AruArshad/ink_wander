import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ink_wander/res/custom_colors.dart';
import 'package:ink_wander/widgets/user_info_popup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _isDarkMode = true;

  void _showUserInfoPopup() {
    showDialog(
      context: context,
      builder: (context) => UserInfoPopup(user: FirebaseAuth.instance.currentUser!, isDarkMode: _isDarkMode), // Pass current user
    );
  }
     
  @override
  void initState() {
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    final Color backgroundColor = _isDarkMode ? Colors.black87 : Colors.white; // Dynamic background color
    final Color textColor = _isDarkMode ? Colors.white : Colors.black; // Dynamic text color for accessibility
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return; // Avoid unnecessary processing if pop wasn't attempted
        final shouldExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: backgroundColor,
            titleTextStyle: TextStyle(color: textColor, fontSize: 23, fontWeight: FontWeight.bold),
            contentTextStyle: TextStyle(color: textColor, fontSize: 19),
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit Ink Wander?'),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: textColor,
                ),
                onPressed: () => Navigator.pop(context, false), // Cancel exit
                child: const Text('Cancel', style: TextStyle(fontSize: 17),),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: textColor,
                ),
                onPressed: () => Navigator.pop(context, true), // Confirm exit
                child: const Text('Yes', style: TextStyle(fontSize: 17),),
              ),
            ],
          ),
        );
        if (shouldExit ?? false) {
          exitApp(); // Exit the app if confirmed
        }
      },
      child: Scaffold(
        backgroundColor: _isDarkMode ? CustomColors.firebaseNavy : Colors.white,
        appBar: AppBar(
        title: Text(
          'Ink Wander',
          style: TextStyle(color: textColor), // Use dynamic text color
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
          color: textColor,
          onPressed:() {
            setState(() {
              _isDarkMode = !_isDarkMode;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_2_rounded), // Replace with your desired icon
            color: textColor,
            onPressed: _showUserInfoPopup,
          ),
        ],
        backgroundColor: backgroundColor, // Use dynamic background color
        ),
        body: PopScope(
          canPop: false,
          child: SafeArea(
          child: _buildCenterText(), // Use the reusable widget
                ),
        ),
      ),
    );
  }

  Widget _buildCenterText() {
    return Center(
      child: Text(
        'Welcome to Ink Wander',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
}

void exitApp() async {
    // Implement app exit logic here (e.g., close connections, save data)
    Navigator.of(context).popUntil((route) => route.isFirst);
    SystemNavigator.pop(); // Explicitly pop app from system
}

}



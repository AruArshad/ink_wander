import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ink_wander/res/custom_colors.dart';
import 'package:ink_wander/widgets/user_info_popup.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key, required User user});

  @override
  UserInfoScreenState createState() => UserInfoScreenState();
}

class UserInfoScreenState extends State<UserInfoScreen> {
  // late User _user;
  // bool _isSigningOut = false;
  bool _isDarkMode = true;

  void _showUserInfoPopup() {
    showDialog(
      context: context,
      builder: (context) => UserInfoPopup(user: FirebaseAuth.instance.currentUser!, isDarkMode: _isDarkMode), // Pass current user
    );
  }
     
  @override
  void initState() {
    // _user = widget._user;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    final Color backgroundColor = _isDarkMode ? Colors.black87 : Colors.white; // Dynamic background color
    final Color textColor = _isDarkMode ? Colors.white : Colors.black; // Dynamic text color for accessibility
    
    return PopScope(
      canPop: false,
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
        body: SafeArea(
        child: _buildCenterText(), // Use the reusable widget
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
}



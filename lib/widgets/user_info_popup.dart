// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ink_wander/res/custom_colors.dart';
import 'package:ink_wander/screens/login.dart';
import 'package:ink_wander/screens/onboarding_screen.dart';
import 'package:ink_wander/utils/authentication.dart';

class UserInfoPopup extends StatefulWidget {
  const UserInfoPopup(
      {super.key, required this.user, required this.isDarkMode});

  final User user;
  final bool isDarkMode;

  @override
  State<UserInfoPopup> createState() => _UserInfoPopupState();
}

Route _routeToSignInScreen() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const Login(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(-1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class _UserInfoPopupState extends State<UserInfoPopup> {
  late User _user;
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    _user = widget.user;

    return Dialog(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User profile picture
            _user.photoURL != null
                ? ClipOval(
                    child: Material(
                      color: widget.isDarkMode
                          ? CustomColors.firebaseGrey.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                      child: Image.network(
                        _user.photoURL!,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  )
                : ClipOval(
                    child: Material(
                      color: widget.isDarkMode
                          ? CustomColors.firebaseGrey.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: CustomColors.firebaseGrey,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 16.0),

            // User information
            const SizedBox(height: 8.0),
            Text(
              _user.displayName!,
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black,
                fontSize: 26,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              _user.email!,
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    widget.isDarkMode
                        ? const Color.fromARGB(255, 43, 152, 196)
                        : const Color.fromARGB(255, 20, 233, 91),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OnboardingScreen()));
                },
                child: const Text(
                  "Show Onboarding Screen",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 15.0),
            // Sign out button
            _isSigningOut
                ? const CircularProgressIndicator() // Show progress indicator
                : ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        widget.isDarkMode ? Colors.redAccent : Colors.red,
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        _isSigningOut = true;
                      });
                      await Authentication.signOut(context: context);
                      setState(() {
                        _isSigningOut = false;
                      });
                      Navigator.of(context).push(_routeToSignInScreen());
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

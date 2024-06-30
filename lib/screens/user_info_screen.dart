import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ink_wander/res/custom_colors.dart';
import 'package:ink_wander/utils/authentication.dart';
import 'package:ink_wander/screens/login.dart';
import 'package:ink_wander/widgets/app_bar.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key, required User user})
      : _user = user;

  final User _user;

  @override
  UserInfoScreenState createState() => UserInfoScreenState();
}

class UserInfoScreenState extends State<UserInfoScreen> {
  late User _user;
  bool _isSigningOut = false;
   bool _isDarkMode = true;

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const Login(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? CustomColors.firebaseNavy : Colors.white,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight), // Adjust height if needed
          child: MyAppBar(
            isDarkMode: _isDarkMode,
            onToggleDarkMode: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
    
          ),
        ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(),
              _user.photoURL != null
                  ? ClipOval(
                      child: Material(
                        color: CustomColors.firebaseGrey.withOpacity(0.3),
                        child: Image.network(
                          _user.photoURL!,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    )
                  : ClipOval(
                      child: Material(
                        color: CustomColors.firebaseGrey.withOpacity(0.3),
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
              _isDarkMode ?
              const Text(
                'Hello',
                style: TextStyle(
                  color:  CustomColors.firebaseGrey,
                  fontSize: 26,
                ),
              ) :
              const Text(
                'Hello',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 8.0),
              _isDarkMode ?
              Text(
                _user.displayName!,
                style: const TextStyle(
                  color: CustomColors.firebaseYellow,
                  fontSize: 26,
                ),
              ) :
              Text(
                _user.displayName!,
                style: const TextStyle(
                  color: Color.fromARGB(255, 29, 185, 81),
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '( ${_user.email!} )',
                style: const TextStyle(
                  color: CustomColors.firebaseOrange,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24.0),
              _isDarkMode ?
              Text(
                'You are now signed in using your Google account. To sign out of your account, click the "Sign Out" button below.',
                style: TextStyle(
                    color: CustomColors.firebaseGrey.withOpacity(0.8),
                    fontSize: 14,
                    letterSpacing: 0.2),
              ) : 
              const Text(
                'You are now signed in using your Google account. To sign out of your account, click the "Sign Out" button below.',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    letterSpacing: 0.2),
              ),
              const SizedBox(height: 16.0),
              _isSigningOut
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Colors.redAccent,
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
                        // ignore: use_build_context_synchronously
                        Navigator.of(context)
                            .pushReplacement(_routeToSignInScreen());
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
      ),
    );
  }
}

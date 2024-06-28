import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'sign_up.dart'; // Ensure this is the correct path to your file

class SignInPage extends StatelessWidget {
  const SignInPage({super.key,});

  // Method to handle Google Sign-In and Firebase authentication
  // Future<UserCredential> signInWithGoogle() async {
  //   // Trigger the Google Sign-In process
  //   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  //   // Obtain the auth details from the request
  //   final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  //   // Create a new credential for Firebase authentication
  //   // final GoogleAuthCredential credential = GoogleAuthProvider.credential(
  //   //   accessToken: googleAuth?.accessToken,
  //   //   idToken: googleAuth?.idToken,
  //   // );

  //   // Sign in to Firebase with the Google user credentials
  //   // return await FirebaseAuth.instance.signInWithCredential(credential);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In'),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // ... TextFields for email and password ...
             Align(
              alignment: Alignment.center,
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2762634596.
              child:  ClipRRect(
                 borderRadius: BorderRadius.circular(20.0),
                child: const Image(  image: AssetImage('assets/images/signin.jpeg'), 
                                width: double.infinity, 
                                height: 400, 
                                fit: BoxFit.cover,	
                              ),
              ),
            ),

            const SizedBox(height: 30),

            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  // try {
                  //   await signInWithGoogle();
                  //   // Navigate to the next screen if sign-in is successful
                  // } catch (e) {
                  //   // Handle sign-in error
                  // }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  textStyle: const TextStyle(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Icon(Icons.login),
                     SizedBox(width: 10),
                     Text('Sign In with Google'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

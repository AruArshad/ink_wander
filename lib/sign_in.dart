import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'sign_up.dart'; // Ensure this is the correct path to your file

class SignInPage extends StatefulWidget {
  const SignInPage({super.key,});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  ValueNotifier userCredential = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In'),),
      body: ValueListenableBuilder(
        valueListenable: userCredential,
        builder: (context, value, child) {
          return (userCredential.value == '' ||
                  userCredential.value == null)
        ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // ... TextFields for email and password ...
               Align(
                alignment: Alignment.center,
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
                            userCredential.value = await signInWithGoogle();
                            if (userCredential.value != null) {
                              if (kDebugMode) {
                                print(userCredential.value.user!.email);
                              }
                            }
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
        )
        :  Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 1.5, color: Colors.black54)),
                            child: Image.network(
                                userCredential.value.user!.photoURL.toString()),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(userCredential.value.user!.displayName
                              .toString()),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(userCredential.value.user!.email.toString()),
                          const SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                bool result = await signOutFromGoogle();
                                if (result) userCredential.value = '';
                              },
                              child: const Text('Logout'))
                        ],
                      ),
                    );
        }
      ),
    );
  }
}

Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e) {
        if (kDebugMode) {
          print('exception->$e');
      }
    }
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

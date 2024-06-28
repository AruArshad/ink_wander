import 'package:flutter/material.dart';
// import 'sign_in.dart'; // Ensure this is the correct path to your file

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  // ... TextEditingControllers and other code ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // ... TextFields for email and password ...
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle sign-in logic
              },
              child: const Text('Sign Up'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signin');
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

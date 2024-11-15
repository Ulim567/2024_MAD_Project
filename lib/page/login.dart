import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shrine/auth/auth.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signInWithGoogle(context),
          child: const Text("Sign in with Google"),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      UserCredential userCredential = await authService.signInWithGoogle();
      User? user = userCredential.user;

      if (user != null) {
        print('Google Sign-In Successful: ${user.displayName}');
        // Navigator.pushNamed(context, "/");
      }
    } catch (error) {
      print('Error during Google sign-in: $error');
    }
  }
}

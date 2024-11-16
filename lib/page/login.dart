import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shrine/auth/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential =
                      await authService.signInWithGoogle();
                  User? user = userCredential.user;
                  if (user != null) {
                    print('Google Sign-In Successful: ${user.displayName}');
                    // Navigator.pushNamed(context, "/");
                  }
                } catch (error) {
                  print('Error during Google sign-in: $error');
                }
              },
              child: const Text("Sign in with Google"),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: const Text("go home(temp)"),
              onPressed: () => {
                Navigator.pushNamed(context, "/"),
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'authControl.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthControl authcontrol = AuthControl();

  @override
  void initState() {
    super.initState();
    if (authcontrol.auth.currentUser != null) {
      authcontrol.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 100,
              ),
              const Icon(
                Icons.account_circle_outlined,
                size: 75,
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                "로그인",
                style: TextStyle(fontSize: 28),
              ),
              Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.all(100),
                child: ElevatedButton(
                  onPressed: () async {
                    var signin = await authcontrol.signInWithGoogle();
                    if (signin != null) {
                      // await authcontrol.saveGoogleUserInfo();
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.account_circle),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Google Login"),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/map");
                },
                child: Text("MapTest"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

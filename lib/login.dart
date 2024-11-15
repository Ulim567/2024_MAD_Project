import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shrine/productprovider.dart';
import 'auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    // ProductProvider 인스턴스 가져오기
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset('assets/diamond.png'),
                const SizedBox(height: 16.0),
                const Text('SHRINE'),
              ],
            ),
            SizedBox(height: 120),

            // Google 로그인 버튼
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential =
                      await authService.signInWithGoogle();
                  User? user = userCredential.user;

                  if (user != null) {
                    // ProductProvider의 createUser 메서드 호출
                    await productProvider.createUser(
                      user.uid,
                      name: user.displayName,
                      email: user.email,
                    );
                    print('Google Sign-In Successful: ${user.displayName}');
                    Navigator.pushNamed(context, "/");
                  }
                } catch (error) {
                  print('Error during Google sign-in: $error');
                }
              },
              child: const Text("Sign in with Google"),
            ),

            // 익명 로그인 버튼
            ElevatedButton(
              onPressed: () async {
                try {
                  User? user = await authService.signInAnonymously();
                  if (user != null) {
                    // ProductProvider의 createUser 메서드 호출
                    await productProvider.createUser(user.uid);
                    print('Anonymous Sign-In Successful: ${user.uid}');
                    Navigator.pushNamed(context, "/");
                  }
                } catch (error) {
                  print('Error during anonymous sign-in: $error');
                }
              },
              child: const Text("Sign in Anonymously"),
            ),
          ],
        ),
      ),
    );
  }
}

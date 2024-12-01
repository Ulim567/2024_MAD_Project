import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moblie_app_project/provider/dbservice.dart';
import 'package:provider/provider.dart';

import 'authControl.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthControl authControl = AuthControl();

  @override
  void initState() {
    super.initState();
    // 사용자가 이미 로그인 상태라면, 자동으로 로그아웃 시킴.
    if (authControl.auth.currentUser != null) {
      authControl.logout();
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
                    var signin = await authControl.signInWithGoogle();
                    if (signin != null) {
                      final User? user = FirebaseAuth.instance.currentUser;

                      if (user == null) {
                        // 사용자 정보가 없을 경우 처리
                        print("No user is currently signed in.");
                        return;
                      }

                      final String name = user.displayName ?? 'none';
                      final String uid = user.uid;
                      final String email = user.email ?? 'email not found';

                      try {
                        // Firestore에 사용자 데이터 저장
                        await _saveUserDataToFirestore(uid, email, name);

                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                              context,
                              "/",
                              (Route<dynamic> route) =>
                                  false); // 데이터 저장 성공 후 화면 닫기
                        }
                      } catch (e) {
                        print("Error saving user data: $e");

                        // 실패 시 사용자 알림 (예: SnackBar)
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text("사용자 데이터를 저장할 수 없습니다. 다시 시도해 주세요.")),
                          );
                        }
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
                child: const Text("Map Test"),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Firestore에 사용자 데이터를 저장하는 함수
  Future<void> _saveUserDataToFirestore(
      String uid, String email, String name) async {
    await Provider.of<DatabaseService>(context, listen: false)
        .saveUserData(uid, email, name);
  }
}

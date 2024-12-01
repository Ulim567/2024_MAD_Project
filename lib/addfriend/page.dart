import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moblie_app_project/addfriend/widgets/add.dart';
import 'package:moblie_app_project/addfriend/widgets/confirm.dart';
import 'package:moblie_app_project/provider/dbservice.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final databaseService = DatabaseService();
  int index = 0;
  List<Widget> pages = [];
  String appBarTitle = "친구추가";

  String? verifiedCode; // 확인된 코드 저장

  @override
  Widget build(BuildContext context) {
    pages = [
      AddCodeWidget(
        onCodeVerified: (code) {
          setState(() {
            verifiedCode = code;
          });
        },
      ),
      ProfileConfirmWidget(
        code: verifiedCode, // 확인된 코드 전달
      ),
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pages[index],
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      if (index == 0) {
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          verifiedCode = null;
                          index--;
                        });
                      }
                    },
                    child: const Text("취소"),
                  ),
                  ElevatedButton(
                    onPressed: verifiedCode != null || index > 0
                        ? () async {
                            if (index == pages.length - 1) {
                              final FirebaseAuth _auth = FirebaseAuth.instance;
                              final User? user = _auth.currentUser;
                              if (user != null) {
                                await databaseService.sendFriendRequest(
                                    verifiedCode!, user.uid);
                                print("친구추가 전송 완료: $verifiedCode");
                                index++;
                              }
                            } else {
                              setState(() {
                                index++;
                              });
                            }
                          }
                        : null, // 코드 확인 전에는 비활성화
                    child: (index == pages.length - 1)
                        ? const Text("확인")
                        : const Text("다음"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

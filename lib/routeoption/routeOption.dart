import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moblie_app_project/provider/defaultState.dart';
import 'package:provider/provider.dart';

import 'widgets/confirmRouteWidget.dart';
import 'widgets/selectTimeWidget.dart';
import 'widgets/selectFriendWidget.dart';
import 'widgets/finalConfirmWidget.dart';
import '../provider/dbservice.dart';

class RouteOptionPage extends StatefulWidget {
  const RouteOptionPage({super.key});

  @override
  State<RouteOptionPage> createState() => _RouteOptionPageState();
}

class _RouteOptionPageState extends State<RouteOptionPage> {
  final DatabaseService _databaseService = DatabaseService();
  int index = 0;
  List<Widget> pages = [];

  String appBarTitle = "";

  @override
  void initState() {
    super.initState();
    pages = [
      const ConfirmRouteWidget(),
      const SelectTimeWidget(),
      const SelectFriendWidget(),
      const FinalconfirmWidget(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Text(
            '사용자가 로그인되지 않았습니다.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
    final String uid = user.uid;
    var defaultState = context.watch<Defaultstate>();

    if (index == 0) {
      appBarTitle = "위치 확인";
    } else if (index == 1) {
      appBarTitle = "타이머 설정";
    } else if (index == 2) {
      appBarTitle = "친구 설정";
    } else if (index == 3) {
      appBarTitle = "최종 확인";
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            defaultState.resetState();
            Navigator.pop(context);
          },
        ),
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
                            index--;
                          });
                        }
                      },
                      child: const Text("뒤로")),
                  ElevatedButton(
                      onPressed: () async {
                        if (index == pages.length - 1) {
                          await _databaseService.sendTrackingInfo(
                              uid,
                              defaultState.selectedFriends,
                              defaultState.name,
                              defaultState.address,
                              defaultState.latitude,
                              defaultState.longitude,
                              Timestamp.fromDate(defaultState.selectedTime),
                              []);

                          defaultState.resetState();
                          Navigator.pushNamed(context, '/tracking');
                        } else {
                          setState(() {
                            index++;
                          });
                        }
                      },
                      child: (index == pages.length - 1)
                          ? const Text("시작하기")
                          : const Text("다음"))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// class AlreadyTrackingPage extends StatelessWidget {
//   const AlreadyTrackingPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Center(
//         child: Column(
//           children: [
//             const SizedBox(
//               height: 60,
//             ),
//             const Icon(
//               Icons.warning_amber_rounded,
//               size: 50,
//             ),
//             const SizedBox(
//               height: 25,
//             ),
//             const Text(
//               "이미 진행 중인 귀가 정보가 있습니다.\n계속 진행하시려면\n해당 귀가를 종료해주세요.",
//               style: TextStyle(fontSize: 20),
//             ),
//             Expanded(child: Container()),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(70, 0, 70, 10),
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         // Navigator.pushNamed(context, '/tracking');
//                       },
//                       style: ElevatedButton.styleFrom(
//                           minimumSize: const Size.fromHeight(50)),
//                       child: const Text("귀가 화면으로 가기"),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(70, 0, 70, 45),
//                     child: OutlinedButton(
//                       onPressed: () {
//                         Navigator.pushNamedAndRemoveUntil(
//                             context, "/", (Route<dynamic> route) => false);
//                       },
//                       style: OutlinedButton.styleFrom(
//                           minimumSize: const Size.fromHeight(50)),
//                       child: const Text("홈 화면으로 돌아가기"),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

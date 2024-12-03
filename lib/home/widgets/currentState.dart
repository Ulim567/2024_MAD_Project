import 'package:auto_size_text_plus/auto_size_text_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../provider/dbservice.dart';

class CurrentStatePage extends StatefulWidget {
  const CurrentStatePage({super.key});

  @override
  State<CurrentStatePage> createState() => _CurrentStatePageState();
}

class _CurrentStatePageState extends State<CurrentStatePage> {
  final DatabaseService _databaseService = DatabaseService();

  Widget stateInfoCard(String name, String locationDetail, String location) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 15, 15, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 4, 8, 0),
            child: Icon(
              Icons.location_on,
              size: 30,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  name,
                  style: const TextStyle(fontSize: 20),
                  maxLines: 1,
                  minFontSize: 18,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 4,
                ),
                AutoSizeText(
                  locationDetail,
                  maxLines: 1,
                  minFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
                AutoSizeText(
                  location,
                  maxLines: 1,
                  minFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () {}, child: const Text("확인하기")),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ));
  }

  bool isButtonDisabled = false;
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            '사용자가 로그인되지 않았습니다.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
    final String uid = user.uid;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.today,
                    size: 30,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "귀가 현황",
                    style: TextStyle(fontSize: 24),
                  ),
                  Expanded(child: Container()),
                  FutureBuilder<bool>(
                      future: _databaseService.isTrackingNow(uid),
                      builder: (context, snapshot) {
                        final bool isTracking = snapshot.data ?? false;

                        return IconButton(
                          onPressed: () {
                            if (isTracking) {
                              Navigator.pushNamed(context, '/tracking');
                            } else {
                              print(
                                  "Disabled? : " + isButtonDisabled.toString());
                              if (isButtonDisabled) return;

                              setState(() {
                                isButtonDisabled = true;
                                print("true");
                              });

                              toastification.show(
                                context: context,
                                type: ToastificationType.info,
                                style: ToastificationStyle.flat,
                                title: const Text("진행 중인 귀가 정보가 없습니다"),
                                alignment: Alignment.bottomCenter,
                                autoCloseDuration: const Duration(seconds: 3),
                                animationBuilder: (
                                  context,
                                  animation,
                                  alignment,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                borderRadius: BorderRadius.circular(12.0),
                                closeButtonShowType: CloseButtonShowType.none,
                                showProgressBar: false,
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 80),
                                closeOnClick: true,
                                dragToClose: true,
                                dismissDirection: DismissDirection.startToEnd,
                              );

                              Future.delayed(const Duration(seconds: 3), () {
                                print("Delaying....");
                                setState(() {
                                  isButtonDisabled = false;
                                  print("false");
                                });
                              });
                            }
                          },
                          icon: Badge(
                              isLabelVisible: isTracking,
                              offset: const Offset(4, 4),
                              backgroundColor: Colors.red,
                              child: const Icon(Icons.map_outlined)),
                          iconSize: 30,
                        );
                      })
                ],
              ),
            ),
            Expanded(
                child: ListView(
              children: [
                stateInfoCard("이우림", "경기도 성남시 중원로 72", "E금빛그랑메종5단지"),
                stateInfoCard("이향우", "경상도 포항 북구 한동로 588", "한동대학교"),
                stateInfoCard("이향우", "경상도 포항 북구 한동로 588", "한동대학교"),
                stateInfoCard("이향우", "경상도 포항 북구 한동로 588", "한동대학교"),
                stateInfoCard("이향우", "경상도 포항 북구 한동로 588", "한동대학교"),
                stateInfoCard("이향우", "경상도 포항 북구 한동로 588", "한동대학교"),
                stateInfoCard("이향우", "경상도 포항 북구 한동로 588", "한동대학교"),
                stateInfoCard("이향우", "경상도 포항 북구 한동로 588", "한동대학교"),
              ],
            ))
          ],
        ),
      ),
    );
  }
}

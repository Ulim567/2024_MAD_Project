import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moblie_app_project/provider/defaultState.dart';
import 'package:provider/provider.dart';
// import 'package:moblie_app_project/login/login.dart';

import 'widgets/confirmRouteWidget.dart';
import 'widgets/selectTimeWidget.dart';
import 'widgets/selectFriendWidget.dart';
import 'widgets/finalConfirmWidget.dart';
import '../provider/dbservice.dart';

class RouteOptionPage extends StatefulWidget {
  const RouteOptionPage({super.key});
  // final String address;
  // final double latitude;
  // final double longitude;

  // const RouteOptionPage({
  //   super.key,
  //   required this.address,
  //   required this.latitude,
  //   required this.longitude,
  // });

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
      // ConfirmRouteWidget(
      //   address: widget.address,
      //   latitude: widget.latitude,
      //   longitude: widget.longitude,
      // ),
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
                              defaultState.selectedTime,
                              defaultState.name,
                              defaultState.address,
                              defaultState.latitude,
                              defaultState.longitude,
                              defaultState.selectedFriends);
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

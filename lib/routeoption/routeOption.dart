import 'package:flutter/material.dart';

import 'widgets/confirmRouteWidget.dart';
import 'widgets/selectTimeWidget.dart';
import 'widgets/selectFriendWidget.dart';
import 'widgets/finalConfirmWidget.dart';

class RouteOptionPage extends StatefulWidget {
  final String address;
  final double latitude;
  final double longitude;

  const RouteOptionPage({
    super.key,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<RouteOptionPage> createState() => _RouteOptionPageState();
}

class _RouteOptionPageState extends State<RouteOptionPage> {
  int index = 0;
  List<Widget> pages = [];

  String appBarTitle = "";

  @override
  void initState() {
    super.initState();
    pages = [
      ConfirmRouteWidget(
        address: widget.address,
        latitude: widget.latitude,
        longitude: widget.longitude,
      ),
      const SelectTimeWidget(),
      const SelectFriendWidget(),
      const FinalconfirmWidget(),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () {
                        if (index == pages.length - 1) {
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

import 'package:flutter/material.dart';

import 'confirmRouteWidget.dart';
import 'selectTimeWidget.dart';
import 'selectFriendWidget.dart';

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
      const SelectFriendWidget()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("위치 확인"),
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
                      child: const Text("돌아가기")),
                  ElevatedButton(
                      onPressed: () {
                        if (index == pages.length - 1) {
                        } else {
                          setState(() {
                            index++;
                          });
                        }
                      },
                      child: const Text("다음"))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'friend.dart';
import 'currentState.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            destinations: const <Widget>[
              NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: "친구"),
              NavigationDestination(
                  icon: Icon(Icons.location_on_outlined),
                  selectedIcon: Icon(Icons.location_on),
                  label: "위치"),
              NavigationDestination(
                  icon: Icon(Icons.access_time_rounded),
                  selectedIcon: Icon(Icons.access_time_filled_rounded),
                  label: "현황")
            ]),
        body: <Widget>[
          FriendPage(),
          HomePage(),
          CurrentStatePage(),
        ][currentPageIndex]);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(
            height: 100,
          ),
          const Text(
            "안녕하세요\n안심 귀가 서비스입니다",
            style: TextStyle(fontSize: 28),
          ),
          const SizedBox(
            height: 10,
          ),
          const TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: '어디로 갈까요?',
            ),
          ),
          Expanded(child: Container()),
          TextButton(
              onPressed: () {
                print("도착지 설정 없이");
              },
              child: const Row(
                children: [Icon(Icons.arrow_forward), Text("도착지 설정 없이 시작하기")],
              ))
        ],
      ),
    );
  }
}

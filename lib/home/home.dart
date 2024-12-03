import 'package:flutter/material.dart';

import 'widgets/friend.dart';
import 'widgets/currentState.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

//ddd

class _HomeState extends State<Home> {
  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            indicatorColor: Colors.amber,
            selectedIndex: currentPageIndex,
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
          const FriendPage(),
          const HomePage(),
          const CurrentStatePage(),
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
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 75,
          ),
          const Text(
            "안녕하세요\n안심 귀가 서비스입니다",
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/search');
            },
            child: const TextField(
              enabled: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.menu),
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                hintText: '어디로 갈까요?',
              ),
            ),
          ),
          Expanded(child: Container()),
          Align(
            alignment: Alignment.bottomCenter,
            child: TextButton(
                onPressed: () {
                  print("도착지 설정 없이");
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(Icons.arrow_forward), Text("도착지 설정 없이 시작하기")],
                )),
          )
        ],
      ),
    );
  }
}

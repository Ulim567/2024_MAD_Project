import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        const Column(
          children: [
            Center(
              child: Text("친구 페이지"),
            )
          ],
        ),
        const Column(
          children: [
            Center(
              child: Text("위치 페이지"),
            )
          ],
        ),
        const Column(
          children: [
            Center(
              child: Text("현황 페이지"),
            )
          ],
        )
      ][currentPageIndex],
    );
  }
}

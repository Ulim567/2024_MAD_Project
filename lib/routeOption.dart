import 'package:flutter/material.dart';

class RouteOptionPage extends StatefulWidget {
  const RouteOptionPage({super.key});

  @override
  State<RouteOptionPage> createState() => _RouteOptionPageState();
}

class _RouteOptionPageState extends State<RouteOptionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("위치 확인"),
      ),
    );
  }
}

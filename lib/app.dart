import 'package:flutter/material.dart';
import 'package:moblie_app_project/googlemap.dart';

import 'login.dart';
import 'home.dart';
import 'search.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      initialRoute: '/login',
      routes: {
        '/map': (BuildContext context) => const GoogleTempPage(),
        '/login': (BuildContext context) => const LoginPage(),
        '/search': (BuildContext context) => const SearchMapPage(),
        '/': (BuildContext context) => const Home(),
      },
      theme: ThemeData.light(useMaterial3: true),
    );
  }
}

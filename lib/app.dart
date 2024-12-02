import 'package:flutter/material.dart';
import 'package:moblie_app_project/routeoption/routeOption.dart';

import 'login/login.dart';
import 'home/home.dart';
import 'search/search.dart';
import 'tracking/tracking.dart';
import 'tracking/finishTracking.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      initialRoute: '/login',
      routes: {
        // '/map': (BuildContext context) => const GoogleTempPage(),
        // '/routeoption': (BuildContext context) {
        //   final address = "포항시 북구 한동로 588 한동대학교";
        //   final latitude = 36.0322; // 예시 위도
        //   final longitude = 129.3404; // 예시 경도

        //   return RouteOptionPage(
        //     address: address,
        //     latitude: latitude,
        //     longitude: longitude,
        //   );
        // },
        '/routeoption': (BuildContext context) => const RouteOptionPage(),
        '/tracking': (BuildContext context) => const TrackingPage(),
        '/finishTracking': (BuildContext context) => const FinishtrackingPage(),
        '/login': (BuildContext context) => const LoginPage(),
        '/search': (BuildContext context) => const SearchMapPage(),
        '/': (BuildContext context) => const Home(),
      },
      theme: ThemeData.light(useMaterial3: true),
    );
  }
}

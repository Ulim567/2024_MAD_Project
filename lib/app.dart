import 'package:flutter/material.dart';
import 'package:shrine/page/login.dart';

class RouteApp extends StatelessWidget {
  const RouteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      initialRoute: '/login',
      routes: {
        '/login': (BuildContext context) => LoginPage(),
        // '/add': (BuildContext context) => const AddPage(),
        // '/profile': (BuildContext context) => const ProfilePage(),
        // '/wishlist': (context) => const WishlistPage(),
        // '/': (BuildContext context) => const HomePage(),
      },
      theme: ThemeData.light(useMaterial3: true),
    );
  }
}

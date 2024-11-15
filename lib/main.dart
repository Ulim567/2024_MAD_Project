import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shrine/productprovider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Firebase 초기화 전에 호출 필요
  await Firebase.initializeApp(); // Firebase 초기화
  runApp(
    ChangeNotifierProvider(
      create: (context) => ProductProvider(),
      child: ShrineApp(),
    ),
  );
}

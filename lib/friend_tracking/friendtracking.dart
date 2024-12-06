import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:intl/intl.dart';
import 'package:moblie_app_project/friend_tracking/widgets/friendmap.dart';

import '../provider/dbservice.dart';

class FriendTrackingPage extends StatefulWidget {
  final String friendUid;

  const FriendTrackingPage({
    super.key,
    required this.friendUid,
  });

  @override
  State<FriendTrackingPage> createState() => _FriendTrackingPageState();
}

class _FriendTrackingPageState extends State<FriendTrackingPage> {
  final _key = GlobalKey<ExpandableFabState>();
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            '사용자가 로그인되지 않았습니다.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final String uid = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("귀가중..."),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FriendRouteMap(
              friendUid: widget.friendUid,
              onRouteLoaded: () {
                print('Route loaded successfully');
              },
            ),
          ),
        ],
      ),
    );
  }
}

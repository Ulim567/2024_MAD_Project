import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:moblie_app_project/tracking/widgets/map.dart';

import '../provider/dbservice.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
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
    // var defaultState = context.watch<Defaultstate>();
    // LatLng destination = LatLng(defaultState.latitude, defaultState.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text("귀가중..."),
        centerTitle: true,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
          stream: _databaseService.getTrackingInfo(uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            Map<String, dynamic>? info = snapshot.data;
            if (info == null) {
              return const Center(child: Text('info is null'));
            }

            Map<String, dynamic> dst = info['destination'];

            LatLng destination = LatLng(dst['latitude'], dst['longitude']);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RouteMap(
                    destination: destination, // 샌프란시스코 좌표
                    onRouteLoaded: () {
                      print('Route loaded successfully');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "도착 설정 시간",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        DateFormat('HH시 mm분').format(dst['time'].toDate()),
                        style: const TextStyle(fontSize: 25),
                      ),
                      const Text(
                        "현재 도착 예정 시간 19시 13분", //TODO: 여기 실제 값으로 변경해야함
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${dst['address']} ${dst['name']}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        type: ExpandableFabType.up,
        childrenAnimation: ExpandableFabAnimation.none,
        distance: 70,
        overlayStyle:
            const ExpandableFabOverlayStyle(color: Colors.black26, blur: 3),
        openButtonBuilder: FloatingActionButtonBuilder(
          size: 56,
          builder: (BuildContext context, void Function()? onPressed,
              Animation<double> progress) {
            return FloatingActionButton(
              heroTag: null,
              onPressed: onPressed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.add),
            );
          },
        ),
        closeButtonBuilder: FloatingActionButtonBuilder(
          size: 56,
          builder: (BuildContext context, void Function()? onPressed,
              Animation<double> progress) {
            return FloatingActionButton(
              heroTag: null,
              onPressed: onPressed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.close),
            );
          },
        ),
        children: [
          Row(
            children: [
              const Text('응급 상황'),
              const SizedBox(width: 20),
              FloatingActionButton(
                heroTag: null,
                onPressed: null,
                backgroundColor: Colors.deepOrange.shade300,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: const Icon(Icons.error_outline),
              ),
            ],
          ),
          Row(
            children: [
              const Text('종료'),
              const SizedBox(width: 20),
              FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  final state = _key.currentState;
                  if (state != null) {
                    _dialogBuilder(context);
                    state.toggle();
                  }
                },
                backgroundColor: Colors.indigo.shade100,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: const Icon(Icons.home_outlined),
              ),
            ],
          ),
          Row(
            children: [
              const Text('전화 화면'),
              const SizedBox(width: 20),
              FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  Navigator.pushNamed(context, '/call');
                },
                backgroundColor: Colors.lightGreen.shade200,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: const Icon(Icons.call),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _dialogBuilder(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            Icon(
              Icons.help_outline_outlined,
              size: 45,
            ),
            SizedBox(
              height: 10,
            ),
            Text('종료하시겠습니까?'),
          ],
        ),
        content: const Text(
          '종료 후에는 현재 진행 중인 귀가 정보는 공유가 중단되며, 귀가 과정을 불러올 수 없습니다.',
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('돌아가기'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('종료하기'),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/finishTracking', // 이동하려는 경로
                (Route<dynamic> route) => false, // 모든 이전 경로를 제거
              );
            },
          ),
        ],
      );
    },
  );
}

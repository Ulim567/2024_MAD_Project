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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("위치 확인"),
        centerTitle: true,
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      body: ConfirmRoutePage(),
    );
  }
}

class ConfirmRoutePage extends StatelessWidget {
  const ConfirmRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          const Text(
            "선택하신 도착지가\n맞는지 확인해주세요",
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(
            height: 35,
          ),
          const Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.black54,
              ),
              const Text(
                "포항시 북구 한동로 588 한동대학교",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Container(
              width: 350,
              height: 350,
              color: Colors.black45,
            ),
          ),
          Expanded(child: Container()),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("돌아가기")),
                ElevatedButton(onPressed: () {}, child: const Text("확인했어요"))
              ],
            ),
          )
        ],
      ),
    );
  }
}

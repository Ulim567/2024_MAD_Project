import 'package:flutter/material.dart';

class ConfirmRouteWidget extends StatelessWidget {
  const ConfirmRouteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
      ],
    );
  }
}

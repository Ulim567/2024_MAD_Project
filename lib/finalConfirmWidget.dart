import 'package:flutter/material.dart';

class FinalconfirmWidget extends StatelessWidget {
  const FinalconfirmWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final location = "한동대학교";
    final locationDetail = "포항시 북구 흥해읍 한동로 588";
    final time = "17시 20분";
    final friends = ["이향우", "이향우", "이향우"];
    String friendsStirng = "";

    for (int i = 0; i < friends.length; i++) {
      if (i == friends.length - 1) {
        friendsStirng = friendsStirng + friends[i];
      } else {
        friendsStirng = "$friendsStirng${friends[i]}, ";
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(
        height: 10,
      ),
      const Text(
        "정보를 확인하고\n시작 버튼을 눌러주세요",
        style: TextStyle(fontSize: 24),
      ),
      const SizedBox(
        height: 35,
      ),
      Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.location_on_outlined,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w500),
                ),
                Text(
                  locationDetail,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.schedule,
              size: 25,
            ),
            title: Text(
              time,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
          ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                friendsStirng,
                style: const TextStyle(fontSize: 20),
              ))
        ],
      ),
    ]);
  }
}

import 'package:flutter/material.dart';
import 'package:moblie_app_project/provider/defaultState.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text_plus/auto_size_text_plus.dart';

class FinalconfirmWidget extends StatelessWidget {
  const FinalconfirmWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var defaultState = context.watch<Defaultstate>();

    String location = defaultState.name;

    List<Map<String, dynamic>> friends = defaultState.selectedFriends;
    String friendsString = "없음";

    if (friends.isNotEmpty) {
      friendsString = "";
    }

    for (int i = 0; i < friends.length; i++) {
      if (i == friends.length - 1) {
        friendsString = friendsString + friends[i]['name'].toString();
      } else {
        friendsString = "$friendsString${friends[i]['name'].toString()}, ";
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
          Row(children: [
            Container(
              width: 30,
              child: const Icon(
                Icons.location_on_outlined,
                size: 30,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    location,
                    maxLines: 1,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.w500),
                  ),
                  AutoSizeText(
                    defaultState.address,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(
            height: 15,
          ),
          Row(children: [
            Container(
              width: 30,
              child: const Icon(
                Icons.schedule,
                size: 25,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                Text(
                  DateFormat('HH시 mm분').format(defaultState.selectedTime),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ]),
          const SizedBox(
            height: 30,
          ),
          Row(children: [
            Container(width: 30, child: const Icon(Icons.person)),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: AutoSizeText(
                friendsString,
                maxLines: 4,
                minFontSize: 18,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 20),
              ),
            )
          ])
        ],
      ),
    ]);
  }
}

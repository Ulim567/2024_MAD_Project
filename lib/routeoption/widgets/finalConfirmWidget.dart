import 'package:flutter/material.dart';
import 'package:moblie_app_project/provider/defaultState.dart';
// import 'package:moblie_app_project/routeoption/widgets/confirmRouteWidget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class FinalconfirmWidget extends StatelessWidget {
  const FinalconfirmWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var defaultState = context.watch<Defaultstate>();

    String location = defaultState.name; // TODO: 이거 바꾸기!!!

    List<String> friends = defaultState.selectedFriends;
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
                  defaultState.address,
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
              DateFormat('HH시 mm분').format(defaultState.selectedTime),
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

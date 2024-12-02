import 'package:flutter/material.dart';
import 'package:moblie_app_project/provider/defaultState.dart';
import 'package:provider/provider.dart';

class SelectFriendWidget extends StatefulWidget {
  const SelectFriendWidget({super.key});

  @override
  State<SelectFriendWidget> createState() => _SelectFriendWidgetState();
}

class _SelectFriendWidgetState extends State<SelectFriendWidget> {
  final List<String> friends = [
    "이항우1",
    "이항우2",
    "이항우3",
    "이항우4",
    "이항우5",
    "이항우6",
    "이항우7",
    "이항우8",
    "이항우9",
    "이항우10",
    "이항우11",
    "이항우12",
    "이항우13",
    "이항우14",
  ]; // 친구 이름 리스트

  List<bool> isSelected = [];

  @override
  Widget build(BuildContext context) {
    var defaultState = context.watch<Defaultstate>();
    for (int i = 0; i < friends.length; i++) {
      isSelected.add(false);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        const Text(
          "위치를 공유할\n친구를 선택해주세요",
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(
          height: 35,
        ),
        SizedBox(
          height: 400,
          child: ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.star_border), // 별 아이콘
                  title: Text(friends[index]),
                  trailing: Checkbox(
                    value: isSelected[index], // 체크 여부 (선택 여부에 따라 변경 가능)
                    onChanged: (bool? value) {
                      setState(() {
                        isSelected[index] = value ?? false;
                        if (isSelected[index]) {
                          defaultState.addSelectedFriends(friends[index]);
                        } else {
                          defaultState.deleteSelectedFriends(friends[index]);
                        }
                      });
                    },
                  ),
                );
              }),
        ),
      ],
    );
  }
}

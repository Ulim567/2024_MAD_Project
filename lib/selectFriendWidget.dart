import 'package:flutter/material.dart';

class SelectFriendWidget extends StatefulWidget {
  const SelectFriendWidget({super.key});

  @override
  State<SelectFriendWidget> createState() => _SelectFriendWidgetState();
}

class _SelectFriendWidgetState extends State<SelectFriendWidget> {
  final List<String> friends = [
    "이항우",
    "이항우",
    "이항우",
    "이항우",
    "이항우",
    "이항우",
    "이항우",
    "이항우",
  ]; // 친구 이름 리스트

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "위치를 공유할 친구를 선택해주세요",
            style: TextStyle(fontSize: 16),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.star_border), // 별 아이콘
                title: Text(friends[index]),
                trailing: Checkbox(
                  value: false, // 체크 여부 (선택 여부에 따라 변경 가능)
                  onChanged: (bool? value) {
                    // 체크박스 변경 로직
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

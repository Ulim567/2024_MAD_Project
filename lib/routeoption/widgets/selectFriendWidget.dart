import 'package:flutter/material.dart';
import 'package:moblie_app_project/provider/dbservice.dart';
import 'package:moblie_app_project/provider/defaultState.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectFriendWidget extends StatefulWidget {
  const SelectFriendWidget({super.key});

  @override
  State<SelectFriendWidget> createState() => _SelectFriendWidgetState();
}

class _SelectFriendWidgetState extends State<SelectFriendWidget> {
  List<Map<String, dynamic>> friends = []; // 친구 이름 리스트
  List<bool> isSelected = []; // 체크박스 상태 리스트

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var defaultState = context.watch<Defaultstate>();

    // FirebaseAuth 인스턴스를 사용하여 현재 사용자 UID 가져오기
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('사용자가 로그인되지 않았습니다.'));
    }

    String currentUserUid = currentUser.uid;

    // DatabaseService 인스턴스
    DatabaseService dbService = DatabaseService();

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
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: dbService.getFriendList(currentUserUid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('오류가 발생했습니다.'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('친구 목록이 비어 있습니다.'));
            }

            // 친구 목록 업데이트
            friends = snapshot.data!;
            isSelected = List.generate(friends.length, (index) {
              return defaultState.selectedFriends.any((selectedFriend) {
                return selectedFriend['uid'] == friends[index]['uid'];
              });
            }); // 체크박스 초기화

            return SizedBox(
              height: 400,
              child: ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.star_border), // 별 아이콘
                      title: Text(friends[index]['name'].toString()),
                      subtitle: Text(friends[index]['email'].toString()),
                      trailing: Checkbox(
                        value: isSelected[index], // 체크 여부 (선택 여부에 따라 변경 가능)
                        onChanged: (bool? value) {
                          setState(() {
                            isSelected[index] = value ?? false;
                            if (isSelected[index]) {
                              defaultState.addSelectedFriends(friends[index]);
                            } else {
                              defaultState
                                  .deleteSelectedFriends(friends[index]);
                            }
                          });
                        },
                      ),
                    );
                  }),
            );
          },
        ),
      ],
    );
  }
}

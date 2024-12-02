import 'package:flutter/material.dart';
import 'package:moblie_app_project/provider/dbservice.dart';

class FriendRequestsModal extends StatelessWidget {
  final String currentUserUid;
  final List<String> friendRequests;
  final DatabaseService databaseService;

  const FriendRequestsModal({
    super.key,
    required this.currentUserUid,
    required this.friendRequests,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "친구 추가 요청",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: databaseService.getUserList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('데이터를 가져오는 중 오류 발생: ${snapshot.error}'),
                );
              }

              final userList = snapshot.data;
              if (userList == null || userList.isEmpty) {
                return const Center(
                  child: Text("사용자 데이터가 없습니다.",
                      style: TextStyle(color: Colors.grey)),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: friendRequests.length,
                itemBuilder: (context, index) {
                  final targetUid = friendRequests[index];
                  final targetUser = userList.firstWhere(
                    (user) => user['uid'] == targetUid,
                    orElse: () => {},
                  );

                  final targetUserName = targetUser['name'] ?? '이름 없음';
                  final targetUserEmail = targetUser['email'] ?? '이메일 없음';

                  return ListTile(
                    title: Text(targetUserName),
                    subtitle: Text(targetUserEmail),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            await databaseService.acceptFriendRequest(
                                targetUid, currentUserUid);

                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await databaseService.rejectFriendRequest(
                                targetUid, currentUserUid);

                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

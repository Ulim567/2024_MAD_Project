import 'package:flutter/material.dart';
import 'package:moblie_app_project/provider/dbservice.dart';

class FriendRequestsModal extends StatelessWidget {
  final String currentUserUid;
  final DatabaseService databaseService;

  const FriendRequestsModal({
    Key? key,
    required this.currentUserUid,
    required this.databaseService,
  }) : super(key: key);

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
          StreamBuilder<Map<String, dynamic>?>(
            stream: databaseService.getUserDataStream(currentUserUid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('데이터를 가져오는 중 오류 발생: ${snapshot.error}'),
                );
              }

              final userData = snapshot.data;
              if (userData == null || userData['request'] == null) {
                return const Center(
                  child: Text("친구 요청이 없습니다.",
                      style: TextStyle(color: Colors.grey)),
                );
              }

              final List<String> friendRequests =
                  List<String>.from(userData['request']);

              return ListView.builder(
                shrinkWrap: true,
                itemCount: friendRequests.length,
                itemBuilder: (context, index) {
                  final targetUid = friendRequests[index];
                  return ListTile(
                    title: Text(targetUid),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            await databaseService.acceptFriendRequest(
                                targetUid, currentUserUid);

                            // 요청 수락 후 모달 닫기
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await databaseService.rejectFriendRequest(
                                targetUid, currentUserUid);

                            // 요청 거절 후 모달 닫기
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

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moblie_app_project/addfriend/page.dart';
import 'package:moblie_app_project/home/widgets/requestmodal.dart';
import 'package:moblie_app_project/provider/dbservice.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<String> friends = [];
  List<String> friendRequests = [];

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // 사용자 로그인이 안 되어 있을 경우 처리
    if (user == null) {
      return Scaffold(
        body: const Center(
          child: Text(
            '사용자가 로그인되지 않았습니다.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final String displayName = user.displayName ?? 'none';
    final String uid = user.uid;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
        child: Column(
          children: [
            // Profile card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 8, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.purple.shade100,
                          child: const Icon(Icons.person,
                              size: 30, color: Colors.purple),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              uid,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        try {
                          // Firebase 로그아웃
                          await FirebaseAuth.instance.signOut();

                          // Google Sign-In 로그아웃
                          final GoogleSignIn googleSignIn = GoogleSignIn();
                          await googleSignIn.signOut();

                          // 로그아웃 성공 메시지 출력
                          print("로그아웃 성공");
                          Navigator.pushNamed(context, "/login");
                        } catch (e) {
                          // 로그아웃 실패 메시지 출력
                          print("로그아웃 실패: $e");
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddFriendPage()),
                    );
                  },
                ),
                hintText: '이름으로 친구를 검색해보세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Friends list
            Expanded(
              child: StreamBuilder<Map<String, dynamic>?>(
                stream: _databaseService.getUserDataStream(uid),
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
                  if (userData == null) {
                    return const Center(child: Text('사용자 데이터를 찾을 수 없습니다.'));
                  }

                  friends = List<String>.from(userData['friend'] ?? []);
                  friendRequests = List<String>.from(userData['request'] ?? []);

                  return StreamBuilder<List<Map<String, dynamic>>>(
                    stream:
                        _databaseService.getUserList(), // 다른 사용자 목록을 가져오는 스트림
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
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          final friendUid = friends[index];

                          // friendUid에 해당하는 사용자를 userList에서 찾음
                          final targetUser = userList.firstWhere(
                            (user) => user['uid'] == friendUid,
                            orElse: () => {}, // 유효하지 않으면 빈 맵 반환
                          );

                          final targetUserName = targetUser['name'] ?? '이름 없음';
                          final targetUserEmail =
                              targetUser['email'] ?? '이메일 없음';

                          return ListTile(
                            leading: const Icon(Icons.star, color: Colors.grey),
                            title: Text(targetUserName),
                            subtitle: Text(targetUserEmail),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  // 친구 삭제 로직
                                  friends.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => FriendRequestsModal(
              currentUserUid: FirebaseAuth.instance.currentUser!.uid,
              friendRequests: friendRequests,
              databaseService: _databaseService,
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 212, 139, 224),
        child: const Icon(Icons.local_post_office),
      ),
    );
  }
}

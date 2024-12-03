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

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
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
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
        child: Column(
          children: [
            // 프로필 카드
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
                          await FirebaseAuth.instance.signOut();
                          final GoogleSignIn googleSignIn = GoogleSignIn();
                          await googleSignIn.signOut();
                          print("로그아웃 성공");
                          Navigator.pushNamed(context, "/login");
                        } catch (e) {
                          print("로그아웃 실패: $e");
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 검색 창
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
            // 친구 목록
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _databaseService.getFriendList(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('데이터를 가져오는 중 오류 발생: ${snapshot.error}'),
                    );
                  }

                  final friends = snapshot.data ?? [];
                  if (friends.isEmpty) {
                    return const Center(
                      child: Text("친구 목록이 없습니다.",
                          style: TextStyle(color: Colors.grey)),
                    );
                  }

                  return ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      final friendName = friend['name'] ?? '이름 없음';
                      final friendEmail = friend['email'] ?? '이메일 없음';

                      return ListTile(
                        leading: const Icon(Icons.star, color: Colors.grey),
                        title: Text(friendName),
                        subtitle: Text(friendEmail),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () async {
                            await _databaseService.deleteFriend(
                              uid,
                              friend['uid'],
                            );
                          },
                        ),
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
              databaseService: _databaseService,
              currentUserUid: uid,
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 212, 139, 224),
        child: const Icon(Icons.local_post_office),
      ),
    );
  }
}

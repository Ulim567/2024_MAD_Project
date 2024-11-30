import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final List<String> friends = ['이향우', '이향우', '이향우', '이향우', '이향우'];
  final List<String> friendRequests = ['이향우'];

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? 'none';
    final String uid = user?.uid ?? 'UID not found';
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
                          child: Icon(Icons.person,
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
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              uid,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 20,
                    ),
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

                            // 로그아웃 성공 메시지 출력 (옵션)
                            print("로그아웃 성공");
                            Navigator.pushNamed(context, "/login");
                          } catch (e) {
                            // 로그아웃 실패 메시지 출력
                            print("로그아웃 실패: $e");
                          }
                        }),
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
                  icon: const Icon(Icons.add), // Show bottom sheet
                  onPressed: () {},
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
              child: ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.star, color: Colors.grey),
                    title: Text(friends[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          friends.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 하단 모달 시트 호출
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => _buildFriendRequestsModal(),
          );
        },
        backgroundColor: const Color.fromARGB(255, 212, 139, 224),
        child: const Icon(Icons.local_post_office),
      ),
    );
  }

  Widget _buildFriendRequestsModal() {
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
          ListView.builder(
            shrinkWrap: true,
            itemCount: friendRequests.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(friendRequests[index]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          friends.add(friendRequests[index]);
                          friendRequests.removeAt(index);
                        });
                        Navigator.pop(context); // 모달 닫기
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          friendRequests.removeAt(index);
                        });
                        Navigator.pop(context); // 모달 닫기
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

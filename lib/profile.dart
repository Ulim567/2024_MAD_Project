import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shrine/login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> _fetchUserData(String uid) async {
    try {
      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();
      return userDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: user == null
            ? const Text('No user is currently signed in.')
            : FutureBuilder<Map<String, dynamic>?>(
                future: _fetchUserData(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Text('Failed to load user data.');
                  }

                  final userData = snapshot.data!;
                  final email = userData['email'] ?? 'Anonymous';
                  final displayName = userData['name'] ??
                      (user.isAnonymous ? 'Anonymous User' : 'User');
                  final statusMessage = userData['status_message'] ??
                      "I promise to take the test honestly before GOD.";
                  final imageUrl = user.photoURL ??
                      'http://handong.edu/site/handong/res/img/logo.png';

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 300, // Width of the square avatar
                          height: 300, // Height of the square avatar
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit
                                  .contain, // Fills the container with the image
                            ),
                            // Set corner radius here
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('UID : ${user.uid}',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Divider(
                          height: 10,
                        ),
                        const SizedBox(height: 30),
                        Text('Email: $email',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 30),
                        Text('Name: $displayName',
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 50),
                        Text('Lee Hyang Woo',
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 30),
                        Text(
                          statusMessage,
                          style: const TextStyle(
                              fontSize: 20, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

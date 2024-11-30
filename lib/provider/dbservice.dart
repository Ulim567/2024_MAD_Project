import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseService with ChangeNotifier {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  // 사용자 데이터 저장
  Future<void> saveUserData(String uid, String email, String name) async {
    try {
      // 사용자 문서 확인
      DocumentSnapshot snapshot = await _userCollection.doc(uid).get();

      if (snapshot.exists) {
        // 이미 존재하는 경우 처리
        if (kDebugMode) print("User data already exists for uid: $uid");
        return; // 데이터를 저장하지 않고 종료
      }

      // 사용자 데이터 저장
      await _userCollection.doc(uid).set({
        'email': email,
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      notifyListeners(); // 상태 변경 알림
    } catch (e) {
      if (kDebugMode) print("Error saving user data: $e");
    }
  }

  // 사용자 데이터 가져오기 (단일 사용자)
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot snapshot = await _userCollection.doc(uid).get();
      return snapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print("Error getting user data: $e");
      return null;
    }
  }

  // 모든 사용자 데이터 스트림
  Stream<List<Map<String, dynamic>>> getAllUsersStream() {
    return _userCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    });
  }
}

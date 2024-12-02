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

      // snapshot.data()가 null일 경우, 빈 Map을 반환하거나 적절한 처리를 해줍니다.
      if (snapshot.exists && snapshot.data() != null) {
        return {'uid': uid, ...snapshot.data() as Map<String, dynamic>};
      } else {
        return null; // 데이터가 없을 경우 null 반환
      }
    } catch (e) {
      if (kDebugMode) print("Error getting user data: $e");
      return null;
    }
  }

  Stream<Map<String, dynamic>?> getUserDataStream(String uid) {
    return _userCollection.doc(uid).snapshots().map((snapshot) {
      // snapshot이 존재하고, 데이터가 null이 아닐 경우
      if (snapshot.exists && snapshot.data() != null) {
        return {'uid': uid, ...snapshot.data() as Map<String, dynamic>};
      } else {
        return null; // 데이터가 없을 경우 null 반환
      }
    }).handleError((e) {
      if (kDebugMode) print("Error getting user data stream: $e");
    });
  }

  Future<String?> getUserNameByUid(String uid) async {
    try {
      DocumentSnapshot snapshot = await _userCollection.doc(uid).get();

      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.get('name'); // 사용자 이름 반환
      } else {
        return null; // 데이터가 없을 경우 null 반환
      }
    } catch (e) {
      if (kDebugMode) print("Error getting user name by UID: $e");
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> getFriendsInfo(List<String> friendsUid) {
    return _userCollection
        .where(FieldPath.documentId,
            whereIn: friendsUid) // friendsUid 목록에 있는 모든 UID로 필터링
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'uid': doc.id,
          'name': doc['name'],
          'email': doc['email'],
        };
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUserList() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'uid': doc.id,
          'name': doc['name'],
          'email': doc['email'],
        };
      }).toList();
    });
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

  // 친구 요청 보내기
  Future<void> sendFriendRequest(
      String targetUid, String currentUserUid) async {
    try {
      // 대상 사용자의 요청 배열에 로그인한 사용자의 UID 추가
      await _userCollection.doc(targetUid).update({
        'request': FieldValue.arrayUnion([currentUserUid]),
      });

      if (kDebugMode)
        print("Friend request sent to $targetUid from $currentUserUid");
    } catch (e) {
      if (kDebugMode) print("Error sending friend request: $e");
    }
  }

  // 친구 요청 수락하기
  Future<void> acceptFriendRequest(
      String targetUid, String currentUserUid) async {
    try {
      // 요청을 수락하고, 친구 목록에 추가
      await _userCollection.doc(currentUserUid).update({
        'friend': FieldValue.arrayUnion([targetUid]),
        'request': FieldValue.arrayRemove([targetUid]),
      });

      await _userCollection.doc(targetUid).update({
        'friend': FieldValue.arrayUnion([currentUserUid]),
        'request': FieldValue.arrayRemove([currentUserUid]),
      });

      if (kDebugMode)
        print("Friend request accepted from $targetUid to $currentUserUid");
    } catch (e) {
      if (kDebugMode) print("Error accepting friend request: $e");
    }
  }

  // 친구 요청 거절하기
  Future<void> rejectFriendRequest(
      String targetUid, String currentUserUid) async {
    try {
      // 요청을 거절하고, 요청 목록에서 제거
      await _userCollection.doc(currentUserUid).update({
        'request': FieldValue.arrayRemove([targetUid]),
      });

      await _userCollection.doc(targetUid).update({
        'request': FieldValue.arrayRemove([currentUserUid]),
      });

      if (kDebugMode)
        print("Friend request rejected from $targetUid to $currentUserUid");
    } catch (e) {
      if (kDebugMode) print("Error rejecting friend request: $e");
    }
  }
}

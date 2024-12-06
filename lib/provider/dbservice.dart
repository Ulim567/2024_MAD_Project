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

  // 친구 목록 Stream
  Stream<List<Map<String, dynamic>>> getFriendList(String currentUserUid) {
    return _userCollection
        .doc(currentUserUid)
        .snapshots()
        .asyncMap((snapshot) async {
      final friendUids = List<String>.from(snapshot['friend'] ?? []);

      if (friendUids.isEmpty) {
        return [];
      }

      final friendDocs = await _userCollection
          .where(FieldPath.documentId, whereIn: friendUids)
          .get();

      return friendDocs.docs.map((doc) {
        return {
          'uid': doc.id,
          'name': doc['name'],
          'email': doc['email'],
        };
      }).toList();
    });
  }

  // 친구 요청 목록 Stream
  Stream<List<Map<String, dynamic>>> getFriendRequestList(
      String currentUserUid) {
    return _userCollection
        .doc(currentUserUid)
        .snapshots()
        .asyncMap((snapshot) async {
      final requestUids = List<String>.from(snapshot['request'] ?? []);

      if (requestUids.isEmpty) {
        return [];
      }

      final requestDocs = await _userCollection
          .where(FieldPath.documentId, whereIn: requestUids)
          .get();

      return requestDocs.docs.map((doc) {
        return {
          'uid': doc.id,
          'name': doc['name'],
          'email': doc['email'],
        };
      }).toList();
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

  Future<void> deleteFriend(String currentUserUid, String friendUid) async {
    try {
      // 로그인한 사용자의 친구 목록에서 friendUid 삭제
      await _userCollection.doc(currentUserUid).update({
        'friend': FieldValue.arrayRemove([friendUid]),
      });

      // 친구 사용자의 친구 목록에서 currentUserUid 삭제
      await _userCollection.doc(friendUid).update({
        'friend': FieldValue.arrayRemove([currentUserUid]),
      });

      if (kDebugMode) {
        print("Friend $friendUid removed from $currentUserUid's friend list");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error removing friend: $e");
      }
    }
  }

  Future<void> sendTrackingInfo(
    String uid,
    List<Map<String, dynamic>> friends,
    String locationName,
    String address,
    double latitude,
    double longitude,
    Timestamp time,
    List<Map<String, dynamic>> records,
  ) async {
    try {
      // Create destination data
      Map<String, dynamic> destination = {
        'name': locationName,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'time': time,
      };

      // Create tracking info data
      Map<String, dynamic> trackingInfo = {
        'trackingInfo': {
          'friends': friends,
          'destination': destination,
          'records': records,
        }
      };

      // Update the main user's tracking info
      await _userCollection.doc(uid).update(trackingInfo);

      // Update each friend's document to include the main user's UID in 'tracking_friends'
      for (var friend in friends) {
        String friendUid =
            friend['uid']; // Assuming 'uid' is a key in the friend map
        await _userCollection.doc(friendUid).update({
          'tracking_friends': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> sendTrackingStartInfo(
    String uid,
    double latitude,
    double longitude,
  ) async {
    try {
      // 문서를 먼저 가져옵니다.
      DocumentSnapshot doc = await _userCollection.doc(uid).get();

      // data()를 Map<String, dynamic>으로 캐스팅
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      // trackingInfo와 start가 이미 있는지 확인
      Map<String, dynamic>? trackingInfo = data?['trackingInfo'];
      if (trackingInfo != null && trackingInfo['start'] != null) {
        if (kDebugMode) {
          print("start 값이 이미 존재합니다. 업데이트를 건너뜁니다.");
        }
        return; // 업데이트하지 않고 종료
      }

      // 업데이트할 start 값 생성
      Map<String, dynamic> start = {
        'latitude': latitude,
        'longitude': longitude,
      };

      // Firebase 문서 업데이트
      await _userCollection.doc(uid).update({
        'trackingInfo.start': start,
      });

      if (kDebugMode) {
        print("start 값이 성공적으로 업데이트되었습니다.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("오류 발생: $e");
      }
    }
  }

  Stream<Map<String, dynamic>> getTrackingInfo(String? uid) {
    try {
      if (uid == null) {
        // uid가 null이면 빈 Map을 반환하는 Stream을 반환
        return Stream.value({});
      }

      // Firestore에서 해당 UID에 해당하는 문서를 스트림으로 가져오기
      return _userCollection.doc(uid).snapshots().map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          Map<String, dynamic> userInfo = snapshot.get('trackingInfo');
          return userInfo;
        } else {
          return {}; // 데이터가 없으면 빈 Map 반환
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
        print("Exception");
      }

      return Stream.value({}); // 예외가 발생한 경우 빈 Map을 반환
    }
  }

  Future<bool> isTrackingNow(String? uid) async {
    try {
      if (uid == null) {
        return false;
      }

      DocumentSnapshot snapshot = await _userCollection.doc(uid).get();
      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        return (data != null && data.containsKey('trackingInfo'));
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }

      return false;
    }
  }

  Future<void> deleteTrackingInfo(String? uid) async {
    try {
      if (uid == null) {
        return;
      }
      final userDoc = await _userCollection.doc(uid).get();
      if (!userDoc.exists) {
        return;
      }
      final userData = userDoc.data() as Map<String, dynamic>?;
      if (userData == null) {
        return;
      }
      final trackingInfo = userData['trackingInfo'];
      if (trackingInfo == null) {
        return;
      }

      // Extract friends list from trackingInfo
      final List<Map<String, dynamic>> friends =
          List<Map<String, dynamic>>.from(trackingInfo['friends'] ?? []);

      // Remove `uid` from each friend's `tracking_friends`
      for (var friend in friends) {
        String friendUid = friend['uid'];
        await _userCollection.doc(friendUid).update({
          'tracking_friends': FieldValue.arrayRemove([uid]),
        });
      }

      // Delete the user's trackingInfo
      await _userCollection.doc(uid).update({
        'trackingInfo': FieldValue.delete(),
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> addRecordToTrackingInfo(
      String uid, Map<String, dynamic> newRecord) async {
    try {
      // Firestore document reference
      DocumentReference userDocRef = _userCollection.doc(uid);

      // Add the new record to the records field in trackingInfo
      await userDocRef.update({
        'trackingInfo.records': FieldValue.arrayUnion([newRecord]),
      });

      if (kDebugMode) {
        print("New record added to trackingInfo for user: $uid");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error adding record to trackingInfo: $e");
      }
    }
  }

  Stream<List> getTrackingRecords(String uid) {
    return _userCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> trackingInfo = snapshot.get('trackingInfo') ?? {};
        // Return the records list if exists, or an empty list if not
        return List<Map<String, dynamic>>.from(trackingInfo['records'] ?? []);
      } else {
        return []; // Return empty list if no data found
      }
    }).handleError((e) {
      if (kDebugMode) {
        print("Error streaming tracking records: $e");
      }
    });
  }
}

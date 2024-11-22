import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthControl {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await auth.signInWithCredential(credential);
    } catch (e) {
      return null;
    }
  }

  Future<UserCredential> signInWithAnonymously() async {
    return FirebaseAuth.instance.signInAnonymously();
  }

  Future<void> logout() async {
    await auth.signOut();
    await GoogleSignIn().signOut();
  }

  Future<void> saveGoogleUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      DocumentSnapshot userInfos = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();
      if (!userInfos.exists) {
        String? emailAddress;
        String? name;
        for (final providerProfile in user.providerData) {
          final provider = providerProfile.providerId;

          if (provider == "google.com") {
            emailAddress = providerProfile.email;
            name = providerProfile.displayName;
          }
        }

        await FirebaseFirestore.instance.collection('user').doc(user.uid).set({
          'email': emailAddress,
          'name': name,
          'status_message': 'I promise to take the test honestly before GOD.',
          'uid': user.uid,
          'wishlist': [],
        });
      }
    }
  }

  Future<void> saveAnonymousUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.isAnonymous) {
      DocumentSnapshot userInfo = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();
      if (!userInfo.exists) {
        await FirebaseFirestore.instance.collection('user').doc(user.uid).set({
          'status_message': 'I promise to take the test honestly before GOD.',
          'uid': user.uid,
          'wishlist': [],
        });
      }
    }
  }

  void monitorAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }
}

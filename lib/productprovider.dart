import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductProvider with ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _wishlistItems = [];

  List<Map<String, dynamic>> get wishlistItems => _wishlistItems;
  String _sortOrder = 'ASC';

  List<Map<String, dynamic>> get products {
    List<Map<String, dynamic>> sortedProducts = List.from(_products);
    if (_sortOrder == 'ASC') {
      sortedProducts.sort(
          (a, b) => (a['price'] as double).compareTo(b['price'] as double));
    } else {
      sortedProducts.sort(
          (a, b) => (b['price'] as double).compareTo(a['price'] as double));
    }
    return sortedProducts;
  }

  void sortProducts(String sortOrder) {
    _sortOrder = sortOrder;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _db.collection('products').get();
      _products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await _db.collection('products').add(productData);
      await fetchProducts();
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _db.collection('products').doc(productId).delete();
      await fetchProducts();
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  Future<void> updateProduct(
      String productId, Map<String, dynamic> updatedData) async {
    try {
      await _db.collection('products').doc(productId).update(updatedData);
      await fetchProducts();
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  String? getCurrentUserId() {
    User? user = _auth.currentUser;
    return user?.uid;
  }

  Future<void> toggleLike(String productId, BuildContext context) async {
    final currentUserUid = getCurrentUserId();
    if (currentUserUid == null) return;

    final productRef = _db.collection('products').doc(productId);
    final productSnapshot = await productRef.get();
    if (productSnapshot.exists) {
      List<dynamic> likes = productSnapshot.data()?['likes'] ?? [];

      if (likes.contains(currentUserUid)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can only do it once !!')),
        );
      } else {
        likes.add(currentUserUid);
        await productRef.update({'likes': likes});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('I LIKE IT!')),
        );
        notifyListeners();
      }
    }
  }

  Future<void> createUser(String uid, {String? name, String? email}) async {
    const String defaultStatusMessage =
        "I promise to take the test honestly before GOD.";

    try {
      final userDoc = await _db.collection('user').doc(uid).get();

      if (userDoc.exists) {
        // 유저가 이미 존재하는 경우
        print("User already exists.");
      } else {
        // 유저가 없을 경우 새로 생성
        final userData = {
          'uid': uid,
          'status_message': defaultStatusMessage,
        };

        if (name != null && email != null) {
          // Google 유저 데이터 추가
          userData['name'] = name;
          userData['email'] = email;
        }

        await _db.collection('user').doc(uid).set(userData);
        print("User document created successfully!");
      }
    } catch (e) {
      print("Error creating user document: $e");
    }
  }

  Future<void> toggleCart(String productId, BuildContext context) async {
    final currentUserUid = getCurrentUserId();
    if (currentUserUid == null) return;

    final userRef = _db.collection('user').doc(currentUserUid);
    final userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      List<dynamic> cart = userSnapshot.data()?['cart'] ?? [];

      if (cart.contains(productId)) {
        // Remove from cart
        cart.remove(productId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from cart!')),
        );
      } else {
        // Add to cart
        cart.add(productId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to cart!')),
        );
      }

      await userRef.update({'cart': cart});
      notifyListeners();
    }
  }

  Future<bool> isInCart(String productId) async {
    final currentUserUid = getCurrentUserId();
    if (currentUserUid == null) return false;

    final userSnapshot = await _db.collection('user').doc(currentUserUid).get();
    List<dynamic> cart = userSnapshot.data()?['cart'] ?? [];
    return cart.contains(productId);
  }

  Future<void> fetchWishlistItems() async {
    final currentUserUid = getCurrentUserId();
    if (currentUserUid == null) return;

    final userSnapshot = await _db.collection('user').doc(currentUserUid).get();
    List<dynamic> cart = userSnapshot.data()?['cart'] ?? [];

    if (cart.isNotEmpty) {
      final snapshot = await _db
          .collection('products')
          .where(FieldPath.documentId, whereIn: cart)
          .get();

      _wishlistItems = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      notifyListeners();
    }
  }
}

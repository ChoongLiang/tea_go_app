import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_model.dart';
import 'user_model.dart' as model;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Returns the current Auth instance
  FirebaseAuth get auth => _auth;

  Future<void> verifyPhoneNumber(String phoneNumber, Function(String) onCodeSent, {Function(String)? onError}) async {
    print("🚀 [Firebase] Sending OTP to: $phoneNumber");

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        print("✅ [Firebase] Auto-verified, signing in...");
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print("❌ [Firebase] Send failed. Code: ${e.code}");
        print("Details: ${e.message}");
        onError?.call(e.message ?? e.code);
      },
      codeSent: (String verificationId, int? resendToken) {
        print("📨 [Firebase] OTP sent. Verification ID: $verificationId");
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("⏰ [Firebase] Auto-retrieval timeout");
      },
    );
  }

  // Sign in with credential — called from OTP page
  Future<UserCredential?> signInWithCredential(PhoneAuthCredential credential) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("❌ [AuthService] Sign-in failed: $e");
      rethrow;
    }
  }

  // Save user profile to Firestore after signup
  Future<void> saveUserProfile(model.User user) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'firstName': user.firstName,
      'lastName': user.lastName,
      'dob': user.dob,
      'gender': user.gender,
      'email': user.email,
      'phone': _auth.currentUser?.phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print("✅ [Firestore] User profile saved for UID: $uid");
  }

  // Save completed order to Firestore under orders/{uid}/
  Future<void> saveOrder({
    required String orderId,
    required List<CartItem> items,
    required double total,
    required String outlet,
  }) async {
    final uid = _auth.currentUser?.uid;
    final collection = uid != null
        ? _db.collection('users').doc(uid).collection('orders')
        : _db.collection('guest_orders');

    await collection.doc(orderId).set({
      'orderId': orderId,
      'outlet': outlet,
      'total': total,
      'status': 'placed',
      'createdAt': FieldValue.serverTimestamp(),
      'items': items.map((i) => {
        'name': i.name,
        'price': i.price,
        'quantity': i.quantity,
        'sugarLevel': i.sugarLevel,
        'iceLevel': i.iceLevel,
        'note': i.note,
        'imageUrl': i.imageUrl,
      }).toList(),
    });
    print("✅ [Firestore] Order $orderId saved");
  }

  // Load all orders for the current user from Firestore
  Future<List<Map<String, dynamic>>> loadOrders() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Load user profile from Firestore (returns null if not found)
  Future<model.User?> loadUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    print("✅ [Firestore] User profile loaded for UID: $uid");
    return model.User(
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      dob: data['dob'] ?? '',
      gender: data['gender'] ?? '',
      email: data['email'] ?? '',
    );
  }
}
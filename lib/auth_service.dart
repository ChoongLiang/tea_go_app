import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        print('Phone number automatically verified and user signed in: ${credential.smsCode}');
        verificationCompleted(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Phone number verification failed: ${e.message}');
        verificationFailed(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        print('Code sent to $phoneNumber, verificationId: $verificationId');
        _verificationId = verificationId;
        codeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('Code auto retrieval timeout for verificationId: $verificationId');
        _verificationId = verificationId;
        codeAutoRetrievalTimeout(verificationId);
      },
    );
  }

  Future<UserCredential?> signInWithCredential(PhoneAuthCredential credential) async {
    try {
      print('Signing in with credential');
      final userCredential = await _auth.signInWithCredential(credential);
      print('Signed in with user: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      print('Failed to sign in with credential: $e');
      return null;
    }
  }

  String? get verificationId => _verificationId;
}

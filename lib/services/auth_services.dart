import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hospital_management_service_app/services/notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= SIGN UP =================
  Future<UserCredential> signUp({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // USERS collection
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ROLE BASED COLLECTION
      if (role == "Patient") {
        await _firestore.collection('patients').doc(uid).set({
          'uid': uid,
          'name': fullName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('doctors').doc(uid).set({
          'uid': uid,
          'name': fullName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // FCM INIT
      await NotificationService().initNotifications(uid, role);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw 'This email is already registered. Please login.';
      } else if (e.code == 'weak-password') {
        throw 'Password must be at least 6 characters.';
      } else if (e.code == 'invalid-email') {
        throw 'Invalid email address.';
      } else {
        throw 'Signup failed. Try again.';
      }
    }
  }

  // ================= LOGIN =================
  Future<User?> signIn(String email, String password, String role) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = result.user!;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw 'User data not found';
      }

      if (userDoc['role'] != role) {
        throw 'Incorrect role selected';
      }

      // FCM INIT
      await NotificationService().initNotifications(user.uid, role);

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No account found with this email';
      } else if (e.code == 'wrong-password') {
        throw 'Incorrect password';
      } else {
        throw 'Login failed. Try again.';
      }
    }
  }

  // ================= GET ROLE =================
  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(uid).get();
    return doc['role'];
  }

  // ================= FORGOT PASSWORD =================
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Password reset failed';
    }
  }

  // ================= LOGOUT =================
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

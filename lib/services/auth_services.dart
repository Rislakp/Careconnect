import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hospital_management_service_app/services/notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SIGN UP
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

    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });

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

    //  FCM INIT (AFTER signup success)
    await NotificationService().initNotifications(uid, role);

    return userCredential;

  } on FirebaseAuthException catch (e) {
    throw Exception(e.message ?? 'Signup failed');
  }
}


  // LOGIN
Future<User?> signIn(String email, String password, String role) async {
  UserCredential result =
      await _auth.signInWithEmailAndPassword(
          email: email, password: password);

  User? user = result.user;

  DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user!.uid).get();

  if (userDoc['role'] != role) {
    throw Exception("Incorrect role selected");
  }

  // FCM INIT (AFTER login success)
  await NotificationService().initNotifications(user.uid, role);

  return user;
}

  // GET ROLE
  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(uid).get();
    return doc['role'];
  }

  // FORGOT PASSWORD
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Password reset failed');
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

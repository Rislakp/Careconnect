import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save or update profile data
  Future<void> saveDoctorProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await _firestore.collection('doctors').doc(user.uid).set(data, SetOptions(merge: true));
  }

  // Get doctor profile stream
  Stream<DocumentSnapshot> getDoctorProfileStream() {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    return _firestore.collection('doctors').doc(user.uid).snapshots();
  }

  // Get doctor profile once
  Future<Map<String, dynamic>?> getDoctorProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final doc = await _firestore.collection('doctors').doc(user.uid).get();
    return doc.data();
  }
}
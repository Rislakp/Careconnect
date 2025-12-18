import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save or update profile data
  Future<void> savePatientProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await _firestore
        .collection('patients')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
  }

  // Get Patient profile stream
  Stream<DocumentSnapshot> getPatientProfileStream() {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    return _firestore.collection('patients').doc(user.uid).snapshots();
  }

  // Get patient profile once
  Future<Map<String, dynamic>?> getPatientProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final doc = await _firestore.collection('patients').doc(user.uid).get();
    return doc.data();
  }
}

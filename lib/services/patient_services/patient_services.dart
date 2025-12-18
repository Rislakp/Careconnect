import 'package:cloud_firestore/cloud_firestore.dart';

class PatientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //  Add new patient to Firestore
  Future<void> addPatient({
    required String name,
    required String id,
    required String lastVisit,
    required String image,
    String? doctorId, required String imageUrl,
  }) async {
    try {
      await _firestore.collection('patients').add({
        'name': name,
        'id': id,
        'lastVisit': lastVisit,
        'image': image,
      'doctorId': doctorId ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print(" Patient added successfully");
    } catch (e) {
      print(" Error adding patient: $e");
    }
  }

  //  Fetch all patients (live updates)
  Stream<QuerySnapshot> getPatients() {
    return _firestore
        .collection('patients')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Delete a patient
  Future<void> deletePatient(String docId) async {
    try {
      await _firestore.collection('patients').doc(docId).delete();
      print(" Patient deleted");
    } catch (e) {
      print(" Error deleting patient: $e");
    }
  }

  //  Update patient info
  Future<void> updatePatient(String docId, Map<String, dynamic> newData) async {
    try {
      await _firestore.collection('patients').doc(docId).update(newData);
      print(" Patient updated");
    } catch (e) {
      print(" Error updating patient: $e");
    }
  }
}

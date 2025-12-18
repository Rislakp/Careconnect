import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PatientDetailsProvider extends ChangeNotifier {
  bool isLoading = true;
  Map<String, dynamic>? patient;

  Future<void> loadPatient(String patientId) async {
    isLoading = true;
    notifyListeners();

    final doc = await FirebaseFirestore.instance
        .collection("patients")
        .doc(patientId)
        .get();

    patient = doc.data();

    isLoading = false;
    notifyListeners();
  }
}

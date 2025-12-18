import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hospital_management_service_app/services/patient_services/patient_profile_service.dart';


class PatientProfileProvider extends ChangeNotifier {
  final _service = PatientProfileService();

  Map<String, dynamic>? _patientData;
  bool _isLoading = false;

  Map<String, dynamic>? get PatientData => _patientData;
  bool get isLoading => _isLoading;

  Future<void> fetchPatientProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.getPatientProfile();
      _patientData = data;
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveDoctorProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.savePatientProfile(data);
     _patientData = data;
    } catch (e) {
      debugPrint("Error saving profile: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Stream<DocumentSnapshot> get doctorStream =>
      _service.getPatientProfileStream();
}

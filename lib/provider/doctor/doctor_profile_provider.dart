import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hospital_management_service_app/services/doctor/doctor_profile_service.dart';


class DoctorProfileProvider extends ChangeNotifier {
  final _service = DoctorProfileService();

  Map<String, dynamic>? _doctorData;
  bool _isLoading = false;

  Map<String, dynamic>? get doctorData => _doctorData;
  bool get isLoading => _isLoading;

  Future<void> fetchDoctorProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.getDoctorProfile();
      _doctorData = data;
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
      await _service.saveDoctorProfile(data);
      _doctorData = data;
    } catch (e) {
      debugPrint("Error saving profile: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Stream<DocumentSnapshot> get doctorStream =>
      _service.getDoctorProfileStream();
}

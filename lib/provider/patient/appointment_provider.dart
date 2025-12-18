import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hospital_management_service_app/model/patient/appointment_model.dart';
import 'package:hospital_management_service_app/services/patient_services/appoinment_services.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService service = AppointmentService();

  //  PATIENT APPOINTMENTS 
  List<AppointmentModel> patientAppointments = [];

  // STATS
  int total = 0;
  int upcoming = 0;
  int completed = 0;

  StreamSubscription? _patientSub;

  void listenPatientAppointments(String patientId) {
    _patientSub?.cancel();

    _patientSub = service.getPatientAppointments(patientId).listen((data) {
      patientAppointments = data;

      //  CALCULATE STATS
      total = data.length;
      upcoming = data.where((e) => e.status == 'upcoming').length;
      completed = data.where((e) => e.status == 'completed').length;

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _patientSub?.cancel();
    super.dispose();
  }

  //  DATE & TIME
  DateTime selectedDate = DateTime.now();
  String selectedTime = "";

  void selectDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void selectTime(String time) {
    selectedTime = time;
    notifyListeners();
  }

  //  DOCTOR APPOINTMENTS 
  List<AppointmentModel> doctorAppointmentsList = [];

  Future<void> fetchDoctorAppointments(String doctorId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("appointments")
          .where("doctorId", isEqualTo: doctorId)
          .get();

      doctorAppointmentsList = snap.docs
          .map((doc) =>
              AppointmentModel.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint("ERROR fetching appointments: $e");
    }
  }
}

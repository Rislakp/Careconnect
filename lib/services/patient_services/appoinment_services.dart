import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hospital_management_service_app/model/patient/appointment_model.dart';

class AppointmentService {
  final firestore = FirebaseFirestore.instance;

  /// Book appointment
  Future<void> bookAppointment(AppointmentModel appointment) async {
    await firestore
        .collection("appointments")
        .doc(appointment.id)
        .set(appointment.toMap());
  }

  /// Get doctor appointments
  Stream<List<AppointmentModel>> getDoctorAppointments(String doctorId) {
    return firestore
        .collection("appointments")
        .where("doctorId", isEqualTo: doctorId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get patient appointments
  Stream<List<AppointmentModel>> getPatientAppointments(String patientId) {
    return firestore
        .collection("appointments")
        .where("patientId", isEqualTo: patientId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Update status
  Future<void> updateStatus(String id, String newStatus) async {
    await firestore.collection("appointments").doc(id).update({
      "status": newStatus,
    });
  }
}

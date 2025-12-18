import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String patientId;
  final String patientName;
  final Timestamp appointmentDate;
  final String time;
  final String status;

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.patientId,
    required this.patientName,
    required this.appointmentDate,
    required this.time,
    this.status = "Pending", required String notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'patientId': patientId,
      'patientName': patientName,
      'appointmentDate': appointmentDate,
      'time': time,
      'status': status,
    };
  }


  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      id: id,
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorSpecialization: map['doctorSpecialization'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      appointmentDate: map['appointmentDate'] ?? '',
      time: map['time'] ?? '',
      status: map['status'] ?? 'Pending', notes: '',
    );
  }

  get gender => null;

  get chatRoomId => null;

  get reason => null;
}

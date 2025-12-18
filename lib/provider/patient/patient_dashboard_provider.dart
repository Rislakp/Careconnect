import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PatientDashboardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore; 

  //  PATIENT
  String? patientId;
  void setPatientId(String id) {
    patientId = id;
  }

  // SPECIALIZATIONS 
  List<String> specializations = [];
  List<Map<String, dynamic>> doctors = [];
  Map<String, String> doctorStatus = {};
  bool isLoading = true;


  //  RECENT CHAT
  List<Map<String, dynamic>> recentChats = [];
  StreamSubscription? _chatSub;

  //  INIT 
  PatientDashboardProvider() {
    loadDoctorsAndSpecializations();
  }

  //  LOAD DOCTORS
  Future<void> loadDoctorsAndSpecializations() async {
    try {
      isLoading = true;
      notifyListeners();

      final snap = await _firestore.collection('doctors').get();

      doctors = snap.docs.map((d) {
        final data = d.data();
        return {
          'doctorId': d.id,
          'name': data['name'] ?? '',
          'specialization': data['specialization'] ?? '',
          'profile': data['profileImage'] ?? '',
        };
      }).toList();

      specializations =
          doctors.map((d) => d['specialization'] as String).toSet().toList()
            ..sort();

      _listenDoctorStatus();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      debugPrint("Dashboard load error: $e");
      notifyListeners();
    }
  }

  //DOCTOR STATUS
  void _listenDoctorStatus() {
    _firestore.collection("doctors").snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        final isOnline = doc['status']?['isOnline'] ?? false;
        doctorStatus[doc.id] = isOnline ? "Online" : "Offline";
      }
      notifyListeners();
    });
  }

  String getStatus(String doctorId) {
    return doctorStatus[doctorId] ?? "Offline";
  }

  List<Map<String, dynamic>> getDoctorsBySpecialization(String spec) {
    return doctors.where((d) => d['specialization'] == spec).toList();
  }

  // RECENT CHATS 
  void listenRecentChats(String patientId) {
    _chatSub?.cancel();

    _chatSub = _firestore
        .collection('chats')
        .where('users', arrayContains: patientId)
        .limit(5)
        .snapshots()
        .listen((snap) async {
      final List<Map<String, dynamic>> list = [];

      for (var doc in snap.docs) {
        final data = doc.data();
        final users = List<String>.from(data['users']);

        final otherUserId =
            users.firstWhere((u) => u != patientId, orElse: () => '');

        String doctorName = 'Doctor';

        if (otherUserId.isNotEmpty) {
          final d =
              await _firestore.collection('users').doc(otherUserId).get();
          if (d.exists) {
            doctorName =
                d['name'] ?? d['fullName'] ?? d['username'] ?? 'Doctor';
          }
        }

        list.add({
          'chatId': doc.id,
          'doctorId': otherUserId,
          'doctorName': doctorName,
          'lastMessage': data['lastMessage'] ?? '',
        });
      }

      recentChats = list;
      notifyListeners();
    });
  }

// UPCOMING APPOINTMENTS 
List<Map<String, dynamic>> upcomingAppointments = [];
StreamSubscription? _upcomingAppointmentSub;

void loadApprovedAppointments() {
    if (patientId == null) {
      debugPrint(" patientId null");
      return;
    }

    _upcomingAppointmentSub?.cancel();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    _upcomingAppointmentSub = _firestore
        .collection("appointments")
        .where("patientId", isEqualTo: patientId)
        .where("status", whereIn: ["Approved", "approved"])
        .where(
          "appointmentDate",
          isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
        )
        .orderBy("appointmentDate")
        .snapshots()
        .listen((snapshot) {
      debugPrint(" Appointments found: ${snapshot.docs.length}");

      final List<Map<String, dynamic>> temp = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        final doctor = doctors.firstWhere(
          (d) => d['doctorId'] == data['doctorId'],
          orElse: () => {'name': 'Doctor'},
        );

        data['doctorName'] = doctor['name'];
        temp.add(data);
      }

      upcomingAppointments = temp;
      notifyListeners();
    });
  }


@override
void dispose() {
  _upcomingAppointmentSub?.cancel(); 
  _chatSub?.cancel();
  super.dispose();
}
}
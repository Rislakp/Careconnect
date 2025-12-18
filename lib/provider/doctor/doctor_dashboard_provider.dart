import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorDashboardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;

  String doctorName = '';
  String specialization = '';

  int todayAppointments = 0;
  int totalPatients = 0;

  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> latestAppointments = [];
  List<Map<String, dynamic>> recentChats = [];

  StreamSubscription? _doctorSub;
  StreamSubscription? _appointmentSub;
  StreamSubscription? _chatSub;

  bool _doctorLoaded = false;
  bool _appointmentLoaded = false;
  bool _chatLoaded = false;

  // LOAD DASHBOARD 
  void loadDashboard(String doctorId) {
    isLoading = true;
    notifyListeners();

    _listenDoctor(doctorId);
    _listenAppointments(doctorId);
    _listenChats(doctorId);
  }

  //  DOCTOR 
  void _listenDoctor(String doctorId) {
    _doctorSub?.cancel();
    _doctorSub = _firestore
        .collection('doctors')
        .doc(doctorId)
        .snapshots()
        .listen((doc) {
          if (doc.exists) {
            final data = doc.data()!;
            doctorName = data['name'] ?? '';
            specialization = data['specialization'] ?? '';
            _doctorLoaded = true;
            _stopLoadingIfReady();
            notifyListeners();
          }
        });
  }

  //  APPOINTMENTS
  void _listenAppointments(String doctorId) {
    _appointmentSub?.cancel();
    _appointmentSub = _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .listen((snap) {
          _appointments = snap.docs
              .map((e) => {'id': e.id, ...e.data()})
              .where((a) => a['appointmentDate'] != null)
              .toList();

          // sort by date descending
          _appointments.sort((a, b) {
            final aDate = a['appointmentDate'];
            final bDate = b['appointmentDate'];
            if (aDate is Timestamp && bDate is Timestamp) {
              return bDate.compareTo(aDate);
            }
            return 0;
          });

          latestAppointments = _appointments.take(5).toList();

          final now = DateTime.now();

          todayAppointments = _appointments.where((a) {
            final t = a['appointmentDate'];
            if (t is! Timestamp) return false;
            final d = t.toDate();
            return d.year == now.year &&
                d.month == now.month &&
                d.day == now.day;
          }).length;

          totalPatients = _appointments
              .map((e) => e['patientId'])
              .toSet()
              .length;

          _appointmentLoaded = true;
          _stopLoadingIfReady();
          notifyListeners();
        });
  }

  // DATE FILTER FOR DASHBOARD 
  List<Map<String, dynamic>> appointmentsForDate(DateTime date) {
    return _appointments.where((a) {
      final t = a['appointmentDate'];
      if (t is! Timestamp) return false;
      final d = t.toDate();
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
  }

  // RECENT CHATS
  void _listenChats(String doctorId) {
    _chatSub?.cancel();
    _chatSub = _firestore
        .collection('chats')
        .where('users', arrayContains: doctorId)
        .limit(5)
        .snapshots()
        .listen((snap) async {
          recentChats = [];

          for (var doc in snap.docs) {
            final data = doc.data();
            final users = List<String>.from(data['users'] ?? []);
            final otherUserId = users.firstWhere(
              (u) => u != doctorId,
              orElse: () => '',
            );

            if (otherUserId.isEmpty) continue;

            //  Get patient name
            String patientName = 'Patient';
            final userDoc = await _firestore
                .collection('users')
                .doc(otherUserId)
                .get();
            if (userDoc.exists) {
              final u = userDoc.data()!;
              patientName =
                  u['name'] ?? u['fullName'] ?? u['username'] ?? 'Patient';
            }

            //  Check if appointment exists and approved
            final approvedSnap = await _firestore
                .collection('appointments')
                .where('doctorId', isEqualTo: doctorId)
                .where('patientId', isEqualTo: otherUserId)
                .where('status', isEqualTo: 'approved')
                .get();

            if (approvedSnap.docs.isEmpty)
              continue; 

            recentChats.add({
              'roomId': doc.id,
              'patientId': otherUserId,
              'patientName': patientName,
              'lastMessage': data['lastMessage'] ?? '',
            });
          }
          _chatLoaded = true;
          _stopLoadingIfReady();
          notifyListeners();
        });
  }

  //  STOP LOADING
  void _stopLoadingIfReady() {
    if (_doctorLoaded && _appointmentLoaded && _chatLoaded) {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _doctorSub?.cancel();
    _appointmentSub?.cancel();
    _chatSub?.cancel();
    super.dispose();
  }
}

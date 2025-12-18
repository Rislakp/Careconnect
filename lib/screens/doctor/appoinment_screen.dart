import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DoctorAppointmentScreen extends StatelessWidget {
  DoctorAppointmentScreen({super.key});

  final String doctorId = FirebaseAuth.instance.currentUser!.uid;
  final DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
    String patientId,
  ) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});

    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': patientId,
      'title': 'Appointment ${status.toUpperCase()}',
      'body': 'Your appointment has been $status',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff4A90E2), Color(0xff007AFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "My Appointments",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 45,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const TabBar(
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.white,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      tabs: [
                        Tab(text: "Today"),
                        Tab(text: "Tomorrow"),
                        Tab(text: "Past"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("appointments")
              .where("doctorId", isEqualTo: doctorId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            final today = dateFormat.format(DateTime.now());
            final tomorrow = dateFormat.format(
              DateTime.now().add(const Duration(days: 1)),
            );

            List<Map<String, dynamic>> todayList = [];
            List<Map<String, dynamic>> tomorrowList = [];
            List<Map<String, dynamic>> pastList = [];

            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;

              final ts = data['appointmentDate'];
              if (ts == null || ts is! Timestamp) continue;

              final date = ts.toDate();
              final dateString = dateFormat.format(date);

              if (dateString == today) {
                todayList.add(data);
              } else if (dateString == tomorrow) {
                tomorrowList.add(data);
              } else if (date.isBefore(DateTime.now())) {
                pastList.add(data);
              }
            }

            return TabBarView(
              children: [
                _buildList(todayList),
                _buildList(tomorrowList),
                _buildList(pastList),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text("No Appointments", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final data = items[index];
        final ts = data['appointmentDate'];
        final date = (ts != null && ts is Timestamp)
            ? ts.toDate()
            : DateTime.now();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF1F8FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const CircleAvatar(radius: 24, child: Icon(Icons.person)),
              const SizedBox(width: 14),

              /// PATIENT NAME
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(data['patientId'])
                          .get(),
                      builder: (context, snap) {
                        if (!snap.hasData || !snap.data!.exists) {
                          return const Text(
                            'Patient',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }

                        final u = snap.data!.data() as Map<String, dynamic>?;

                        final name =
                            u?['name'] ??
                            u?['fullName'] ??
                            u?['username'] ??
                            'Patient';

                        return Text(
                          name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),

                    Text("📅 ${DateFormat('yyyy-MM-dd').format(date)}"),
                    Text("⏰ ${data['time'] ?? '-'}"),
                  ],
                ),
              ),

              if (data['status'] == "pending")
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    final patientId = data['patientId'] ?? '';
                    await updateAppointmentStatus(
                      data['id'],
                      value == "accept" ? 'approved' : 'rejected',
                      patientId,
                    );
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "accept", child: Text("Accept")),
                    PopupMenuItem(value: "reject", child: Text("Reject")),
                  ],
                )
              else
                Chip(
                  label: Text(
                    data['status'].toString().toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: data['status'] == 'approved'
                      ? Colors.green
                      : Colors.red,
                ),
            ],
          ),
        );
      },
    );
  }
}

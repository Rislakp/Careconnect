import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_management_service_app/provider/patient/patient_dashboard_provider.dart';
import 'package:hospital_management_service_app/screens/patient/notification_screen.dart';
import 'package:hospital_management_service_app/widgets/patient/appointment_list_section.dart';
import 'package:hospital_management_service_app/widgets/patient/header_section.dart';
import 'package:hospital_management_service_app/widgets/patient/recent_chats_section.dart';
import 'package:hospital_management_service_app/widgets/patient/specialization_list.dart';
import 'package:provider/provider.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final dash = Provider.of<PatientDashboardProvider>(
    context,
    listen: false,
  );

  dash.setPatientId(uid);

   await dash.loadDoctorsAndSpecializations();
  dash.loadApprovedAppointments();            
});

}

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,

          title: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('patients')
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              return HeaderSection(name: data?['name'] ?? "Patient");
            },
          ),

          ///  NOTIFICATION 
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),

                  ///  UNREAD COUNT
                  Positioned(
                    right: 6,
                    top: 6,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('notifications')
                          .where('userId', isEqualTo: user.uid)
                          .where('isRead', isEqualTo: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const SizedBox();
                        }

                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            snapshot.data!.docs.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SpecializationList(),
           
            SizedBox(height: 24),
            AppointmentListSection(),
            SizedBox(height: 24),
            RecentChatsSection(),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_management_service_app/provider/doctor/doctor_dashboard_provider.dart';
import 'package:hospital_management_service_app/widgets/doctor/dashboard/appbar_widget.dart';
import 'package:hospital_management_service_app/widgets/doctor/dashboard/latest_appointment.dart';
import 'package:hospital_management_service_app/widgets/doctor/dashboard/profile_card_widget.dart';
import 'package:hospital_management_service_app/widgets/doctor/dashboard/recent_chats.dart';
import 'package:hospital_management_service_app/widgets/doctor/dashboard/stats_row_widget.dart';
import 'package:hospital_management_service_app/widgets/doctor/dashboard/week_calendar.dart';
import 'package:provider/provider.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late List<DateTime> weekDates;
  int selectedDateIndex = 0;

  @override
  void initState() {
    super.initState();
    weekDates = _generateCurrentWeek();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctorId = FirebaseAuth.instance.currentUser!.uid;
      context.read<DoctorDashboardProvider>().loadDashboard(doctorId);
    });
  }

  List<DateTime> _generateCurrentWeek() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday % 7));
    return List.generate(
      7,
      (i) => DateTime(start.year, start.month, start.day + i),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text("No doctor logged in")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: DoctorDashboardAppBar(userId: user!.uid),
      body: Consumer<DoctorDashboardProvider>(
        builder: (context, dp, _) {
          if (dp.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DoctorProfileCard(dp: dp),
                const SizedBox(height: 18),
                DoctorStatsRow(dp: dp),
                const SizedBox(height: 18),
                WeekCalendar(
                  weekDates: weekDates,
                  selectedIndex: selectedDateIndex,
                  onSelect: (i) => setState(() => selectedDateIndex = i),
                ),
                const SizedBox(height: 20),
                LatestAppointmentsSection(dp: dp),
                const SizedBox(height: 25),
                RecentChatsSection(dp: dp),
              ],
            ),
          );
        },
      ),
    );
  }
}

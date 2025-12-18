import 'package:flutter/material.dart';
import 'package:hospital_management_service_app/provider/doctor/doctor_dashboard_provider.dart';
import 'package:hospital_management_service_app/widgets/doctor/dashboard/stat_card.dart';

class DoctorStatsRow extends StatelessWidget {
  final DoctorDashboardProvider dp;

  const DoctorStatsRow({
    super.key,
    required this.dp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatCard(
          title: "Today's\nAppointments",
          value: dp.todayAppointments.toString(),
          icon: Icons.calendar_today,
        ),
        const SizedBox(width: 12),
        StatCard(
          title: "Total\nPatients",
          value: dp.totalPatients.toString(),
          icon: Icons.people,
        ),
      ],
    );
  }
}

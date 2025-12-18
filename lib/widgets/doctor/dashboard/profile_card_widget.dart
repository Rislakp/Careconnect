import 'package:flutter/material.dart';
import 'package:hospital_management_service_app/provider/doctor/doctor_dashboard_provider.dart';

class DoctorProfileCard extends StatelessWidget {
  final DoctorDashboardProvider dp;
  const DoctorProfileCard({super.key, required this.dp});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 36,
              child: Icon(Icons.person, size: 36),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dr. ${dp.doctorName}",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(dp.specialization),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

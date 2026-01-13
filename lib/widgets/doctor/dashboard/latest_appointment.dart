import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hospital_management_service_app/provider/doctor/doctor_dashboard_provider.dart';
import 'package:hospital_management_service_app/widgets/doctor/dashboard/status_chip.dart';

class LatestAppointmentsSection extends StatelessWidget {
  final DoctorDashboardProvider dp;
  const LatestAppointmentsSection({super.key, required this.dp});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Latest Appointments",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (dp.latestAppointments.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text("No recent appointments"),
          )
        else
          Column(
            children: dp.latestAppointments.map((a) {
              final Timestamp? ts = a['appointmentDate'];
              if (ts == null) return const SizedBox();
              final d = ts.toDate();

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(a['patientName'] ?? 'Patient'),
                  subtitle: Text(
                    "${d.day}/${d.month}/${d.year} • ${a['time']}",
                  ),
                  trailing: statusChip(a['status']),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

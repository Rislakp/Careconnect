import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hospital_management_service_app/provider/patient/patient_dashboard_provider.dart';

class AppointmentListSection extends StatelessWidget {
  const AppointmentListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PatientDashboardProvider>(context);
    final appointments = provider.upcomingAppointments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upcoming Appointments",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        if (appointments.isEmpty)
          const Center(
            child: Text("No upcoming approved appointments"),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final data = appointments[index];
              final date =
                  (data['appointmentDate'] as Timestamp).toDate();

              return Card(
                child: ListTile(
                  title: Text(
                    "Dr. ${data['doctorName']}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(date),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              );
            },
          ),
      ],
    );
  }
}

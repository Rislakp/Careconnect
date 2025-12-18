import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_management_service_app/provider/patient/patient_dashboard_provider.dart';
import 'package:hospital_management_service_app/screens/doctor/chat_screen.dart';
import 'package:hospital_management_service_app/services/chat/chat_services.dart';
import 'package:provider/provider.dart';

class DoctorListBySpecialization extends StatelessWidget {
  final String specialization;

  const DoctorListBySpecialization({super.key, required this.specialization});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientDashboardProvider>();
    final filteredDoctors = provider.getDoctorsBySpecialization(specialization);

    return Scaffold(
      appBar: AppBar(
        title: Text("$specialization Doctors"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: filteredDoctors.isEmpty
          ? const Center(
              child: Text(
                "No doctors available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                final doc = filteredDoctors[index];

                final doctorId = doc['doctorId'] ?? "";
                final name = doc['name'] ?? "Unknown";
                final doctorSpecialization =
                    doc['specialization'] ?? "Not Available";
                final profile = doc['profile'] ?? "";
                final status = provider.getStatus(doctorId);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Doctor Info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundImage: profile.isNotEmpty
                                  ? NetworkImage(profile)
                                  : null,
                              backgroundColor: Colors.blue.shade50,
                              child: profile.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 32,
                                      color: Colors.blueAccent,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    doctorSpecialization,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: status == "Online"
                                    ? Colors.green
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _gradientButton(
                              icon: Icons.message,
                              label: "Message",
                              gradient: const LinearGradient(
                                colors: [Colors.blue, Colors.lightBlueAccent],
                              ),
                              onTap: () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) return;

                                final patientId = user.uid;

                                //  chatId
                                final chatId = ChatService().createChatId(
                                  doctorId,
                                  patientId,
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      otherUserId: doctorId,
                                      chatId: chatId,
                                      otherUserName: name,
                                    ),
                                  ),
                                );
                              },
                            ),

                            _gradientButton(
                              icon: Icons.calendar_month,
                              label: "Book",
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.purple,
                                  Colors.deepPurpleAccent,
                                ],
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  "/bookAppointment",
                                  arguments: {
                                    "doctorId": doctorId,
                                    "doctorName": name,
                                    "specialization": doctorSpecialization,
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Button builder ------------------------------
  Widget _gradientButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

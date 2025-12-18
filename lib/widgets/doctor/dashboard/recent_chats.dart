import 'package:flutter/material.dart';
import 'package:hospital_management_service_app/provider/doctor/doctor_dashboard_provider.dart';
import 'package:hospital_management_service_app/screens/doctor/chat_screen.dart';

class RecentChatsSection extends StatelessWidget {
  final DoctorDashboardProvider dp;
  const RecentChatsSection({super.key, required this.dp});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recent Chats",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (dp.recentChats.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text("No recent chats"),
          )
        else
          Column(
            children: dp.recentChats.map((c) {
              return Card(
                child: ListTile(
                  title: Text(c['patientName']),
                  subtitle: Text(c['lastMessage']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chatId: c['roomId'],
                          otherUserId: c['patientId'],
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

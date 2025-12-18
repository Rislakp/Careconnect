import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorNotificationScreen extends StatelessWidget {
  DoctorNotificationScreen({super.key});

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No doctor logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No notifications found"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final isRead = data['isRead'] ?? false;

              return GestureDetector(
                onTap: () {
                  // Mark notification as read
                  if (!isRead) {
                    FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(docs[index].id)
                        .update({'isRead': true});
                  }
                },
                child: Card(
                  color: isRead ? Colors.grey.shade200 : Colors.white,
                  child: ListTile(
                    leading: Icon(
                      data['type'] == 'reminder' ? Icons.notifications : Icons.info,
                      color: isRead ? Colors.grey : Colors.blue,
                    ),
                    title: Text(
                      data['title'] ?? 'Notification',
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(data['body'] ?? ''),
                    trailing: Text(
                      data['appointmentTime'] != null
                          ? _formatTimestamp(data['appointmentTime'])
                          : '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      return "${dt.day}-${dt.month}-${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    }
    return '';
  }
}

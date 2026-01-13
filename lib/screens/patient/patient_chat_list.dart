import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_management_service_app/screens/doctor/chat_screen.dart';


class PatientChatListScreen extends StatelessWidget {
  final String patientId = FirebaseAuth.instance.currentUser!.uid;

  Future<String> getDoctorName(String doctorId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(doctorId).get();

    if (!doc.exists || doc.data() == null) return doctorId;

    final data = doc.data()!;

    if (data.containsKey('name') && data['name'] != null && data['name'] != "") return data['name'];
    if (data.containsKey('fullName') && data['fullName'] != null && data['fullName'] != "") return data['fullName'];
    if (data.containsKey('username') && data['username'] != null && data['username'] != "") return data['username'];
    if (data.containsKey('patientName') && data['patientName'] != null && data['patientName'] != "") return data['DoctorName'];

    return doctorId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: patientId)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return Center(
              child: Text(
                'No chats yet',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final users = List<String>.from(chat['users']);
              final doctorId = users.firstWhere((id) => id != patientId);

              return FutureBuilder<String>(
                future: getDoctorName(doctorId),
                builder: (context, snapshotName) {
                  final doctorName = snapshotName.hasData ? snapshotName.data! : doctorId;

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[200],
                        child: Text(
                          doctorName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        ' $doctorName',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        chat['lastMessage'] ?? 'No messages yet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: Icon(Icons.chat, color: Colors.blueAccent),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chat.id,
                              otherUserId: doctorId,
                              otherUserName: doctorName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

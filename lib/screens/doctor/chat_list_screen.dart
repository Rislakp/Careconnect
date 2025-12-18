import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorChatListScreen extends StatelessWidget {
  final String doctorId = FirebaseAuth.instance.currentUser!.uid;

  Future<String> getPatientName(String patientId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(patientId)
        .get();

    if (!doc.exists || doc.data() == null) return patientId;

    final data = doc.data()!;

    if (data.containsKey('name') && data['name'] != null && data['name'] != "") {
      return data['name'];
    }
    if (data.containsKey('fullName') && data['fullName'] != null && data['fullName'] != "") {
      return data['fullName'];
    }
    if (data.containsKey('username') && data['username'] != null && data['username'] != "") {
      return data['username'];
    }
    if (data.containsKey('patientName') && data['patientName'] != null && data['patientName'] != "") {
      return data['patientName'];
    }

    return patientId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Chats'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: doctorId)
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
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final users = List<String>.from(chat['users']);
              final patientId = users.firstWhere((id) => id != doctorId);

              return FutureBuilder<String>(
                future: getPatientName(patientId),
                builder: (context, snapshotName) {
                  final patientName = snapshotName.hasData ? snapshotName.data! : patientId;

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          patientName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        patientName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        chat['lastMessage'] ?? 'No messages yet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(Icons.chat_bubble, color: Colors.blueAccent),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chat.id,
                              otherUserId: patientId,
                              otherUserName: patientName,
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_management_service_app/screens/patient/patient_chat_screen.dart';
import 'package:hospital_management_service_app/services/chat/chat_services.dart';
import 'package:intl/intl.dart';

class RecentChatsSection extends StatelessWidget {
  const RecentChatsSection({super.key});

  get c => null;

  String formatTime(Timestamp? ts) {
    if (ts == null) return '';
    return DateFormat('hh:mm a').format(ts.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final chatService = ChatService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Chats",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .where('users', arrayContains: currentUserId)
              .orderBy('lastMessageTime', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Text("No recent chats");
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;

                final users = List<String>.from(data['users']);
                final otherUserId = users.firstWhere((u) => u != currentUserId);

                return FutureBuilder<String>(
                  future: chatService.getUserName(otherUserId),
                  builder: (context, nameSnap) {
                    final name = nameSnap.data ?? "User";

                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(name),
                        subtitle: Text(
                          data['lastMessage'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          formatTime(data['lastMessageTime']),
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                chatId: doc.id, 
                                otherUserId: otherUserId, 
                                otherUserName: name,
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
      ],
    );
  }
}

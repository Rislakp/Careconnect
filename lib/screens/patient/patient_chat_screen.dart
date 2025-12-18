import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_management_service_app/services/chat/chat_services.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String? otherUserName;

  ChatScreen({
    required this.chatId,
    required this.otherUserId,
    this.otherUserName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String otherUserName = 'Chat';

  @override
  void initState() {
    super.initState();
    otherUserName = widget.otherUserName ?? 'Chat';
    if (widget.otherUserName == null) {
      _loadOtherUserName();
    }
    markMessagesAsRead();
  }

  void _loadOtherUserName() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.otherUserId)
        .get();
    if (!doc.exists || doc.data() == null) return;

    final data = doc.data() ?? {};
    String name = widget.otherUserId;

    if (data['name'] != null && data['name'].toString().isNotEmpty) {
      name = data['name'];
    } else if (data['fullName'] != null &&
        data['fullName'].toString().isNotEmpty) {
      name = data['fullName'];
    } else if (data['username'] != null &&
        data['username'].toString().isNotEmpty) {
      name = data['username'];
    } else if (data['patientName'] != null &&
        data['patientName'].toString().isNotEmpty) {
      name = data['patientName'];
    }

    setState(() {
      otherUserName = name;
    });
  }

  String formatTimestamp(Timestamp timestamp) {
    return DateFormat('hh:mm a').format(timestamp.toDate());
  }

  void markMessagesAsRead() async {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages');

    final unreadMessages = await messagesRef
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var msg in unreadMessages.docs) {
      await msg.reference.update({'isRead': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(otherUserName),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent),
                  );
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final data = msg.data() as Map<String, dynamic>? ?? {};

                    final bool isMe = data['senderId'] == currentUserId;
                    final bool isRead = data['isRead'] == true;
                    final Timestamp? ts = data['timestamp'];
                    final String time = ts != null ? formatTimestamp(ts) : '';

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[400] : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                            bottomLeft: isMe
                                ? Radius.circular(14)
                                : Radius.circular(0),
                            bottomRight: isMe
                                ? Radius.circular(0)
                                : Radius.circular(14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                data['senderName'] ?? "Unknown",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            SizedBox(height: 3),
                            Text(
                              data['message'] ?? "",
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  time,
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontSize: 10,
                                  ),
                                ),
                                if (isMe) SizedBox(width: 6),
                                if (isMe)
                                  Icon(
                                    isRead ? Icons.done_all : Icons.done,
                                    size: 16,
                                    color: isRead
                                        ? Colors.lightGreenAccent
                                        : Colors.white70,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () async {
                      if (_controller.text.trim().isEmpty) return;

                      await _chatService.sendMessage(
                        chatId: widget.chatId,
                        senderId: currentUserId,
                        receiverId: widget.otherUserId,
                        message: _controller.text.trim(),
                      );
                      _controller.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String createChatId(String doctorId, String patientId) {
    return doctorId.hashCode <= patientId.hashCode
        ? '${doctorId}_$patientId'
        : '${patientId}_$doctorId';
  }

  // FETCH USER NAME 
  Future<String> getUserName(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists || doc.data() == null) return userId;

    final data = doc.data()!;
    return data['fullName'] ??
        data['username'] ??
        data['patientName'] ??
        userId;
  }

  // SEND MESSAGE
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').add(
      {
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'senderName': await getUserName(senderId), 
      },
    );

    // Update main chat document
    await _firestore.collection('chats').doc(chatId).set({
      'users': [senderId, receiverId],
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // GET MESSAGES STREAM
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp", descending: true) 
        .snapshots();
  }

  // CHAT LIST STREAM
  Stream<QuerySnapshot> getChatList(String userId) {
    return _firestore
        .collection("chats")
        .where("users", arrayContains: userId)
        .orderBy("lastMessageTime", descending: true)
        .snapshots();
  }
}

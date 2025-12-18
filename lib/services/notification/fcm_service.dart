import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Save token to user document
  Future<void> saveToken({required String userId, required String role}) async {
    await _fcm.requestPermission();
    String? token = await _fcm.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection(role == "patient" ? "patients" : "doctors")
          .doc(userId)
          .update({'fcmToken': token});
    }
  }

  /// Add a notification in Firestore
  Future<void> addNotification({
    required String userId,
    required String title,
    required String body,
    required String type, // booked, cancelled, reminder
    DateTime? appointmentTime,
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'appointmentTime':
          appointmentTime != null ? Timestamp.fromDate(appointmentTime) : null,
    });
  }
  
}

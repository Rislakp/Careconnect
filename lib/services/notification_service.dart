import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initNotifications(String uid, String role) async {
    await _fcm.requestPermission();

    String? token = await _fcm.getToken();

    if (token != null) {
      await _firestore.collection('users').doc(uid).set({
        'fcmToken': token,
        'role': role,
      }, SetOptions(merge: true));
    }

    FirebaseMessaging.onMessage.listen((message) {
      print('Notification: ${message.notification?.title}');
    });
  }
}

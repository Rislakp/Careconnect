import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hospital_management_service_app/screens/doctor/notification_screen.dart';

class DoctorDashboardAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String userId;
  const DoctorDashboardAppBar({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: const Text("Doctor Dashboard",
          style: TextStyle(color: Colors.black)),
      actions: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .snapshots(),
          builder: (context, snapshot) {
            final unread =
                snapshot.hasData ? snapshot.data!.docs.length : 0;

            return Stack(
              children: [
                IconButton(
                  icon:
                      const Icon(Icons.notifications, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorNotificationScreen(),
                      ),
                    );
                  },
                ),
                if (unread > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.red,
                      child: Text(
                        unread.toString(),
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

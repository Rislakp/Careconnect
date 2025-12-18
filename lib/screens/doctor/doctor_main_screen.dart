import 'package:flutter/material.dart';
import 'package:hospital_management_service_app/screens/doctor/appoinment_screen.dart';
import 'package:hospital_management_service_app/screens/doctor/chat_list_screen.dart';
import 'package:hospital_management_service_app/screens/doctor/dashboard_screen.dart';
import 'package:hospital_management_service_app/screens/doctor/profile/profile_screen.dart';


class DoctorMainScreen extends StatefulWidget {
  const DoctorMainScreen({Key? key, required this.userName}) : super(key: key);

  final String userName;

  @override
  State<DoctorMainScreen> createState() => _DoctorMainScreenState();
}

class _DoctorMainScreenState extends State<DoctorMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
   // final currentDoctorId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

    final List<Widget> screens = [
      const DoctorDashboardScreen(),
      DoctorAppointmentScreen(),
      DoctorChatListScreen(),
      const DoctorProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: screens[_currentIndex],

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            selectedFontSize: 13,
            unselectedFontSize: 12,
            elevation: 0,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Appointments',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

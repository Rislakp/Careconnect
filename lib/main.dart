import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hospital_management_service_app/firebase_options.dart';
import 'package:hospital_management_service_app/provider/doctor/doctor_dashboard_provider.dart';
import 'package:hospital_management_service_app/provider/doctor/doctor_profile_provider.dart';
import 'package:hospital_management_service_app/provider/patient/appointment_provider.dart';
import 'package:hospital_management_service_app/provider/patient/patient_dashboard_provider.dart';
import 'package:hospital_management_service_app/provider/patient/patient_details_provider.dart';
import 'package:hospital_management_service_app/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;


///  BACKGROUND NOTIFICATION HANDLER 
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //  Register background notifications
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientDashboardProvider()),
        ChangeNotifierProvider(create: (_) => DoctorDashboardProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProfileProvider()),
        ChangeNotifierProvider(create: (_) => PatientDetailsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hospital Management',
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.appRoutes,
      ),
    );
  }
}

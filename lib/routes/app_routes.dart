import 'package:flutter/material.dart';
import 'package:hospital_management_service_app/screens/auth/Login.dart';
import 'package:hospital_management_service_app/screens/auth/forgot_password.dart';
import 'package:hospital_management_service_app/screens/auth/signup.dart';
import 'package:hospital_management_service_app/screens/doctor/dashboard_screen.dart';
import 'package:hospital_management_service_app/screens/doctor/profile/doctor_profile_details.dart';
import 'package:hospital_management_service_app/screens/patient/Patient_Appointment_Screen.dart';
import 'package:hospital_management_service_app/screens/patient/patient_main_screen.dart';
import 'package:hospital_management_service_app/screens/patient/profile/patient_details.dart';
import 'package:hospital_management_service_app/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String ForgotPassword = '/forgotpassword';

  //doctor
  static const String doctorDetails = '/doctorDetails';
  static const String doctorMainScreen = '/DoctorDashboard';
  static const String addPatient = '/addpatient';

  //patient
  static const String patientDetails = '/patientDetails';
  static const String patientMainScreen = '/PatientDashboard';
  static const String editProfile = '/editProfile';
  static const String chatScreen = '/chatScreen';
 
  static const String bookAppointment = '/bookAppointment';

  static Map<String, WidgetBuilder> appRoutes = {
    splash: (context) => const SplashScreen(),
    login: (context) => LoginScreen(),
    signup: (context) => const SignUpScreen(),
    ForgotPassword: (context) => ForgotPasswordScreen(),

    //doctor sections
    doctorMainScreen: (context) => const DoctorDashboardScreen(),
    doctorDetails: (context) => DoctorProfileDetailsScreen(),

    //patient sections
    patientMainScreen: (context) => const PatientMainScreen(),
    patientDetails: (context) => const PatientProfileDetailsScreen(),
    bookAppointment: (context) => const PatientAppointmentScreen(),
  };
}

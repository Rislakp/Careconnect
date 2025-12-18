import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_management_service_app/screens/doctor/doctor_main_screen.dart';

class DoctorProfileDetailsScreen extends StatefulWidget {
  const DoctorProfileDetailsScreen({super.key});

  @override
  State<DoctorProfileDetailsScreen> createState() =>
      _DoctorProfileDetailsScreenState();
}

class _DoctorProfileDetailsScreenState
    extends State<DoctorProfileDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final workingTimeController = TextEditingController();
  final workingTillController = TextEditingController();

  String? selectedSpecialization;
  bool loading = false;

  final List<String> specializations = [
    "Cardiologist",
    "Dermatologist",
    "Neurologist",
    "Orthopedic",
    "Pediatrician",
    "General Physician",
    "Psychiatrist",
    "ENT Specialist",
    "Gynecologist",
    "Oncologist",
  ];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email ?? "";
    }
  }

  String email = "";

  Future<void> saveDoctorData(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("User not logged in")));
        return;
      }

      await FirebaseFirestore.instance.collection('doctors').doc(user.uid).set({
        'uid': user.uid,
        'name': nameController.text.trim(),
        'specialization': selectedSpecialization,
        'email': email,
        'number': numberController.text.trim(),
        'working_time': workingTimeController.text.trim(),
        'working_till': workingTillController.text.trim(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DoctorMainScreen(userName: ''),
        ),
      );
    } catch (e) {
      debugPrint("Error saving data: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Doctor Profile Details"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Name",
                    border: OutlineInputBorder(),),
                    validator: (v) =>
                        v!.isEmpty ? "Enter your name" : null,
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedSpecialization,
                    decoration: const InputDecoration(
                      labelText: "Specialization",
                      border: OutlineInputBorder(),
                    ),
                    items: specializations.map((spec) {
                      return DropdownMenuItem(
                        value: spec,
                        child: Text(spec),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedSpecialization = value);
                    },
                    validator: (v) =>
                        v == null ? "Select specialization" : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    initialValue: email,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: "Email (Auto-filled)",
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: numberController,
                    decoration:
                        const InputDecoration(labelText: "Phone Number",
                        border: OutlineInputBorder(),),
                    validator: (v) =>
                        v!.isEmpty ? "Enter phone number" : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: workingTimeController,
                    decoration: const InputDecoration(
                      labelText: "Working From (e.g. 9:00 AM)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Enter starting time" : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: workingTillController,
                    decoration: const InputDecoration(
                      labelText: "Working Till (e.g. 6:00 PM)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Enter ending time" : null,
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: loading ? null : () => saveDoctorData(context),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Save",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

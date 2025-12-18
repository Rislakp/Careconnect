import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_management_service_app/screens/patient/patient_main_screen.dart';

class PatientProfileDetailsScreen extends StatefulWidget {
  const PatientProfileDetailsScreen({super.key});

  @override
  State<PatientProfileDetailsScreen> createState() =>
      _PatientProfileDetailsScreenState();
}

class _PatientProfileDetailsScreenState
    extends State<PatientProfileDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  String email = "";
  bool loading = false;

  String? selectedGender;
  String? selectedBloodGroup;

  final List<String> genderList = ["Male", "Female", "Other"];

  final List<String> bloodGroups = [
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-",
  ];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    email = user?.email ?? "";
  }

  Future<void> savePatientData(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        return;
      }

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'name': nameController.text.trim(),
            'age': ageController.text.trim(),
            'gender': selectedGender,
            'blood_group': selectedBloodGroup,
            'phone': phoneController.text.trim(),
            'email': email,
            'address': addressController.text.trim(),
            'createdAt': DateTime.now(),
          }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PatientMainScreen()),
      );
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
        title: const Text("Patient Profile Details"),
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
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Enter your full name" : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: ageController,
                    decoration: const InputDecoration(
                      labelText: "Age",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Enter age" : null,
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: const InputDecoration(
                      labelText: "Gender",
                      border: OutlineInputBorder(),
                    ),
                    items: genderList.map((g) {
                      return DropdownMenuItem(value: g, child: Text(g));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedGender = value);
                    },
                    validator: (v) => v == null ? "Select gender" : null,
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedBloodGroup,
                    decoration: const InputDecoration(
                      labelText: "Blood Group",
                      border: OutlineInputBorder(),
                    ),
                    items: bloodGroups.map((bg) {
                      return DropdownMenuItem(value: bg, child: Text(bg));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedBloodGroup = value);
                    },
                    validator: (v) => v == null ? "Select blood group" : null,
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
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Enter phone number" : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: "Address",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (v) => v!.isEmpty ? "Enter address" : null,
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
                    onPressed: loading ? null : () => savePatientData(context),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Save Details",
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

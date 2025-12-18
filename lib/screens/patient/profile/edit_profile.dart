import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientEditProfileScreen extends StatefulWidget {
  const PatientEditProfileScreen({super.key});

  @override
  State<PatientEditProfileScreen> createState() =>
      _PatientEditProfileScreenState();
}

class _PatientEditProfileScreenState extends State<PatientEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  String? selectedGender;
  String? selectedBloodGroup;
  String email = "";

  bool loading = true;
  bool saving = false;

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
    loadPatientData();
  }

  Future<void> loadPatientData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    email = user.email ?? "";

    final doc = await FirebaseFirestore.instance
        .collection('patients')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = data['name'] ?? "";
      ageController.text = data['age'] ?? "";
      phoneController.text = data['phone'] ?? "";
      addressController.text = data['address'] ?? "";
      selectedGender = data['gender'];
      selectedBloodGroup = data['blood_group'];
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> updatePatientData(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(user.uid)
          .update({
            'name': nameController.text.trim(),
            'age': ageController.text.trim(),
            'gender': selectedGender,
            'blood_group': selectedBloodGroup,
            'phone': phoneController.text.trim(),
            'address': addressController.text.trim(),
            'updatedAt': DateTime.now(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter your full name" : null,
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

              DropdownButtonFormField(
                value: selectedGender,
                items: genderList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => selectedGender = value),
                validator: (v) => v == null ? "Select gender" : null,
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField(
                value: selectedBloodGroup,
                items: bloodGroups
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: "Blood Group",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) =>
                    setState(() => selectedBloodGroup = value),
                validator: (v) => v == null ? "Select blood group" : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                initialValue: email,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
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

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: saving ? null : () => updatePatientData(context),
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

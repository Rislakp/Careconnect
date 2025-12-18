import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorProfileEditScreen extends StatefulWidget {
  const DoctorProfileEditScreen({super.key});

  @override
  State<DoctorProfileEditScreen> createState() =>
      _DoctorProfileEditScreenState();
}

class _DoctorProfileEditScreenState extends State<DoctorProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final specializationController = TextEditingController();
  final numberController = TextEditingController();
  final workingTimeController = TextEditingController();
  final workingTillController = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(user.uid)
        .get();
    final data = doc.data();
    if (data != null) {
      nameController.text = data['name'] ?? '';
      specializationController.text = data['specialization'] ?? '';
      numberController.text = data['number'] ?? '';
      workingTimeController.text = data['working_time'] ?? '';
      workingTillController.text = data['working_till'] ?? '';
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(user.uid)
        .update({
          'name': nameController.text.trim(),
          'specialization': specializationController.text.trim(),
          'number': numberController.text.trim(),
          'working_time': workingTimeController.text.trim(),
          'working_till': workingTillController.text.trim(),
        });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
      Navigator.pop(context);
    }

    setState(() => loading = false);
  }

  InputDecoration boxDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        title: const Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: nameController,
                decoration: boxDecoration("Name"),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: specializationController,
                decoration: boxDecoration("Specialization"),
                validator: (v) => v!.isEmpty ? "Enter specialization" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: numberController,
                decoration: boxDecoration("Phone"),
                validator: (v) => v!.isEmpty ? "Enter phone number" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: workingTimeController,
                decoration: boxDecoration("Working From"),
                validator: (v) => v!.isEmpty ? "Enter start time" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: workingTillController,
                decoration: boxDecoration("Working Till"),
                validator: (v) => v!.isEmpty ? "Enter end time" : null,
              ),
              const SizedBox(height: 27),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: loading ? null : _updateProfile,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

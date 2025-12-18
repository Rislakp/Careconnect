import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_management_service_app/model/patient/appointment_model.dart';
import 'package:hospital_management_service_app/services/notification/fcm_service.dart';
import 'package:hospital_management_service_app/services/patient_services/appoinment_services.dart';
import 'package:table_calendar/table_calendar.dart';

class PatientAppointmentScreen extends StatefulWidget {
  const PatientAppointmentScreen({super.key});

  @override
  State<PatientAppointmentScreen> createState() =>
      _PatientAppointmentScreenState();
}

class _PatientAppointmentScreenState extends State<PatientAppointmentScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int selectedTimeIndex = 0;
  TextEditingController notesController = TextEditingController();

  String? selectedDoctorId;
  String? selectedDoctorName;
  String? selectedDoctorSpecialization;

  final List<String> timeSlots = [
    "8:30 AM",
    "9:00 AM",
    "9:30 AM",
    "10:00 AM",
    "10:30 AM",
    "11:00 AM",
    "11:30 AM",
    "12:00 PM",
    "12:30 PM",
    "2:00 PM",
    "2:30 PM",
    "3:00 PM",
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xfff3f6fd),
      appBar: AppBar(
        backgroundColor: const Color(0xfff3f6fd),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Book Appointment",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Doctor",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Doctor dropdown
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("doctors")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final docs = snapshot.data!.docs;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: _boxDecoration(),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedDoctorId,
                    hint: const Text("Choose a doctor"),
                    underline: const SizedBox(),
                    items: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(
                          "${data['name']} (${data['specialization']})",
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDoctorId = value;
                        final docData =
                            docs.firstWhere((d) => d.id == value).data()
                                as Map<String, dynamic>;
                        selectedDoctorName = docData['name'];
                        selectedDoctorSpecialization =
                            docData['specialization'];
                      });
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 25),

            // Calendar
            Text("Select Date & Time", style: _titleStyle()),
            const SizedBox(height: 12),
            Container(
              decoration: _boxDecoration(),
              child: TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Time slots
            Wrap(
              spacing: 10,
              runSpacing: 12,
              children: List.generate(timeSlots.length, (index) {
                final isSelected = selectedTimeIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedTimeIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      timeSlots[index],
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),

            // Notes
            Text("Notes (Optional)", style: _titleStyle()),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: _boxDecoration(),
              height: 110,
              child: TextField(
                controller: notesController,
                maxLines: 6,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Add any notes for this appointment...",
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Book Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedDoctorId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select a doctor")),
                    );
                    return;
                  }
                  if (_selectedDay == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select a date")),
                    );
                    return;
                  }

                  final Timestamp appointmentDate = Timestamp.fromDate(
                    DateTime(
                      _selectedDay!.year,
                      _selectedDay!.month,
                      _selectedDay!.day,
                    ),
                  );

                  final selectedTime = timeSlots[selectedTimeIndex];

                  final appointment = AppointmentModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    doctorId: selectedDoctorId!,
                    doctorName: selectedDoctorName ?? "",
                    doctorSpecialization: selectedDoctorSpecialization ?? "",
                    patientId: user!.uid,
                    patientName: user.displayName ?? "Patient",
                    appointmentDate: appointmentDate,
                    time: selectedTime,
                    notes: notesController.text,
                    status: "pending",
                  );

                  await AppointmentService().bookAppointment(appointment);

                  // Notifications
                  final appointmentDateTime = DateTime(
                    _selectedDay!.year,
                    _selectedDay!.month,
                    _selectedDay!.day,
                    int.parse(selectedTime.split(":")[0]) +
                        (selectedTime.contains("PM") &&
                                !selectedTime.startsWith("12")
                            ? 12
                            : 0),
                    selectedTime.contains(":30") ? 30 : 0,
                  );

                  await FCMService().addNotification(
                    userId: user.uid,
                    title: "Appointment Booked",
                    body:
                        "Your appointment with Dr. ${selectedDoctorName ?? ""} is confirmed",
                    type: "booking",
                    appointmentTime: appointmentDateTime,
                  );

                  await FCMService().addNotification(
                    userId: selectedDoctorId!,
                    title: "New Appointment",
                    body:
                        "You have a new appointment with ${user.displayName ?? "a patient"}",
                    type: "booking",
                    appointmentTime: appointmentDateTime,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Appointment Booked Successfully"),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Confirm Appointment",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey.shade300),
  );

  TextStyle _titleStyle() =>
      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hospital_management_service_app/provider/patient/patient_dashboard_provider.dart';
import 'package:hospital_management_service_app/screens/patient/specialization/doctor_list_screen.dart';
import 'package:provider/provider.dart';

class SpecializationList extends StatefulWidget {
  const SpecializationList({super.key});

  @override
  State<SpecializationList> createState() => _SpecializationListState();
}

class _SpecializationListState extends State<SpecializationList> {
  String? selectedSpecialization;

  @override
  Widget build(BuildContext context) {
    final specs = context.watch<PatientDashboardProvider>().specializations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "Top Specializations",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 55,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: specs.length,
            itemBuilder: (context, index) {
              final spec = specs[index];
              final isSelected = selectedSpecialization == spec;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSpecialization = spec;
                  });

                  // Navigate to doctor list screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DoctorListBySpecialization(specialization: spec),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.shade600
                        : Colors.blue.shade400.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      spec,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

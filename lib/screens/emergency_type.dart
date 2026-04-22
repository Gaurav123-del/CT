
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/emergency_contact.dart';
import 'main_monitoring_screen.dart';

class EmergencyTypeScreen extends StatefulWidget {
  final List<EmergencyContact> contacts;

  const EmergencyTypeScreen({super.key, required this.contacts});

  @override
  State<EmergencyTypeScreen> createState() => _EmergencyTypeScreenState();
}

class _EmergencyTypeScreenState extends State<EmergencyTypeScreen> {
  List<String> emergencyTypes = [
    "Cardiac Arrest",
    "Harassment",
    "Theft",
    "Accident",
    "Medical Emergency",
    "Fire",
    "Kidnapping",
  ];

  Set<String> selectedTypes = {};

  void toggleSelection(String type) {
    setState(() {
      if (selectedTypes.contains(type)) {
        selectedTypes.remove(type);
      } else {
        selectedTypes.add(type);
      }
    });
  }

  void _continue() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainMonitoringScreen(
          contacts: widget.contacts,
          // later you can pass selectedTypes also
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar (3rd step)
              Row(
                children: List.generate(3, (index) {
                  final isActive = index <= 2;
                  return Expanded(
                    child: Container(
                      margin:
                          EdgeInsets.only(right: index < 2 ? 6 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: isActive
                            ? AppTheme.green
                            : AppTheme.borderColor,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 28),

              const Text(
                "Emergency Types",
                style: AppTheme.headingLarge,
              ),

              const SizedBox(height: 8),

              const Text(
                "Select situations you want quick help for",
                style: AppTheme.bodyText,
              ),

              const SizedBox(height: 30),

              // Grid
              Expanded(
                child: GridView.builder(
                  itemCount: emergencyTypes.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 2.8,
                  ),
                  itemBuilder: (context, index) {
                    final type = emergencyTypes[index];
                    final isSelected =
                        selectedTypes.contains(type);

                    return GestureDetector(
                      onTap: () => toggleSelection(type),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.green
                              : AppTheme.surfaceLight,
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.green
                                : AppTheme.borderColor,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedTypes.isNotEmpty
                        ? AppTheme.green
                        : AppTheme.surfaceLight,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  onPressed:
                      selectedTypes.isNotEmpty ? _continue : null,
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      color: selectedTypes.isNotEmpty
                          ? Colors.black
                          : AppTheme.textHint,
                      fontWeight: FontWeight.bold,
                    ),
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

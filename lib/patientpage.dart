import 'package:flutter/material.dart';
import 'package:medicineapp/location.dart';
import 'package:medicineapp/navigationbar.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  int _selectedIndex = 1;
  String selectedLocation = "Pasadena";

  void _showAddPatientBottomSheet(BuildContext context) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final noteController = TextEditingController();

    String? selectedGender = "Male";
    String? selectedVisitType = "On site";
    String? selectedTreatment;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add New Patient",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                const Text("Enter the patient's information below. Click save when you're done."),
                const SizedBox(height: 16),

                /// LOCATION
                Row(
                  children: const [
                    Icon(Icons.location_on_outlined, size: 20),
                    SizedBox(width: 4),
                    Text("Location", style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "Clinica San Miguel Fondren",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                /// First & Last Name
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(controller: firstNameController, label: "First Name", hint: "Enter firstname"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(controller: lastNameController, label: "Last Name", hint: "Enter lastname"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// Phone & Email
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(controller: phoneController, label: "Phone", hint: "Enter phone"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(controller: emailController, label: "Email", hint: "Enter Email"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// Dropdown
                const Text("Treatment Type"),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: "Select treatment type",
                    border: OutlineInputBorder(),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                  ),
                  value: selectedTreatment,
                  items: ['Checkup', 'X-ray', 'Therapy', 'Consultation']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => selectedTreatment = value,
                ),
                const SizedBox(height: 12),

                /// Gender & Location
                LayoutBuilder(builder: (context, constraints) {
                  return constraints.maxWidth < 360
                      ? Column(
                          children: [_buildRadioGroup("Gender", ["Male", "Female", "Other"], selectedGender, (val) => selectedGender = val),
                            const SizedBox(height: 10),
                            _buildRadioGroup("Location", ["On site", "Off site"], selectedVisitType, (val) => selectedVisitType = val),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: _buildRadioGroup("Gender", ["Male", "Female", "Other"], selectedGender, (val) => selectedGender = val)),
                            Expanded(child: _buildRadioGroup("Location", ["On site", "Off site"], selectedVisitType, (val) => selectedVisitType = val)),
                          ],
                        );
                }),

                const SizedBox(height: 12),

                /// Note
                _buildInputField(
                  controller: noteController,
                  label: "Note",
                  hint: "Enter any note about the patient",
                  maxLines: 3,
                ),

                const SizedBox(height: 20),

                /// Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade300,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        ),
      ],
    );
  }

  static Widget _buildRadioGroup(String title, List<String> options, String? selected, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Wrap(
          spacing: 10,
          children: options.map((opt) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: opt,
                  groupValue: selected,
                  onChanged: onChanged,
                ),
                Text(opt),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              /// Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/medicineicon.png', height: 80),
                  Row(
                    children: [
                      Text(
                        selectedLocation,
                        style: const TextStyle(decoration: TextDecoration.underline),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          final result = await showLocationBottomSheet(context);
                          if (result != null) {
                            setState(() => selectedLocation = result);
                          }
                        },
                        child: const Icon(Icons.location_pin, size: 30),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.person, size: 30),
                    ],
                  ),
                ],
              ),

              /// Title and Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.arrow_back, size: 28),
                  const Text("Patients", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showAddPatientBottomSheet(context),
                        child: Row(
                          children: const [
                            Icon(Icons.add_circle_outline, color: Colors.blue),
                            SizedBox(width: 4),
                            Text("Add New", style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.filter_alt_outlined, size: 30),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// Patient Grid
              Expanded(
                child: GridView.builder(
                  itemCount: 10,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: width < 400 ? 1 : 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4FB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("P6345", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text("on-site", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text("Mr. Jack Sparrow", style: TextStyle(fontWeight: FontWeight.w500)),
                          const Text("Male", style: TextStyle(color: Colors.blue)),
                          const Spacer(),
                          const Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(Icons.arrow_forward, color: Colors.blue),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigatorBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:medicineapp/location.dart';
import 'package:medicineapp/navigationbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  int _selectedIndex = 1;

  List<Map<String, dynamic>> patients = [];
  List<String> services = [];
  String? selectedTreatment;
  Future<void> fetchServices() async {
    final supabase = Supabase.instance.client;

    final response = await supabase.from('services').select('title');

    if (response != null) {
      setState(() {
        services = response
            .map<String>((item) => item['title'] as String)
            .toList();
      });
    }
  }

  void _showAddPatientBottomSheet(BuildContext context) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final noteController = TextEditingController();

    String? selectedGender;
    String? selectedVisitType;
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  "Enter the patient's information below. Click save when you're done.",
                ),
                const SizedBox(height: 16),

                /// LOCATION
                Row(
                  children: const [
                    Icon(Icons.location_on_outlined, size: 20),
                    SizedBox(width: 4),
                    Text(
                      "Location",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    AppData.selectedLocation ?? 'No location selected',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                /// First & Last Name
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: firstNameController,
                        label: "First Name",
                        hint: "Enter firstname",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        controller: lastNameController,
                        label: "Last Name",
                        hint: "Enter lastname",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// Phone & Email
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: phoneController,
                        label: "Phone",
                        hint: "Enter phone",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        controller: emailController,
                        label: "Email",
                        hint: "Enter Email",
                      ),
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
                  items: services
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) => selectedTreatment = value,
                ),
                const SizedBox(height: 12),

                /// Gender & Location
                LayoutBuilder(
                  builder: (context, constraints) {
                    return constraints.maxWidth < 360
                        ? Column(
                            children: [
                              _buildRadioGroup(
                                "Gender",
                                ["Male", "Female", "Other"],
                                selectedGender,
                                (val) {
                                  setState(() {
                                    selectedGender = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              _buildRadioGroup(
                                "Location",
                                ["On site", "Off site"],
                                selectedVisitType,
                                (val) {
                                  setState(() {
                                    selectedVisitType = val;
                                  });
                                },
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _buildRadioGroup(
                                  "Gender",
                                  ["Male", "Female", "Other"],
                                  selectedGender,
                                  (val) {
                                    setState(() {
                                      selectedGender = val;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: _buildRadioGroup(
                                  "Location",
                                  ["On site", "Off site"],
                                  selectedVisitType,
                                  (val) {
                                    setState(() {
                                      selectedVisitType = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                  },
                ),

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
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final supabase = Supabase.instance.client;

                        // Basic validation
                        if (firstNameController.text.isEmpty ||
                            lastNameController.text.isEmpty ||
                            phoneController.text.isEmpty ||
                            emailController.text.isEmpty ||
                            selectedTreatment == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please fill all required fields."),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          final insertData = {
                            'firstname': firstNameController.text.trim(),
                            'lastname': lastNameController.text.trim(),
                            'phone': phoneController.text.trim(),
                            'email': emailController.text.trim(),
                            'treatmenttype': selectedTreatment,
                            'gender': selectedGender,
                            'locationid':
                                15, // Replace with dynamic location if needed
                            'onsite': selectedVisitType == 'On site',
                            'text_opt': true,
                            'email_opt': true,
                            'note': noteController.text.trim().isNotEmpty
                                ? noteController.text.trim()
                                : null,
                            'lastvisit': DateTime.now()
                                .toIso8601String(), // Or allow user to pick
                          };
                          print(insertData);

                          final response = await supabase
                              .from('allpatients')
                              .insert(insertData);
                          print(response);
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Patient added successfully."),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          print("Insert error: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to add patient."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },

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

  static Widget _buildRadioGroup(
    String title,
    List<String> options,
    String? selected,
    Function(String?) onChanged,
  ) {
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

  Future<void> fetchPatients() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('allpatients') // change this to your actual table name
          .select('id, firstname, lastname, gender, treatmenttype, onsite')
          .eq('locationid', AppData.selectedLocationId!);

      if (response != null) {
        setState(() {
          patients = List<Map<String, dynamic>>.from(response);
          patients = response;
          if (patients.isEmpty) {
            patients = [
              {'message': 'No patients found for ${AppData.selectedLocation}.'},
            ];
          }
        });
      }
    } catch (e) {
      print('Error fetching patients: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPatients();
    fetchServices();
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 1,
                    child: Image.asset(
                      'assets/images/medicineicon.png',
                      height: 60,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            AppData.selectedLocation ?? 'No location selected',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () async {
                            final result = await showLocationBottomSheet(
                              context,
                            );
                            if (result != null) {
                              setState(() => AppData.selectedLocation!);
                            }
                            fetchPatients();
                          },
                          child: const Icon(Icons.location_pin, size: 30),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.person, size: 30),
                      ],
                    ),
                  ),
                ],
              ),

              /// Title and Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    "Patients",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showAddPatientBottomSheet(context),
                        child: Row(
                          children: const [
                            Icon(Icons.add_circle_outline, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              "Add New",
                              style: TextStyle(color: Colors.blue),
                            ),
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
                  itemCount: patients.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: width < 400 ? 1 : 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    final fullName =
                        "${patient['firstname'] ?? ''} ${patient['lastname'] ?? ''}";
                    final isOnsite = patient['onsite'] == true;

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
                              Text(
                                "P${patient['id'] ?? ''}", // patient ID
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isOnsite ? "On-site" : "Off-site",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Name
                          Text(
                            fullName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),

                          // Gender
                          Text(
                            patient['gender'] ?? '',
                            style: const TextStyle(color: Colors.blue),
                          ),

                          // Treatment
                          Text(
                            patient['treatmenttype'] ?? '',
                            style: const TextStyle(color: Colors.black54),
                          ),

                          const Spacer(),
                          IconButton(
                            onPressed: () async {
                              final supabase = Supabase.instance.client;
                              final id = patient['id'];
                              print(id);
                              await supabase
                                  .from('allpatients')
                                  .delete()
                                  .eq('id', id);
                             
                              fetchPatients();
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                          // Bottom arrow
                          const Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.blue,
                            ),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentPage extends StatefulWidget {
  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final supabase = Supabase.instance.client;
  bool showApproved = true;
  List<dynamic> appointments = [];

  final List<String> days = ["MON", "Tue", "Wed", "Thr", "Fri", "Sat"];
  final List<String> dates = ["4", "5", "6", "7", "8", "9"];

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    final response = await supabase
        .from('Appoinments')
        .select()
        .eq('isApproved', showApproved);
    print(response);
    setState(() {
      appointments = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Appointments",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => showAddAppointmentBottomSheet(context),
            icon: Icon(Icons.add_circle_outline, color: Colors.blue),
            label: Text("Add New", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusChip("Approved", showApproved, true),
                SizedBox(width: 12),
                _buildStatusChip("Need Approval", showApproved, false),
              ],
            ),
            SizedBox(height: 24),
            Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                itemBuilder: (context, index) {
                  bool isSelected = index == 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            days[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            dates[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ListView.builder(
              itemCount: appointments.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return Card(
                  color: Color(0xFFEAF4FB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${appointment['first_name']} ${appointment['last_name']}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${appointment['service']}",
                              style: TextStyle(color: Colors.blue),
                            ),
                            Text("${appointment['sex']}"),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF37474F),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "${appointment['date_and_time']}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Confirm Delete"),
                                        content: Text(
                                          "Are you sure you want to delete this appointment?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final id = appointment['id'];
                                              await supabase
                                                  .from('Appoinments')
                                                  .delete()
                                                  .eq('id', id);
                                              Navigator.pop(context);
                                              fetchAppointments();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
  showEditAppointmentBottomSheet(context, appointment);
  await fetchAppointments(); // This will run after the bottom sheet is closed
},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, bool current, bool match) {
    final isSelected = current == match;
    return GestureDetector(
      onTap: () {
        setState(() {
          showApproved = match;
          fetchAppointments();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF37474F) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}


void showAddAppointmentBottomSheet(BuildContext context) {
  final supabase = Supabase.instance.client;

  String? visitType;
  String? patientType;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController zipcodeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String? gender;
  String? service;
  String? selectedTimeSlot;
  String selectedState = "Alaska - AK";
  String locationName = "Clinica San Miguel Fondren";

  bool? inOfficePatient = false;
  bool? newPatient = false;

  final List<String> states = [
    "Alaska - AK", "California - CA", "New York - NY", "Texas - TX"
  ];

  final List<String> timeSlots = [
    "09:00 AM", "10:00 AM", "11:00 AM", "01:00 PM", "02:00 PM"
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Add an Appointment", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Fill all the fields to continue"),
                SizedBox(height: 16),

                // Type of Visit and Patient Status
                Text("Type of visit & Patient status", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        children: [
                          ChoiceChip(
                            label: Text("Office visit"),
                            selected: visitType == "office",
                            onSelected: (_) => setModalState(() => visitType = "office"),
                          ),
                          ChoiceChip(
                            label: Text("Virtual visit"),
                            selected: visitType == "virtual",
                            onSelected: (_) => setModalState(() => visitType = "virtual"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        children: [
                          ChoiceChip(
                            label: Text("New"),
                            selected: patientType == "new",
                            onSelected: (_) => setModalState(() => patientType = "new"),
                          ),
                          ChoiceChip(
                            label: Text("Coming back"),
                            selected: patientType == "returning",
                            onSelected: (_) => setModalState(() => patientType = "returning"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Name Fields
                Row(
                  children: [
                    Expanded(child: TextField(controller: firstNameController, decoration: InputDecoration(labelText: "First Name", border: OutlineInputBorder()))),
                    SizedBox(width: 12),
                    Expanded(child: TextField(controller: lastNameController, decoration: InputDecoration(labelText: "Last Name", border: OutlineInputBorder()))),
                  ],
                ),
                SizedBox(height: 12),

                // Contact Fields
                TextField(controller: emailController, decoration: InputDecoration(labelText: "Email Address", border: OutlineInputBorder())),
                SizedBox(height: 12),
                TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone Number", border: OutlineInputBorder())),
                SizedBox(height: 12),

                // DOB
                TextField(
                  controller: dobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Date of Birth", hintText: "mm/dd/yyyy",
                    border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setModalState(() {
                        dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                ),
                SizedBox(height: 16),

                // Gender
                Text("Sex", style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(spacing: 10, children: ["male", "female", "others"].map((val) {
                  return ChoiceChip(
                    label: Text(val),
                    selected: gender == val,
                    onSelected: (_) => setModalState(() => gender = val),
                  );
                }).toList()),
                SizedBox(height: 16),

                // State & Zipcode
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedState,
                        items: states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setModalState(() => selectedState = val ?? states.first),
                        decoration: InputDecoration(labelText: "State", border: OutlineInputBorder()),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(child: TextField(controller: zipcodeController, decoration: InputDecoration(labelText: "Zipcode", border: OutlineInputBorder()))),
                  ],
                ),
                SizedBox(height: 12),

                // Address
                TextField(controller: addressController, decoration: InputDecoration(labelText: "Street Address", border: OutlineInputBorder())),
                SizedBox(height: 12),

                // Service
                Text("Treatment", style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(spacing: 10, children: ["Ultrasound", "Blood Test", "Consultation"].map((val) {
                  return ChoiceChip(
                    label: Text(val),
                    selected: service == val,
                    onSelected: (_) => setModalState(() => service = val),
                  );
                }).toList()),
                SizedBox(height: 16),

                // Appointment Date & Time
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: dateController,
                        readOnly: true,
                        decoration: InputDecoration(labelText: "Date *", suffixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setModalState(() {
                              dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedTimeSlot,
                        items: timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) => setModalState(() => selectedTimeSlot = val),
                        decoration: InputDecoration(labelText: "Time *", border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Switches
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Is this an in-office appointment?"),
                    Switch(
                      value: inOfficePatient ?? false,
                      onChanged: (val) => setModalState(() => inOfficePatient = val),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Is this a new patient?"),
                    Switch(
                      value: newPatient ?? false,
                      onChanged: (val) => setModalState(() => newPatient = val),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Submit Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
  if ([
    firstNameController.text,
    lastNameController.text,
    emailController.text,
    phoneController.text,
    dobController.text,
    addressController.text,
    zipcodeController.text,
    dateController.text,
    selectedTimeSlot,
    gender,
    service,
    visitType,
    patientType,
  ].any((e) => e == null || (e is String && e.isEmpty))) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Please fill all fields."),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    // Optional: You can still dynamically get location_id from the 'locations' table
    // final locationResponse = await supabase
    //     .from('locations')
    //     .select('id')
    //     .eq('name', locationName)
    //     .maybeSingle();
    // final locationId = locationResponse?['id'];

    final insertData = {
      'first_name': firstNameController.text.trim(),
      'last_name': lastNameController.text.trim(),
      'email_address': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'dob': dobController.text.trim(),
      'sex': gender,
      // 'state': selectedState,
      // 'zipcode': zipcodeController.text.trim(),
      'address': addressController.text.trim(),
      'service': service,
      // 'date_and_time': '${dateController.text.trim()} - ${selectedTimeSlot}',
      'date_and_time': null,
   
      'in_office_patient': inOfficePatient ?? true,
      'new_patient': newPatient ?? true,
      'isApproved': false,
      'text_opt': true,
      'email_opt': true,
      'location_id': 2, // You said this is correct
      // 'type_of_visit': visitType,
      // 'patient_status': patientType,
    };

    final response = await supabase.from('Appoinments').insert(insertData);

   
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Appointment added successfully."),
          backgroundColor: Colors.green,
        ));
                    
    
  } catch (e) {
    print("Supabase insert error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to add appointment."),
        backgroundColor: Colors.red,
      ),
    );
  }
},
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0B5FFF), foregroundColor: Colors.white),
                      child: Text("Add appointment"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      });
    },
  );
}
void showEditAppointmentBottomSheet(BuildContext context, Map<String, dynamic> appointment) {
  final supabase = Supabase.instance.client;

  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  final List<String> timeSlots = [
    "09:00 AM", "10:00 AM", "11:00 AM", "01:00 PM", "02:00 PM"
  ];

  final originalDateTime = appointment['date_and_time'] ?? '';

  if (originalDateTime.toString().contains(' - ')) {
    final split = originalDateTime.toString().split(' - ');
    dateController.text = split[0].trim();
    timeController.text = split[1].trim();
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Edit Appointment", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),

                  /// Date Field
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "New Date",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        final formatted = DateFormat('yyyy-MM-dd').format(picked);
                        setModalState(() => dateController.text = formatted);
                      }
                    },
                  ),
                  SizedBox(height: 12),

                  /// Time Dropdown
                  DropdownButtonFormField<String>(
                    value: timeSlots.contains(timeController.text) ? timeController.text : null,
                    items: timeSlots
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setModalState(() => timeController.text = val ?? ''),
                    decoration: InputDecoration(
                      labelText: "New Time",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  /// Submit Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel"),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final newDate = dateController.text.trim();
                          final newTime = timeController.text.trim();
                          if (newDate.isEmpty || newTime.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please select both date and time."),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final newDateTime = "$newDate - $newTime";

                          try {
                            await supabase
                                .from('Appoinments')
                                .update({'date_and_time': newDateTime})
                                .eq('id', appointment['id']);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Appointment updated successfully."),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            print("Error updating appointment: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to update appointment."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0B5FFF),
                          foregroundColor: Colors.white,
                        ),
                        child: Text("Update Appointment"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    });
}
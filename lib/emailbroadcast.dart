import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicineapp/location.dart';
import 'package:medicineapp/navigationbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart';

class EmailTemplateScreen extends StatefulWidget {
  final String userId;

  const EmailTemplateScreen({super.key, required this.userId});

  @override
  State<EmailTemplateScreen> createState() => _EmailTemplateScreenState();
}

class _EmailTemplateScreenState extends State<EmailTemplateScreen> {
  // Dropdown options
  final List<String> templateOptions = [
    "Template 1 (Built-in)",
    "Template 2 (Built-in)",
    "Template 3 (Built-in)",
    "Template 4 (Built-in)",
    "Template 5 (Built-in)",
    "Template 6 (Built-in)",
    "Template 7 (Built-in)",
    "Template 8 (Built-in)",
    "Template 9 (Built-in)",
    "Template 10 (Built-in)",
    "Christmas (DB)",
    "Easter(DB)",
  ];

  // Template content
  final Map<String, Map<String, String>> templateContent = {
    "Template 1 (Built-in)": {
      "greeting": "Dear Patient,",
      "message":
          "🍂 October is the month to fight breast cancer! 💝 Protect yourself! At Clínica San Miguel we give you the mammogram order for only \$0. Don't wait any longer! It is without appointment.",
      "sender": "Email Template",
    },
    "Template 2 (Built-in)": {
      "greeting": "Dear Patient,",
      "message":
          "Woman! Your health comes first.🙋‍♀️ Detect breast cancer in time with a mammogram order at Clínica San Miguel. 💝 October special offer:. Call us!",
      "sender": "Dr. Ali",
    },
    "Template 3 (Built-in)": {
      "greeting": "Dear Patient,",
      "message":
          "Pink October! Take care of yourself and take care of the women you love. Mammography only. San Miguel Clinic. Schedule your appointment today!",
    },
    "Template 4 (Built-in)": {
      "greeting": "Dear Patient,",
      "message":
          "Goodbye to extra pounds!💪 Our weight loss plan with Semaglutide will help you achieve your goals. 10 units for only .Consult our experts! ",
    },
    "Template 5 (Built-in)": {
      "greeting": "Dear Patient,",
      "message":
          "⁠Do you want to feel healthier and more energetic?💪Our plan with Semaglutide is the solution.10 units at an incredible price:Don't miss it!",
    },
    "Template 6 (Built-in)": {
      "greeting": "Dear Patient,",
      "message":
          "Transform your body and your life! 💥 Our weight loss plan with Semaglutide is your best ally. Check our packages.",
    },
    "Template 7 (Built-in)": {
      "greeting": "Dear Patient,",
      "message":
          "Take control of your health! Get your mammogram at Clínica San Miguel for only . Schedule now!",
    },
    "Template 8 (Built-in)": {
      "greeting": "Dear Patient,",
      "message":
          "Man! Don't neglect your health. Get a prostate exam + general exam for  at Clínica San Miguel. Schedule your appointment!",
    },
    "Template 9 (Built-in)": {
      "greeting": "Dear Patient,",
      "message":
          "If you are in Houston and need the immigration exam🇺🇸Clínica San Miguel offers it to you for only (vaccines not included). //Call us! ",
    },
    "Template 10 (Built-in)": {
      "greeting": "Dear Patient,",
      "message":
          "Get energized!⚡ Our 5 Vitamin B12 injections will give you the boost you need. Only !y only. ",
    },
    "Christmas (DB)": {
      "greeting": "Dear Patient!",
      "message":
          "Hello, We are offering 20% on excuse forms, offer valid till 28th December 2025.",
    },
    "Easter (DB)": {
      "greeting": "Dear Patient!",
      "message": "We have new deals for easter, please check our website.",
    },
  };

  // Form controllers
  String selectedTemplate = "Template 1 (Built-in)";
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController targetPatientController = TextEditingController();
  List<Map<String, dynamic>> patients = [];
  List<String> selectedEmails = [];
  List<Map<String, dynamic>> filteredPatients = [];
  bool selectAll = false;
  TextEditingController searchController = TextEditingController();

  Future<void> fetchPatients() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('allpatients')
          .select(
            'id, firstname, lastname, email, gender, treatmenttype, onsite',
          );

      if (response != null) {
        setState(() {
          patients = List<Map<String, dynamic>>.from(response);
          filteredPatients = patients;
          selectedEmails = []; // Clear old selection
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
  }

  @override
  Widget build(BuildContext context) {
    int? _selectedIndex = 3;
    final selected = templateContent[selectedTemplate]!;

    // const emailApiUrl =
    //     'https://send-resent-mail-646827ff1a0b.herokuapp.com/send';

    Future<void> sendEmailToPatients({
      required List<String> recipients, // e.g. ['a@x.com', 'b@y.com']
      required String subject,
      required String htmlBody, // full HTML you built
    }) async {
      const endpoint =
          'https://send-resent-mail-646827ff1a0b.herokuapp.com/send-batch-email';

      final payload = {
        "from":
            "noreply@alerts.myclinicmd.com", // must match backend allow‑list
        "recipients": recipients, // <-- NOT  "to"
        "subject": subject,
        "html": htmlBody, // <-- NOT  "body"
      };

      final res = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200) {
        debugPrint('✅ Emails sent!');
      } else {
        debugPrint('❌ ${res.statusCode} – ${res.body}');
        throw Exception('Email‑service error');
      }
    }

    void _showPatientSelectionSheet(BuildContext context) {
  bool selectAll = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom +30,
              left: 30,
              right: 30,
              top: 30,
            ),  child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text(
                      "Select Patients".tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                   IconButton(
  onPressed: () {
    Navigator.pop(context);
  },
  padding: EdgeInsets.zero, // removes extra padding
  constraints: const BoxConstraints(), // keeps size compact
  icon: Container(
    width: 24,
    height: 24,
    decoration: const BoxDecoration(
      color: Color(0xFFE8EAF6), // light grey circle background
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.close,
      size: 16,
      color: Colors.black54, // X color
    ),
  ),
)

                  ],
                ),
                const Divider(),
                const SizedBox(height: 25),

                // Search bar
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      filteredPatients = patients
                          .where((p) => (p['email'] ?? '')
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                    });

                    setModalState(() {
                      // Also update selectAll flag
                      selectAll = selectedEmails.length == filteredPatients.length;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Search by email".tr(),
                    
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Select All
                CheckboxListTile(
                  title: Text("select_all".tr()),
                  value: selectAll,
                  onChanged: (checked) {
                    setState(() {
                      selectAll = checked!;
                      selectedEmails = checked
                          ? filteredPatients
                              .map((p) => p['email'] as String)
                              .toList()
                          : [];
                    });

                    setModalState(() {}); // Refresh modal state
                  },
                ),
                const Divider(),

                // Patient list
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: filteredPatients.length,
                    itemBuilder: (_, index) {
                      final email = filteredPatients[index]['email'] as String;
                      final name =
                          filteredPatients[index]['firstname'] ?? 'Unnamed';
                      final isChecked = selectedEmails.contains(email);

                      return CheckboxListTile(
                        title: Text('$name ($email)'),
                        value: isChecked,
                        activeColor: const Color(0xFF0057FF),
                        controlAffinity: ListTileControlAffinity.trailing,
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              selectedEmails.add(email);
                            } else {
                              selectedEmails.remove(email);
                            }

                            // Update selectAll flag
                            selectAll = selectedEmails.length ==
                                filteredPatients.length;
                          });

                          setModalState(() {}); // Refresh modal state
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Done button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: const Color(0xFF0057FF),
                    ),
                    child:  Text(
                      "Done".tr(),
                      style: TextStyle(color: const Color(0xFF0057FF),),
                    ),
                  ),
                ),
              ],
            ),
          )
        
            )
            
            );
        },
      );
    },
  );
}

    return Scaffold(
       backgroundColor: const Color(0xFFF1F4F9),
            appBar: AppBar(
        leading: Row(
          children: [
            IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: 28,
                          color: Colors.black,
                          
                        ),

                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      //  Text('Back', style: TextStyle(color: Colors.black,fontSize: 10)),
                     

          ],
        ),
        centerTitle: true,
          title: Text("Broadcast".tr(), style: TextStyle(color: Colors.black,fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 1,),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // Row(
              //   children: [
              //     IconButton(
              //       icon: Icon(Icons.arrow_back, size: 28, color: Colors.black),

              //       onPressed: () {
              //         Navigator.pop(context);
              //       },
              //     ),
              //     Text('Back'.tr(), style: TextStyle(color: Colors.black)),
              //     SizedBox(width: 55, height: 10),
              //     Text(
              //       "Broadcast".tr(),
              //       style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              //     ),
              //   ],
              // ),
              
              
              const SizedBox(height: 20),
              // --- FORM SECTION ---
             Text(
                'target_patients'.tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showPatientSelectionSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF0057FF)),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    selectedEmails.isEmpty
                        ? 'select patients'.tr()
                        : '${selectedEmails.length} selected',
                    style: const TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF0057FF),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

               Text(
                "Email Template".tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedTemplate,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: templateOptions.map((template) {
                  return DropdownMenuItem(
                    value: template,
                    child: Text(template),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedTemplate = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              Text(
                "Write Subject".tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: subjectController,
                decoration:  InputDecoration(
                  hintText: "Run email".tr(),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

               Text(
                "Name".tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                decoration:  InputDecoration(
                  hintText: "Email Template".tr(),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

            Text(
                "Price".tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: priceController,
                decoration:  InputDecoration(
                  hintText: "Run email".tr(),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0057FF),
                  ),

                  onPressed: () async {
                    final subject = subjectController.text.trim();
                    print('subject $subject');
                    final greeting =
                        templateContent[selectedTemplate]?['greeting'] ?? '';
                    print('greeting $greeting');
                    final rawMessage =
                        templateContent[selectedTemplate]?['message'] ?? '';
                    final sender = nameController.text.trim().isEmpty
                        ? (templateContent[selectedTemplate]?['sender'] ?? '')
                        : nameController.text.trim();
                    final price = priceController.text.trim().isEmpty
                        ? '0'
                        : priceController.text.trim();

                    final body =
                        '''
$greeting

${rawMessage.replaceAll('\$0', 'Rs. $price')}

Best,
$sender
''';
                    print('body $body');

                    if (selectedEmails.isEmpty ||
                        subject.isEmpty ||
                        body.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please select patients, subject, and template",
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      print('yahan agye hain $selectedEmails');
                      print(subject);
                      print(body);
                      await sendEmailToPatients(
                        recipients: selectedEmails,
                        subject: subject,
                        htmlBody: body,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Emails sent to ${selectedEmails.length} patients.",
                          ),
                        ),
                      );

                      // Reset form
                      setState(() {
                        selectedEmails.clear();
                        subjectController.clear();
                        nameController.clear();
                        priceController.clear();
                      });
                    } catch (e) {
                      print("❌ Email sending error: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Something went wrong while sending email.",
                          ),
                        ),
                      );
                    }
                  },

                  // Send logic
                  child: Text(
                    "Run email".tr(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              //               Center(
              //                 child:

              //  Container(
              //       padding: const EdgeInsets.all(2), // Border width
              //       decoration: BoxDecoration(
              //         color: const Color(0xFF0057FF), // Dark blue border
              //         shape: BoxShape.circle,
              //       ),
              //       child: CircleAvatar(
              //         radius: 40,

              //         backgroundImage: AssetImage('assets/images/stethoscope.png'),
              //       ),
              //     ),
              //                     ),      // --- PREVIEW SECTION ---
           Padding(
  padding: const EdgeInsets.only(top: 30), // give extra space
  child: Stack(
    clipBehavior: Clip.none, // allow drawing outside bounds
    alignment: Alignment.center,
    children: [
      // Main Email Card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF0057FF), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  "assets/images/medicineicon1.png",
                  width: 80,
                  height: 100,
                ),
                const SizedBox(width: 150),
                Text(
                  "Preview".tr(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              templateContent[selectedTemplate]?['greeting'] ?? '',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              templateContent[selectedTemplate]?['message']!.replaceAll(
                    "\$0",
                    "Rs. ${priceController.text.trim().isEmpty ? '0' : priceController.text.trim()}",
                  ) ??
                  '',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Divider(),
            Text(
              "Best Regards,\n Clinica San Miguel Team",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),

      // Stethoscope Circle
      Positioned(
        top: -20,
        left: 0,
        right: 0,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F6FF),
            shape: BoxShape.circle,
            border: Border.all(
              color: Color(0xFF0057FF),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              'assets/images/stethoscope.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    ],
  ),
)

              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     color: Colors.grey[100],
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(color: const Color(0xFF0057FF), width: 2),
              //   ),

              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Image.asset(
              //             "assets/images/medicineicon1.png",
              //             width: 80,
              //             height: 100,
              //           ),
              //           const SizedBox(width: 150),
              //           const Text(
              //             "Preview",
              //             style: TextStyle(fontWeight: FontWeight.bold),
              //           ),
              //         ],
              //       ),

              //       const SizedBox(height: 20),
              //       Text(
              //         templateContent[selectedTemplate]?['greeting'] ?? '',
              //         style: const TextStyle(fontSize: 18),
              //       ),
              //       const SizedBox(height: 10),
              //       Text(
              //         templateContent[selectedTemplate]?['message']!.replaceAll(
              //               "\$0",
              //               "Rs. ${priceController.text.trim().isEmpty ? '0' : priceController.text.trim()}",
              //             ) ??
              //             '',
              //         style: const TextStyle(fontSize: 16, height: 1.5),
              //       ),
              //       const SizedBox(height: 20),
              //       const Divider(),
              //       // Text(
              //       //   "Best Regards,\n${nameController.text.trim().isEmpty ? (templateContent[selectedTemplate]?['sender'] ?? '') : nameController.text.trim()}",
              //       //   style: const TextStyle(fontSize: 16),
              //       // ),
              //       Text(
              //         "Best Regards,\n Clinica San Miguel Team",
              //         style: const TextStyle(fontSize: 16),
              //       ),
              //     ],
              //   ),
              // ),
            
            
            ],
          ),
        ),
      ),

      bottomNavigationBar: NavigatorBar(
        userId: widget.userId,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

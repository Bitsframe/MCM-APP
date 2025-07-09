import 'package:flutter/material.dart';
import 'package:medicineapp/location.dart';
import 'package:medicineapp/navigationbar.dart';
import 'package:medicineapp/patientpage.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 2;
   String selectedLocation = "Pasadena";

  // void _onBottomNavTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  //   if (index == 0) {
  //     showModalBottomSheet(
  //       context: context,
  //       isScrollControlled: true,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
  //       ),
  //       builder: (context) => DraggableScrollableSheet(
  //         expand: false,
  //         builder: (context, scrollController) => AppointmentPage(),
  //       ),
  //     );
  //   }
  // else if (index == 1) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => PatientsPage()),
  //     );
  //   }
  // }

  void _onTileTapped(String type) {
    if (type == 'Appointments') {
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$type clicked!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/medicineicon.png',
                          height: 100,
                        ),
                        Row(
                          children: [
                          GestureDetector(
      onTap: () async {
        final result = await showLocationBottomSheet(context);
        if (result != null) {
          setState(() {
            selectedLocation = result;
          });
        }
      },
      child: Row(
        children: [
          Text(
            selectedLocation,
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.location_pin, size: 24, color: Colors.black),
        ],
      ),
    ),
                          ]
  
                        )
                            
                      ],
                    ),
                    SizedBox(height: 24),
                    Text("Hello,", style: TextStyle(fontSize: 24)),
                    Text(
                      "Mack",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "You have unattended appointments.",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "30 mins ago",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.refresh),
                      ],
                    ),
                    SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildDashboardTile(
                          label: "Patients",
                          icon: Icons.groups,
                          value: "350",
                          color: Colors.pink.shade50,
                          textColor: Colors.pink,
                          onTap: () => _onTileTapped("Patients"),
                        ),
                        _buildDashboardTile(
                          label: "Sales",
                          icon: Icons.point_of_sale,
                          value: "\$780k",
                          color: Colors.purple.shade50,
                          textColor: Colors.purple,
                          onTap: () => _onTileTapped("Sales"),
                        ),
                        _buildDashboardTile(
                          label: "Appointments",
                          icon: Icons.calendar_month,
                          value: "78",
                          color: Colors.cyan.shade50,
                          textColor: Colors.teal,
                          onTap: () => _onTileTapped("Appointments"),
                        ),
                        _buildDashboardTile(
                          label: "Products",
                          icon: Icons.inventory,
                          value: "315",
                          color: Colors.blue.shade50,
                          textColor: Colors.blue,
                          onTap: () => _onTileTapped("Products"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onBottomNavTapped,
      //   type: BottomNavigationBarType.fixed,
      //   backgroundColor: Colors.grey.shade300,
      //   items: [
      //     BottomNavigationBarItem(icon: Icon(Icons.medical_services_outlined), label: ""),
      //     BottomNavigationBarItem(icon: Icon(Icons.contact_page), label: ""),
      //     BottomNavigationBarItem(
      //       icon: Container(
      //         padding: EdgeInsets.all(8),
      //         decoration: BoxDecoration(
      //           color: Colors.black87,
      //           shape: BoxShape.circle,
      //         ),
      //         child: Icon(Icons.home, color: Colors.white),
      //       ),
      //       label: "",
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.podcasts), label: ""),
      //     BottomNavigationBarItem(icon: Icon(Icons.group), label: ""),
      //   ],
      // ),
      bottomNavigationBar: NavigatorBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildDashboardTile({
    required String label,
    required IconData icon,
    required String value,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// class AppointmentPage extends StatefulWidget {
//   const AppointmentPage({super.key});

//   @override
//   State<AppointmentPage> createState() => _AppointmentPageState();
// }

// class _AppointmentPageState extends State<AppointmentPage> {
//    var  _selectedIndex = 0;
//   final List<String> days = ["MON", "Tue", "Wed", "Thr", "Fri", "Sat"];
//   final List<String> dates = ["4", "5", "6", "7", "8", "9"];
 

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           "Appointments",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           TextButton.icon(
//             onPressed: () => showAddAppointmentBottomSheet(context),
//             icon: Icon(Icons.add_circle_outline, color: Colors.blue),
//             label: Text("Add New", style: TextStyle(color: Colors.blue)),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _buildStatusChip("Approved", Color(0xFF37474F), Colors.white),
//                   SizedBox(width: 12),
//                   _buildStatusChip(
//                     "Need Approval",
//                     Colors.grey.shade300,
//                     Colors.black,
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 24),
//             Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold)),
//             SizedBox(height: 12),
//             SizedBox(
//               height: 60,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: days.length,
//                 itemBuilder: (context, index) {
//                   bool isSelected = index == 0;
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                     child: Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: isSelected ? Colors.blue : Colors.grey.shade200,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           Text(
//                             days[index],
//                             style: TextStyle(
//                               color: isSelected ? Colors.white : Colors.black,
//                             ),
//                           ),
//                           Text(
//                             dates[index],
//                             style: TextStyle(
//                               color: isSelected ? Colors.white : Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 16),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: 5,
//               itemBuilder: (context, index) => Card(
//                 color: Color(0xFFEAF4FB),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 margin: EdgeInsets.symmetric(vertical: 8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Mr. Jack Sparrow",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             "Ultra Sound",
//                             style: TextStyle(color: Colors.blue),
//                           ),
//                           Text("Male"),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Color(0xFF37474F),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.access_time,
//                                   color: Colors.white,
//                                   size: 16,
//                                 ),
//                                 SizedBox(width: 6),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "22-Feb-2025",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                     Text(
//                                       "5:00 PM",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               IconButton(
//                                 onPressed: () {
//                                   _showConfirmDialog(context, "delete");
//                                 },
//                                 icon: Icon(
//                                   Icons.delete,
//                                   color: Colors.redAccent,
//                                   size: 28,
//                                 ),
//                               ),
//                               IconButton(
//                                 onPressed: () {
//                                   _showConfirmDialog(context, "edit");
//                                 },
//                                 icon: Icon(
//                                   Icons.edit,
//                                   color: Colors.blueAccent,
//                                   size: 28,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),

//       bottomNavigationBar: NavigatorBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//       ),
//     );
//   }

//   Widget _buildStatusChip(String text, Color bgColor, Color textColor) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: Text(text, style: TextStyle(color: textColor)),
//     );
//   }

//   void _showConfirmDialog(BuildContext context, String action) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Are you sure?"),
//         content: Text("Do you want to $action this appointment?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("Cancel", style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.black,
//               foregroundColor: Colors.white,
//             ),
//             child: Text("Yes"),
//           ),
//         ],
//       ),
//     );
//   }
// }

// void showAddAppointmentBottomSheet(BuildContext context) {
//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController dobController = TextEditingController();

//   String visitType = '';
//   String patientType = '';
//   String gender = '';

//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//     ),
//     builder: (context) {
//       return Padding(
//         padding: EdgeInsets.only(
//           left: 16,
//           right: 16,
//           top: 24,
//           bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Add an Appointment",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 4),
//               Text("Make changes to the patient's information and save them"),
//               SizedBox(height: 16),

//               Text(
//                 "Current Location:",
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//               Text(
//                 "Clinica San Miguel Fondren",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 16),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Type of visit"),
//                   Text("Are you a new or returning patient?"),
//                 ],
//               ),
//               SizedBox(height: 8),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Wrap(
//                       spacing: 10,
//                       children: [
//                         ChoiceChip(
//                           label: Text("Office visit"),
//                           selected: visitType == "office",
//                           onSelected: (_) => visitType = "office",
//                         ),
//                         ChoiceChip(
//                           label: Text("Virtual visit"),
//                           selected: visitType == "virtual",
//                           onSelected: (_) => visitType = "virtual",
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: Wrap(
//                       spacing: 10,
//                       children: [
//                         ChoiceChip(
//                           label: Text("New"),
//                           selected: patientType == "new",
//                           onSelected: (_) => patientType = "new",
//                         ),
//                         ChoiceChip(
//                           label: Text("Coming back"),
//                           selected: patientType == "returning",
//                           onSelected: (_) => patientType = "returning",
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),

//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: firstNameController,
//                       decoration: InputDecoration(
//                         labelText: "First Name",
//                         hintText: "FirstName",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: TextField(
//                       controller: lastNameController,
//                       decoration: InputDecoration(
//                         labelText: "Last Name",
//                         hintText: "LastName",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: emailController,
//                       decoration: InputDecoration(
//                         labelText: "Email",
//                         hintText: "Email",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: TextField(
//                       controller: phoneController,
//                       decoration: InputDecoration(
//                         labelText: "Phone Number",
//                         hintText: "Phone Number",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: dobController,
//                       decoration: InputDecoration(
//                         labelText: "Your date of birth",
//                         hintText: "mm/dd/yyyy",
//                         border: OutlineInputBorder(),
//                         suffixIcon: Icon(Icons.calendar_today),
//                       ),
//                       onTap: () async {
//                         FocusScope.of(
//                           context,
//                         ).requestFocus(FocusNode()); // hide keyboard
//                         DateTime? picked = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime(2000),
//                           firstDate: DateTime(1900),
//                           lastDate: DateTime.now(),
//                         );
//                         if (picked != null) {
//                           dobController.text =
//                               "${picked.month}/${picked.day}/${picked.year}";
//                         }
//                       },
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Sex",
//                           style: TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                         Wrap(
//                           spacing: 10,
//                           children: [
//                             ChoiceChip(
//                               label: Text("Male"),
//                               selected: gender == "male",
//                               onSelected: (_) => gender = "male",
//                             ),
//                             ChoiceChip(
//                               label: Text("Female"),
//                               selected: gender == "female",
//                               onSelected: (_) => gender = "female",
//                             ),
//                             ChoiceChip(
//                               label: Text("Others"),
//                               selected: gender == "others",
//                               onSelected: (_) => gender = "others",
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text("Cancel"),
//                   ),
//                   SizedBox(width: 12),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Collect and process input here
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF0B5FFF),
//                       foregroundColor: Colors.white,
//                     ),
//                     child: Text("Add appointment"),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }


// // class AppointmentPage extends StatelessWidget {
// //   // final ScrollController scrollController;
// //   // AppointmentPage({required this.scrollController});

// //   final List<String> days = ["MON", "Tue", "Wed", "Thr", "Fri", "Sat"];
// //   final List<String> dates = ["4", "5", "6", "7", "8", "9"];

// //   @override
// //   Widget build(BuildContext context) {
// //     return SingleChildScrollView(
// //       // controller: scrollController,
// //       child: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text("Appointments", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// //                 Row(
// //                   children: [
// //                      GestureDetector(
// //                         onTap: (){
// //                             showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         final TextEditingController nameController = TextEditingController();
// //         final TextEditingController genderController = TextEditingController();
// //         final TextEditingController emailController = TextEditingController();

// //         return AlertDialog(
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //           title: Text(
// //             "Add Appointment",
// //             style: TextStyle(
// //               color: Colors.black,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           content: SingleChildScrollView(
// //             child: Column(
// //               children: [
// //                 TextField(
// //                   controller: nameController,
// //                   decoration: InputDecoration(
// //                     labelText: "Name",
// //                     hintText: "Enter name",
// //                   ),
// //                 ),
// //                 SizedBox(height: 12),
// //                 TextField(
// //                   controller: genderController,
// //                   decoration: InputDecoration(
// //                     labelText: "Date",
// //                     hintText: "Enter Date",
// //                   ),
// //                 ),
// //                 SizedBox(height: 12),
// //                 TextField(
// //                   controller: emailController,
// //                   decoration: InputDecoration(
// //                     labelText: "Time",
// //                     hintText: "Enter time",
// //                   ),
// //                 ),
// //                 SizedBox(height: 20),
// //                 ElevatedButton(
// //                   onPressed: () {
// //                     String name = nameController.text;
// //                     String gender = genderController.text;
// //                     String email = emailController.text;

// //                     // TODO: You can now save or process these values

// //                     Navigator.pop(context); // close dialog
// //                   },
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.black,
// //                     foregroundColor: Colors.white,
// //                   ),
// //                   child: Text("Book Appointment"),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //                         },
// //                         child: Row(
// //                           children: [
// //                             Icon(Icons.add_circle_outline, color: Colors.blue),
// //                             SizedBox(width: 4),
// //                             Text(
// //                               "Add New",
// //                               style: TextStyle(color: Colors.blue),
// //                             ),
// //                           ],
// //                         ), 

// //                       ),
// //                     // Icon(Icons.add_circle_outline, color: Colors.blue),
// //                     // SizedBox(width: 4),
// //                     // Text("Add New", style: TextStyle(color: Colors.blue)),
// //                   ],
// //                 )
// //               ],
// //             ),
// //             SizedBox(height: 16),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Container(
// //                   padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
// //                   decoration: BoxDecoration(
// //                     color: Color(0xFF37474F),
// //                     borderRadius: BorderRadius.circular(24),
// //                   ),
// //                   child: Text("Approved", style: TextStyle(color: Colors.white)),
// //                 ),
// //                 SizedBox(width: 12),
// //                 Container(
// //                   padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
// //                   decoration: BoxDecoration(
// //                     color: Colors.grey.shade300,
// //                     borderRadius: BorderRadius.circular(24),
// //                   ),
// //                   child: Text("Need Approval"),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: 24),
// //             Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold)),
// //             SizedBox(height: 12),
// //             SizedBox(
// //               height: 60,
// //               child: ListView.builder(
// //                 scrollDirection: Axis.horizontal,
// //                 itemCount: days.length,
// //                 itemBuilder: (context, index) {
// //                   bool isSelected = index == 0;
// //                   return Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 4.0),
// //                     child: Column(
// //                       children: [
// //                         Container(
// //                           padding: EdgeInsets.all(10),
// //                           decoration: BoxDecoration(
// //                             color: isSelected ? Colors.blue : Colors.grey.shade200,
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                           child: Column(
// //                             children: [
// //                               Text(days[index], style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
// //                               Text(dates[index], style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //             SizedBox(height: 16),
// //             ListView.builder(
// //               itemCount: 5,
// //               shrinkWrap: true,
// //               physics: NeverScrollableScrollPhysics(),
// //               itemBuilder: (context, index) => Card(
// //                 color: Color(0xFFEAF4FB),
// //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                 margin: EdgeInsets.symmetric(vertical: 8),
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(12.0),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text("Mr. Jack Sparrow", style: TextStyle(fontWeight: FontWeight.bold)),
// //                           Text("Ultra Sound", style: TextStyle(color: Colors.blue)),
// //                           Text("Male"),
// //                         ],
// //                       ),
// //                       Column(
// //                         children: [
// //                           Container(
// //                             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //                             decoration: BoxDecoration(
// //                               color: Color(0xFF37474F),
// //                               borderRadius: BorderRadius.circular(8),
// //                             ),
// //                             child: Row(
// //                               children: [
// //                                 Icon(Icons.access_time, color: Colors.white, size: 16),
// //                                 SizedBox(width: 6),
// //                                 Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     Text("22-Feb-2025", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
// //                                     Text("5:00 PM", style: TextStyle(color: Colors.white, fontSize: 12)),
// //                                   ],
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                           Row(
// //                             children: [
// //                               IconButton(
// //                                 icon: Icon(Icons.delete, color: Colors.red),
// //                                 onPressed: () {},
// //                               ),
// //                               IconButton(
// //                                 icon: Icon(Icons.edit, color: Colors.blue),
// //                                 onPressed: () {},
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

import 'package:flutter/material.dart';
import 'package:medicineapp/navigationbar.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 4;
  final List<Map<String, String>> users = List.generate(
    4,
    (index) => {
      "name": "Mack",
      "role": "Super Admin",
      "location": "Multiple Locations",
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Top Logo and Profile Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/medicineicon.png', height: 100),
                  Icon(Icons.person, size: 30, color: Colors.black87),
                ],
              ),

              // Title and Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: 24,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Users",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.all(3),

                  child:Row(
                    children: [
                    
                      GestureDetector(
                        // onTap: () {
                        //   showDialog(
                        //     context: context,
                        //     builder: (BuildContext context) {
                        //       final TextEditingController nameController =
                        //           TextEditingController();
                        //       final TextEditingController genderController =
                        //           TextEditingController();
                        //       final TextEditingController emailController =
                        //           TextEditingController();

                        //       return AlertDialog(
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(16),
                        //         ),
                        //         title: Text(
                        //           "Add New Role",
                        //           style: TextStyle(
                        //             color: Colors.black,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ),
                        //         content: SingleChildScrollView(
                        //           child: Column(
                        //             children: [
                        //               TextField(
                        //                 controller: nameController,
                        //                 decoration: InputDecoration(
                        //                   labelText: "Name",
                        //                   hintText: "Enter name",
                        //                 ),
                        //               ),
                        //               SizedBox(height: 12),

                        //               SizedBox(height: 12),
                        //               TextField(
                        //                 controller: emailController,
                        //                 decoration: InputDecoration(
                        //                   labelText: "Role",
                        //                   hintText: "Enter Role",
                        //                 ),
                        //               ),
                        //               SizedBox(height: 20),
                        //               ElevatedButton(
                        //                 onPressed: () {
                        //                   String name = nameController.text;
                        //                   String gender = genderController.text;
                        //                   String email = emailController.text;

                        //                   // TODO: You can now save or process these values

                        //                   Navigator.pop(
                        //                     context,
                        //                   ); // close dialog
                        //                 },
                        //                 style: ElevatedButton.styleFrom(
                        //                   backgroundColor: Colors.black,
                        //                   foregroundColor: Colors.white,
                        //                 ),
                        //                 child: Text("Add Role"),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   );
                        // },

                       onTap: () {
  final TextEditingController roleController = TextEditingController();
  final Map<String, bool> permissions = {
    "Dashboard": false,
    "Patients": false,
    "Pos": false,
    "Inventory": false,
    "User Management": false,
    "Appointment": false,
    "Reputation": false,
    "Stock Panel": false,
    "Web Content": false,
    "Email Broadcast": false,
    "Promo Codes": false,
    "Sales Report": false,
    "Warehouse": false,
    "control": false,
    "Roles": false,
    "transactions": false,
  };

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Add New Role",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: roleController,
                    decoration: InputDecoration(
                      labelText: "User roles",
                      hintText: "Enter user role",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Permissions",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Column(
                    children: permissions.keys.map((key) {
                      return SwitchListTile(
                        title: Text(key),
                        value: permissions[key]!,
                        onChanged: (val) {
                          setState(() {
                            permissions[key] = val;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 👉 You can now save roleController.text and permissions map to your backend
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("Add Role"),
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      );
    },
  );
},
   
                        child: Column(
                          children: [
                            Icon(Icons.person_4_outlined, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              "Add New Role",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 5,height: 4,),
                      GestureDetector(
                        // onTap: () {
                        //   showDialog(
                        //     context: context,
                        //     builder: (BuildContext context) {
                        //       final TextEditingController nameController =
                        //           TextEditingController();
                        //       final TextEditingController genderController =
                        //           TextEditingController();
                        //       final TextEditingController emailController =
                        //           TextEditingController();

                        //       return AlertDialog(
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(16),
                        //         ),
                        //         title: Text(
                        //           "Add New User",
                        //           style: TextStyle(
                        //             color: Colors.black,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ),
                        //         content: SingleChildScrollView(
                        //           child: Column(
                        //             children: [
                        //               TextField(
                        //                 controller: nameController,
                        //                 decoration: InputDecoration(
                        //                   labelText: "Name",
                        //                   hintText: "Enter username",
                        //                 ),
                        //               ),
                        //               SizedBox(height: 12),
                        //               TextField(
                        //                 controller: genderController,
                        //                 decoration: InputDecoration(
                        //                   labelText: "Location",
                        //                   hintText: "Enter location",
                        //                 ),
                        //               ),
                        //               SizedBox(height: 12),
                        //               TextField(
                        //                 controller: emailController,
                        //                 decoration: InputDecoration(
                        //                   labelText: "Role",
                        //                   hintText: "Enter role",
                        //                 ),
                        //               ),
                        //               SizedBox(height: 20),
                        //               ElevatedButton(
                        //                 onPressed: () {
                        //                   String name = nameController.text;
                        //                   String gender = genderController.text;
                        //                   String email = emailController.text;

                        //                   // TODO: You can now save or process these values

                        //                   Navigator.pop(
                        //                     context,
                        //                   ); // close dialog
                        //                 },
                        //                 style: ElevatedButton.styleFrom(
                        //                   backgroundColor: Colors.black,
                        //                   foregroundColor: Colors.white,
                        //                 ),
                        //                 child: Text("Add User"),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       );
                        //     },
                       
                    

                    onTap: () {
  final TextEditingController usernameController =
      TextEditingController(text: "Admin#987");
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final List<String> roles = [
    "super admin",
    "sales person",
    "Setting",
    "POS",
    "manager",
    "Appoinment mang",
    "Patients",
    "Pos",
    "Inventory",
  ];

  String? selectedRole;

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
              // Top bar drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),

              Text(
                "Add New User",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Username
              TextField(
                controller: usernameController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Username",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),

              // Role Dropdown
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  hintText: "Select Role",
                  border: OutlineInputBorder(),
                ),
                items: roles
                    .map((role) => DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedRole = value;
                },
              ),
              SizedBox(height: 12),

              // Email
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),

              // Password
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),

              // Location (readonly or dropdown can be implemented)
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Select Locations",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // You can save all data here
                      print("Username: ${usernameController.text}");
                      print("Role: $selectedRole");
                      print("Email: ${emailController.text}");
                      print("Password: ${passwordController.text}");
                      print("Location: ${locationController.text}");

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: Text("Add User"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
},

                        child: Column(
                          children: [
                            Icon(Icons.add_circle_outline, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              "Add New User",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),

                  
                    ],
                  ),)
                ],
              ),

              SizedBox(height: 16),

              // User List
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F6FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['name']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  user['role']!,
                                  style: TextStyle(color: Colors.black87),
                                ),
                                Text(
                                  user['location']!,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        IconButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Add your delete logic here
              Navigator.of(context).pop(); // Close the dialog
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black,foregroundColor: Colors.white),
            child: Text("Delete"),
          ),
        ],
      ),
    );
  },
  icon: Icon(
    Icons.delete,
    color: Colors.redAccent,
    size: 28,
  ),
),

IconButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Patient"),
        content: Text("Are you sure you want to edit this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Add your edit logic here
              Navigator.of(context).pop(); // Close the dialog
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black,foregroundColor: Colors.white),
            child: Text("Edit"),
          ),
        ],
      ),
    );
  },
  icon: Icon(
    Icons.edit,
    color: Colors.blueAccent,
    size: 28,
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
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

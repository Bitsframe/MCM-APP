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
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final TextEditingController nameController = TextEditingController();
      final TextEditingController genderController = TextEditingController();
      final TextEditingController emailController = TextEditingController();

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
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
            Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  child: Column(children: [

 
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Category",
                hintText: "Enter Category",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
           
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                 

                  // TODO: Save or use the inputs here

                  Navigator.pop(context); // close the sheet
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
             ],))
          ],
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
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final TextEditingController nameController = TextEditingController();
      final TextEditingController genderController = TextEditingController();
      final TextEditingController emailController = TextEditingController();

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Add New User",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  child: Column(
    children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                hintText: "Enter Username",
                border: OutlineInputBorder(),
              ),
            ),
           
            
            SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Enter email address",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  String name = nameController.text;
                  String gender = genderController.text;
                  String email = emailController.text;

                 

                  Navigator.pop(context); // close the sheet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text("Add User"),
              ),
            ),
            SizedBox(height: 12),
          ],
  ))]
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
